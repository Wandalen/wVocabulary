
if( typeof module !== 'undefined' )
require( 'wvocabulary' );
let _ = wTools;

/**/

var voc = new _.Vocabulary({ onPhraseDescriptorFrom, onPhraseDescriptorIs });

voc.phraseAdd( 'do this' );
voc.phraseAdd( 'do that' );
voc.phraseAdd( 'that is' );

var found = voc.withPhrase( 'do this' );
console.log( found.phrase );
console.log( found.words );
console.log( found.type );

/* optput:
do this
[ 'do', 'this' ]
custom.phrase.descriptor
*/

function onPhraseDescriptorFrom( src, phrase )
{
  if( src.phrase )
  src.phrase = this.phraseNormalize( src.phrase );
  phrase = phrase || src.phrase || src;
  if( _.strIs( src ) )
  src = Object.create( null );
  src.phrase = phrase;
  src.type = 'custom.phrase.descriptor';
  return src;
}

function onPhraseDescriptorIs( phraseDescriptor )
{
  return phraseDescriptor.type === 'custom.phrase.descriptor'
}
