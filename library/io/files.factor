! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: io
USING: hashtables kernel lists math memory namespaces sequences
strings styles ;

! Words for accessing filesystem meta-data.

: path+ ( path path -- path )
    over "/" tail? [ append ] [ "/" swap append3 ] if ;

: exists? ( file -- ? ) stat >boolean ;

: directory? ( file -- ? ) stat car ;

: directory ( dir -- list )
    (directory)
    [ { "." ".." } member? not ] subset natural-sort ;

: file-length ( file -- length ) stat third ;

: parent-dir ( path -- path )
    CHAR: / over last-index CHAR: \\ pick last-index max
    dup -1 = [ 2drop "." ] [ swap head ] if ;

: resource-path ( path -- path )
    image parent-dir swap path+ ;

: <resource-stream> ( path -- stream )
    #! Open a file path relative to the Factor source code root.
    resource-path <file-reader> ;

: (file.) ( name path -- )
    file associate [ format* ] with-style ;

DEFER: directory.

: (directory.) ( name path -- )
    dup [ directory. ] curry
    [ "/" append (file.) ] write-outliner terpri ;

: file. ( dir name -- )
    tuck path+
    dup directory? [ (directory.) ] [ (file.) terpri ] if ;

: directory. ( dir -- )
    dup directory [ file. ] each-with ;
