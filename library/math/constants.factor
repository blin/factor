! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel-internals
USING: namespaces math ;

: bootstrap-cell \ cell get ; inline
: cells cell * ; inline
: bootstrap-cells bootstrap-cell * ; inline

: cell-bits 8 cells ; inline
: bootstrap-cell-bits 8 bootstrap-cells ; inline

IN: math

: i C{ 0 1 } ; inline
: -i C{ 0 -1 } ; inline
: e 2.7182818284590452354 ; inline
: pi 3.14159265358979323846 ; inline
: epsilon 2.2204460492503131e-16 ; inline
: first-bignum 1 cell-bits tag-bits - 1- shift ; inline
: most-positive-fixnum first-bignum 1- >fixnum ; inline
: most-negative-fixnum first-bignum neg >fixnum ; inline
