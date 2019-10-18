! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: arrays errors gadgets gadgets-frames gadgets-grids
gadgets-labels gadgets-panes gadgets-theme gadgets-viewports
generic hashtables io kernel math models namespaces prettyprint
queues sequences threads ;

! Assoc mapping aliens to gadgets
SYMBOL: windows

: window ( handle -- world ) windows get-global assoc ;

: register-window ( world handle -- )
    swap 2array windows get-global push ;

: unregister-window ( handle -- )
    windows get-global
    [ first = not ] subset-with
    windows set-global  ;

: raised-window ( world -- )
    windows get-global [ second eq? ] find-with drop
    windows get-global [ length 1- ] keep exchange ;

: update-hand ( gadget -- )
    find-world [
        dup hand-gadget get-global find-world eq?
        [ hand-loc get-global swap move-hand ] [ drop ] if
    ] when* ;

: post-layout ( gadget -- )
    find-world [ dup world-handle set ] when* ;

: layout-queued ( -- )
    invalid dup queue-empty? [
        drop
    ] [
        deque dup layout post-layout layout-queued
    ] if ;

: init-ui ( -- )
    <queue> \ invalid set-global
    V{ } clone windows set-global ;

: ui-step ( -- )
    do-timers
    [ layout-queued ] make-hash hash-values [
        dup update-hand
        dup world-handle [ dup draw-world ] when
        drop
    ] each
    10 sleep ;

: <status-bar> ( -- gadget ) "" <label> dup highlight-theme ;

TUPLE: titled-gadget title ;

M: titled-gadget gadget-title titled-gadget-title ;

M: titled-gadget focusable-child* gadget-child ;

C: titled-gadget ( gadget title -- )
    [ set-titled-gadget-title ] keep
    { { f f f @center } } make-frame* ;

: init-status ( world -- )
    dup world-status <label-control> dup highlight-theme
    swap @bottom grid-add ;

: open-window ( gadget -- )
    <world> dup init-status
    dup pref-dim over set-gadget-dim
    dup open-window*
    draw-world ;

: open-titled-window ( gadget title -- )
    <model> <titled-gadget> open-window ;

: find-window ( quot -- world )
    windows get [ second ] map
    [ world-gadget swap call ] find-last-with nip ; inline

: open-tool ( arg cons setter -- )
    >r call dup open-window r> call ; inline

: call-tool ( arg pred cons setter -- )
    rot find-window [
        rot drop
        dup raise-window
        world-gadget swap call
    ] [
        open-tool
    ] if* ; inline

: start-world ( world -- )
    dup graft
    dup relayout
    world-gadget request-focus ;

: close-global ( world global -- )
    dup get-global find-world rot eq?
    [ f swap set-global ] [ drop ] if ;

: focus-world ( world -- )
    #! Sent when native window receives focus
    t over set-world-focused?
    dup raised-window
    focused-ancestors f focus-gestures ;

: unfocus-world ( world -- )
    #! Sent when native window loses focus.
    f over set-world-focused?
    focused-ancestors f swap focus-gestures ;

: reset-world ( world -- )
    dup unfocus-world
    dup ungraft
    f over set-world-focus
    f over set-world-handle
    world-fonts clear-hash ;

: close-world ( world -- )
    dup hand-clicked close-global
    dup hand-gadget close-global
    dup free-fonts
    reset-world ;

: restore-windows ( -- )
    windows get [ second ] map
    0 windows get set-length
    [ dup reset-world open-window* ] each
    forget-rollover ;

: restore-windows? ( -- ? )
    windows get [ empty? not ] [ f ] if* ;

: make-toolbar ( quot -- gadget )
    { } make make-shelf dup highlight-theme ; inline

: error-window ( error -- )
    [ print-error ] make-pane "Error" open-titled-window ;

: ui-try ( quot -- )
    [ error-window ] recover ;

TUPLE: world-error world ;

C: world-error ( error world -- error )
    [ set-world-error-world ] keep
    [ set-delegate ] keep ;

M: world-error error. ( world-error -- )
    "An error occurred while drawing the world " write
    dup world-error-world pprint-short "." print
    "This world has been deactivated to prevent cascading errors." print
    delegate error. ;

: draw-world ( world -- )
    dup world-active? [
        [
            dup world set [
                dup (draw-world)
            ] [
                over <world-error> error-window
                f over set-world-active?
            ] recover
        ] with-scope
    ] when drop ;

IN: shells

DEFER: ui