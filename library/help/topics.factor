! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help
USING: arrays errors generic graphs hashtables io kernel
namespaces prettyprint sequences words ;

! Markup
GENERIC: print-element

! Help articles
SYMBOL: articles

TUPLE: article title content ;

: article ( name -- article )
    dup articles get hash
    [ ] [ "No such article: " swap unparse append throw ] ?if ;

: (add-article) ( name title element -- )
    <article> swap articles get set-hash ;

M: object article-title article article-title ;
M: object article-content article article-content ;

! Special case: f help
M: f article-title drop \ f article-title ;
M: f article-content drop \ f article-content ;

TUPLE: link name ;

: word-help ( word -- content ) "help" word-prop ;

: all-articles ( -- seq )
    articles get hash-keys
    all-words [ word-help ] subset append ;

GENERIC: elements* ( elt-type element -- )

: elements ( elt-type element -- seq ) [ elements* ] { } make ;

: collect-elements ( element seq -- elements )
    [
        [
            swap elements [
                1 swap tail [ dup set ] each
            ] each
        ] each-with
    ] make-hash hash-keys ;

SYMBOL: parent-graph

DEFER: $subsection

: children ( article -- seq )
    article-content { $subsection } collect-elements ;

: parents ( article -- seq )
    dup link? [ link-name ] when parent-graph get in-edges ;

: (where) ( article -- )
    dup , parents [ word? not ] subset dup empty?
    [ drop ] [ [ (where) ] each ] if ;

: where ( article -- seq )
    [ (where) ] { } make 1 swap tail prune ;

: xref-article ( article -- )
    [ children ] parent-graph get add-vertex ;

: unxref-article ( article -- )
    [ children ] parent-graph get remove-vertex ;

: xref-help ( -- )
    all-articles [ children ] parent-graph get build-graph ;