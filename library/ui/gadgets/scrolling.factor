! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-scrolling
USING: arrays gadgets gadgets-frames gadgets-theme
gadgets-viewports generic kernel math namespaces sequences ;

! A scroller combines a viewport with two x and y sliders.
! The follows slot is a boolean, if true scroller will scroll
! down on the next relayout.
TUPLE: scroller viewport x y follows ;

: scroller-origin ( scroller -- { x y } )
    dup scroller-x slider-value
    swap scroller-y slider-value
    2array ;

: find-scroller [ scroller? ] find-parent ;

: scroll-up-line scroller-y -1 swap slide-by-line ;

: scroll-down-line scroller-y 1 swap slide-by-line ;

scroller H{
    { T{ wheel-up } [ scroll-up-line ] }
    { T{ wheel-down } [ scroll-down-line ] }
    { T{ slider-changed } [ relayout-1 ] }
} set-gestures

C: scroller ( gadget -- scroller )
    #! Wrap a scrolling pane around the gadget.
    {
        { [ <viewport> ] set-scroller-viewport f @center }
        { [ <x-slider> ] set-scroller-x        f @bottom }
        { [ <y-slider> ] set-scroller-y        f @right  }
    } make-frame*
    t over set-gadget-root?
    dup faint-boundary ;

: set-slider ( value page max slider -- )
    #! page/max/value are 3-vectors.
    [ [ gadget-orientation v. ] keep set-slider-max ] keep
    [ [ gadget-orientation v. ] keep set-slider-page ] keep
    [ [ gadget-orientation v. ] keep set-slider-value* ] keep
    slider-elevator relayout-1 ;

: update-slider ( scroller value slider -- )
    >r swap scroller-viewport dup rect-dim swap viewport-dim
    r> set-slider ;

: position-viewport ( scroller -- )
    dup scroller-origin vneg
    swap scroller-viewport gadget-child
    set-rect-loc ;

: scroll ( scroller value -- )
    2dup over scroller-x update-slider
    dupd over scroller-y update-slider
    position-viewport ;

: scroll>bottom ( gadget -- )
    find-scroller [ t swap set-scroller-follows ] when* ;

: update-scroller ( scroller -- )
    dup dup scroller-follows [
        f over set-scroller-follows
        scroller-viewport viewport-dim { 0 1 } v*
    ] [
        scroller-origin
    ] if scroll ;

M: scroller layout* ( scroller -- )
    dup delegate layout*
    dup layout-children
    update-scroller ;

M: scroller focusable-child* ( scroller -- viewport )
    scroller-viewport ;