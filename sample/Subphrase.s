
if( typeof module !== 'undefined' )
require( 'wvocabulary' );
let _ = wTools;

/**/

var voc = new _.Vocabulary();
voc.phrasesAdd([ 'do.this', 'do.that', 'that.is' ]);

console.log( 'do :' );
var found = voc.withSubphrase( 'do' );
found.forEach( ( e ) => console.log( e.phrase ) );
/* optput:
do :
do.this
do.that
*/

console.log( 'that :' );
var found = voc.withSubphrase( 'that' );
found.forEach( ( e ) => console.log( e.phrase ) );
/* optput:
that :
do.that
that.is
*/

console.log( '"" :' );
var found = voc.withSubphrase( '' );
found.forEach( ( e ) => console.log( e.phrase ) );
/* optput:
"" :
do.this
do.that
that.is
*/

console.log( 'do.this :' );
var found = voc.withSubphrase( 'do.this' );
found.forEach( ( e ) => console.log( e.phrase ) );
/* optput:
do.this :
do.this
*/
