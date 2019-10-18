! Copyright (C) 2003, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: kernel
USING: errors hashtables io kernel-internals namespaces
parser sequences strings ;

: run-user-init ( -- )
    #! Run user init file if it exists
    "user-init" get [
        "~" get "/.factor-rc" append dup exists?
        [ try-run-file ] [ drop ] if
    ] when ;

: cli-var-param ( name value -- ) swap set-global ;

: cli-bool-param ( name -- ) "no-" ?head not cli-var-param ;

: cli-param ( param -- )
    #! Handle a command-line argument starting with '-' by
    #! setting that variable to t, or if the argument is
    #! prefixed with 'no-', setting the variable to f.
    #!
    #! Arguments containing = are handled differently; they
    #! set the object path.
    "=" split1 [ cli-var-param ] [ cli-bool-param ] if* ;

: cli-arg ( argument -- argument )
    #! Handle a command-line argument. If the argument was
    #! consumed, returns f. Otherwise returns the argument.
    #! Parameters that start with + are runtime parameters.
    "-" ?head [ cli-param f ] when ;

: cli-args ( -- args ) 10 getenv ;

: default-shell "tty" ;

: default-cli-args
    #! Some flags are *on* by default, unless user specifies
    #! -no-<flag> CLI switch
    "user-init" on
    "compile" on
    "native-io" on
    "null-stdio" off
    macosx? "cocoa" set
    unix? macosx? not and "x11" set
    default-shell "shell" set ;

: ignore-cli-args? ( -- ? )
    #! On Mac OS X, files to run are given to us via a Cocoa API
    #! so we ignore any command line switches which name files.
    macosx? "shell" get "ui" = and ;

: parse-command-line ( -- )
    cli-args [ cli-arg ] subset
    ignore-cli-args? [ drop ] [ [ try-run-file ] each ] if ;