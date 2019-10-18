! Copyright (C) 2004, 2005 Mackenzie Straight.

IN: win32-stream
USING: alien errors generic kernel kernel-internals math namespaces
       prettyprint sequences io strings threads win32-api
       win32-io-internals io-internals ;

TUPLE: win32-server this ;
TUPLE: win32-client-stream host port ;
SYMBOL: winsock
SYMBOL: socket

: maybe-init-winsock ( -- )
    winsock get [
        HEX: 0202 <wsadata> WSAStartup drop winsock on
    ] unless ;

: handle-socket-error ( -- )
    WSAGetLastError [
      ERROR_IO_PENDING ERROR_SUCCESS
    ] member? [
      WSAGetLastError win32-error-message throw 
    ] unless ;

: new-socket ( -- socket )
    AF_INET SOCK_STREAM 0 f f WSA_FLAG_OVERLAPPED WSASocket ;

: setup-sockaddr ( port -- sockaddr )
    "sockaddr-in" <c-object> swap
    htons over set-sockaddr-in-port
    INADDR_ANY over set-sockaddr-in-addr 
    AF_INET over set-sockaddr-in-family ;

: bind-socket ( port socket -- )
    swap setup-sockaddr "sockaddr-in" c-size wsa-bind zero? [
        handle-socket-error
    ] unless ;

: listen-socket ( socket -- )
    20 wsa-listen zero? [ handle-socket-error ] unless ;

: sockaddr> ( sockaddr -- port host )
    dup sockaddr-in-port ntohs swap sockaddr-in-addr inet-ntoa ;

: extract-remote-host ( buffer -- port host )
    buffer-ptr <alien> 0 32 32 0 <int> 
                               0 <int>
                               0 <int> 
                        dup >r 0 <int>
    GetAcceptExSockaddrs r> *int <alien> sockaddr> ;

C: win32-client-stream ( buf stream -- stream )
    [ set-delegate extract-remote-host ] keep
    [ set-win32-client-stream-host ] keep 
    [ set-win32-client-stream-port ] keep ;

M: win32-client-stream client-stream-host win32-client-stream-host ;
M: win32-client-stream client-stream-port win32-client-stream-port ;

C: win32-server ( port -- server )
    swap [ 
        maybe-init-winsock new-socket swap over bind-socket dup listen-socket 
        dup add-completion
        socket set
        dup stream set
    ] make-hash over set-win32-server-this ;

M: win32-server stream-close ( server -- )
    win32-server-this [ socket get CloseHandle drop ] bind ;

M: win32-server set-timeout ( timeout server -- )
    win32-server-this [ timeout set ] bind ;

M: win32-server expire ( -- )
    win32-server-this [
        timeout get [ millis cutoff get > [ socket get CancelIo ] when ] when
    ] bind ;

: client-sockaddr ( host port -- sockaddr )
    setup-sockaddr [
        >r gethostbyname handle-socket-error hostent-addr
        r> set-sockaddr-in-addr
    ] keep ;

IN: io
: accept ( server -- client )
    win32-server-this [
        update-timeout new-socket 64 <buffer>
        [
            stream get alloc-io-callback init-overlapped
            >r >r >r socket get r> r> 
            buffer-ptr <alien> 0 32 32 f r> AcceptEx
            [ handle-socket-error ] unless stop
        ] callcc1 pending-error drop
        swap dup add-completion <win32-stream> <line-reader> 
        dupd <win32-client-stream> swap buffer-free
    ] bind ;

: <client> ( host port -- stream )
    maybe-init-winsock client-sockaddr new-socket
    [ swap "sockaddr-in" c-size connect drop handle-socket-error ] keep 
    dup add-completion <win32-stream> <line-reader> ;
