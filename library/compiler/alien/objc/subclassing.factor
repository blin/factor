! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: objc
USING: alien arrays compiler hashtables kernel kernel-internals
libc math namespaces sequences strings words ;

: init-method ( method alien -- )
    >r first3 r>
    [ >r execute r> set-objc-method-imp ] keep
    [ >r <malloc-string> r> set-objc-method-types ] keep
    >r sel_registerName r> set-objc-method-name ;

: <empty-method-list> ( n -- alien )
    "objc-method-list" c-size
    "objc-method" c-size pick * + 1 calloc
    [ set-objc-method-list-count ] keep ;

: <method-list> ( methods -- alien )
    dup length dup <empty-method-list> -rot
    [ pick method-list@ objc-method-nth init-method ] 2each ;

: <method-lists> ( methods -- lists )
    <method-list> alien-address
    "void*" <malloc-object> [ 0 set-alien-unsigned-cell ] keep ;

: <objc-class> ( name info -- class )
    "objc-class" <malloc-object>
    [ set-objc-class-info ] keep
    [ >r <malloc-string> r> set-objc-class-name ] keep ;

! The Objective C object model is a bit funny.
! Every class has a metaclass.

! The superclass of the metaclass of X is the metaclass of the
! superclass of X.

! The metaclass of the metaclass of X is the metaclass of the
! root class of X.
: meta-meta-class ( class -- class ) root-class objc-class-isa ;

: copy-instance-size ( class -- )
    dup objc-class-super-class objc-class-instance-size
    swap set-objc-class-instance-size ;

: <meta-class> ( methods superclass name -- class )
    CLS_META <objc-class>
    [ >r dup objc-class-isa r> set-objc-class-super-class ] keep
    [ >r meta-meta-class r> set-objc-class-isa ] keep
    [ >r <method-lists> r> set-objc-class-methodLists ] keep
    dup copy-instance-size ;

: <new-class> ( methods metaclass superclass name -- class )
    CLS_CLASS <objc-class>
    [ set-objc-class-super-class ] keep
    [ set-objc-class-isa ] keep
    [ >r <method-lists> r> set-objc-class-methodLists ] keep
    dup copy-instance-size ;

: (define-objc-class) ( imeth cmeth superclass name -- )
    >r objc-class r> [ <meta-class> ] 2keep <new-class>
    objc_addClass ;

: encode-types ( return types -- encoding )
    >r 1array r> append
    [ [ alien>objc-types get hash % CHAR: 0 , ] each ] "" make ;

: struct-return ( ret types quot -- ret types quot )
    pick c-struct? [
        pick c-size [ memcpy ] curry append
        >r { "void*" } swap append >r drop "void" r> r>
    ] when ;

: prepare-method ( ret types quot -- type imp )
    >r [ encode-types ] 2keep r>
    [ struct-return 3array % \ alien-callback , ] [ ] make
    compile-quot ;

: prepare-methods ( methods -- methods )
    [ first4 prepare-method 3array ] map ;

: define-objc-class ( superclass name imeth cmeth -- )
    pick >r
    [ prepare-methods ] 2apply
    [ 2array % 2array % \ (define-objc-class) , ] [ ] make
    r> swap import-objc-class ;