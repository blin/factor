! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: telnetd
USING: errors listener kernel math namespaces io threads parser ;

: telnet-client ( socket -- )
    dup [ log-client print-banner listener ] with-stream ;

: telnet-connection ( socket -- )
    [ telnet-client ] in-thread drop ;

: telnetd-loop ( server -- server )
    [ accept telnet-connection ] keep telnetd-loop ;

: telnetd ( port -- )
    [
        <server> [
            telnetd-loop
        ] [
            swap stream-close rethrow
        ] catch
    ] with-logging ;

IN: shells

: telnet
    "telnetd-port" get string>number telnetd ;

! This is a string since we string>number it above.
global [ "9999" "telnetd-port" set ] bind
