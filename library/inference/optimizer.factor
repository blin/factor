! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: generic hashtables inference kernel lists
matrices namespaces sequences vectors ;

! We use the recursive-state variable here, to track nested
! label scopes, to prevent infinite loops when inlining
! recursive methods.

GENERIC: optimize-node* ( node -- node )

: keep-optimizing ( node -- node ? )
    dup optimize-node* dup t =
    [ drop f ] [ nip keep-optimizing t or ] ifte ;

DEFER: optimize-node

: optimize-children ( node -- )
    f swap [
        node-children [ optimize-node swap >r or r> ] map
    ] keep set-node-children ;

: optimize-node ( node -- node ? )
    #! Outputs t if any changes were made.
    keep-optimizing >r dup [
        dup optimize-children >r
        dup node-successor optimize-node >r
        over set-node-successor r> r> r> or or
    ] [ r> ] ifte ;

: optimize-loop ( dataflow -- dataflow )
    recursive-state off
    dup kill-set over kill-node
    dup infer-classes
    optimize-node [ optimize-loop ] when ;

: optimize ( dataflow -- dataflow )
    [
        dup solve-recursion dup split-node optimize-loop
    ] with-scope ;

: prune-if ( node quot -- successor/t )
    over >r call [ r> node-successor ] [ r> drop t ] ifte ;
    inline

! Generic nodes
M: f optimize-node* drop t ;

M: node optimize-node* ( node -- t )
    drop t ;

! #push
M: #push optimize-node* ( node -- node/t )
    [ node-out-d empty? ] prune-if ;

! #drop
M: #drop optimize-node*  ( node -- node/t )
    [ node-in-d empty? ] prune-if ;

! #ifte
: static-branch? ( node -- lit ? )
    node-in-d first dup literal? ;

: static-branch ( conditional n -- node )
    over drop-inputs
    [ >r swap node-children nth r> set-node-successor ] keep ;

M: #ifte optimize-node* ( node -- node )
    dup static-branch?
    [ literal-value 0 1 ? static-branch ] [ 2drop t ] ifte ;

! #values
: optimize-fold ( node -- node/t )
    node-successor [ node-successor ] [ t ] ifte* ;

M: #values optimize-node* ( node -- node/t )
    optimize-fold ;

! #return
M: #return optimize-node* ( node -- node/t )
    optimize-fold ;

! M: #label optimize-node* ( node -- node/t )
!     dup node-param over node-children first calls-label? [
!         drop t
!     ] [
!         dup node-children first dup node-successor [
!             dup penultimate-node rot
!             node-successor swap set-node-successor
!         ] [
!             drop node-successor
!         ] ifte
!     ] ifte ;
