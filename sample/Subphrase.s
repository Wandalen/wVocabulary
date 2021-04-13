
if( typeof module !== 'undefined' )
require( 'wvocabulary' );
let _ = wTools;

/**/

var voc = new _.Vocabulary();
voc.phrasesAdd([ 'do.this', 'do.that', 'that.is' ]);

var found = voc.withSubphrase( 'do' );
console.log( found.map( ( e ) => e.phrase ) );
/* optput:
[ 'do.this', 'do.that' ]
*/

var found = voc.withSubphrase( 'that' );
console.log( found.map( ( e ) => e.phrase ) );
/* optput:
[ 'do.that', 'that.is' ]
*/

var found = voc.withSubphrase( '' );
console.log( found.map( ( e ) => e.phrase ) );
/* optput:
[ 'do.this', 'do.that', 'that.is' ]
*/

var found = voc.withSubphrase( 'do.this' );
console.log( found.map( ( e ) => e.phrase ) );
/* optput:
[ 'do.this' ]
*/
