
if( typeof module !== 'undefined' )
require( 'wvocabulary' );
let _ = wTools;

/**/

var voc = new _.Vocabulary();
voc.phrasesAdd([ 'do this', 'do that', 'that is' ]);

var found = voc.withPhrase( 'do this' );
console.log( found.phrase );
console.log( found.words );

/* optput:
do this
[ 'do', 'this' ]
*/

