
if( typeof module !== 'undefined' )
require( 'wvocabulary' );
var _ = wTools;

/**/

var vocabulary = new _.Vocabulary();
vocabulary.phrasesAdd([ 'do this', 'do that', 'this is' ]);

console.log( vocabulary.helpForSubject( 'do' ) );
[ '.do.this - Do this.', '.do.that - Do that.' ]

/*
[ '.do.this - Do this.', '.this.is - This is.' ]
*/

console.log( vocabulary.helpForSubject( 'this' ) );

/*
[ '.do.this - Do this.', '.this.is - This is.' ]
*/
