IN: temporary
USE: lists
USE: kernel
USE: math
USE: namespaces
USE: random
USE: test
USE: compiler

: sort-benchmark
    [ 100000 [ 0 10000 random-int , ] times ] make-vector [ - ] sort drop ; compiled

[ ] [ sort-benchmark ] unit-test
