! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
! Wrapper for the Prototype javascript library.
! For information and license details for protoype 
! see http://prototype.conio.net
IN: prototype-js
USING: callback-responder html httpd io kernel namespaces
strings ;

: include-prototype-js ( -- )
  #! Write out the HTML script tag to include the prototype
  #! javascript library.
  <script "text/javascript" =type "/responder/resources/contrib/httpd/javascript/prototype.js"
  =src script>
  </script> ;

: updating-javascript ( id quot -- string )
  #! Return the javascript code to perform the updating
  #! ajax call.
  t register-html-callback swap 
  [ "new Ajax.Updater(\"" % % "\",\"" % % "\", { method: \"get\" });" % ] "" make ;

: toggle-javascript ( string id -- string )
    [
        "if(Element.visible(\"" % dup % "\"))" %
        "Element.hide(\"" % dup % "\");" %
        "else {" %
        swap %
        " Element.show(\"" % % "\"); }" %
    ] "" make ;

: updating-anchor ( text id quot -- )
  #! Write the HTML for an anchor that when clicked will
  #! call the given quotation on the server. The output generated
  #! from that quotation will replace the DOM element on the page with
  #! the given id. The 'text' is the anchor text.
  over >r updating-javascript r> toggle-javascript
  <a =onclick a> write </a> ;