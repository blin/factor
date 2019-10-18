! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: alien
USING: assembler compiler errors generic hashtables kernel lists
math namespaces parser sequences strings words ;

! Some code for interfacing with C structures.

: define-getter ( offset type name -- )
    #! Define a word with stack effect ( alien -- obj ) in the
    #! current 'in' vocabulary.
    create-in >r
    [ "getter" get ] bind cons r> swap define-compound ;

: define-setter ( offset type name -- )
    #! Define a word with stack effect ( obj alien -- ) in the
    #! current 'in' vocabulary.
    "set-" swap append create-in >r
    [ "setter" get ] bind cons r> swap define-compound ;

: define-field ( offset type name -- offset )
    >r c-type dup >r [ "align" get ] bind align r> r>
    "struct-name" get swap "-" swap append3
    ( offset type name -- )
    3dup define-getter 3dup define-setter
    drop [ "width" get ] bind + ;

: define-member ( max type -- max )
    c-type [ "width" get ] bind max ;

: define-struct-type ( width -- )
    #! Define inline and pointer type for the struct. Pointer
    #! type is exactly like void*.
    [
        "width" set
        cell "align" set
        [ swap <displaced-alien> ] "getter" set
    ]
    "struct-name" get define-c-type
    "struct-name" get "in" get init-c-type ;
