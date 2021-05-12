# module::Vocabulary  [![status](https://github.com/Wandalen/wVocabulary/actions/workflows/StandardPublish.yml/badge.svg)](https://github.com/Wandalen/wVocabulary/actions/workflows/StandardPublish.yml) [![stable](https://img.shields.io/badge/stability-stable-brightgreen.svg)](https://github.com/emersion/stability-badges#stable)

Vocabulary of phrases, primarily for CLI. Implements class to operate phrases. Vocabulary enables the design of CLI based on phrases instead of words. Also, Vocabulary makes it possible to group phrases by similarity, powering partial match search.

[Module::CommandsAggregator](https://github.com/Wandalen/wCommandsAggregator) uses the module to expose CLI for many utilities. Use it to make your CLI more user-friendly.

### Try out from the repository

```
git clone https://github.com/Wandalen/wVocabulary
cd wVocabulary
will .npm.install
node sample/trivial/Sample.s
```

Make sure you have utility `willbe` installed. To install willbe: `npm i -g willbe@stable`. Willbe is required to build of the module.

### To add to your project

```
npm add 'wvocabulary@stable'
```

`Willbe` is not required to use the module in your project as submodule.

### Concepts

[Phrase](./doc/concept/All.md#phrase) - sequence of words. \
[Word](./doc/concept/All.md#word) - string which does not contain delimeter. \
[Delimeter](./doc/concept/All.md#delimeter) - by default, both dot `.` and space ` ` represents delimeter. \
[Subphrase](./doc/concept/All.md#subphrase) - phrase with sequence of words removed from it. \
[Vocabulary](./doc/concept/All.md#vocabulary) - collection of phrases and related data.

<!-- xxx : qqq : duplicate in doc/* and make links working -->

### Basics

Vocabulary collects a set of prases and satisfies search requests. A request could include all words the phrase consists of a subphrase.

```js
var voc = new _.Vocabulary();
voc.phrasesAdd([ 'do this', 'do that', 'that is' ]);

var found = voc.withPhrase( 'do this' );
console.log( found.phrase );
console.log( found.words );

/* optput:
do this
[ 'do', 'this' ]
*/
```
In this example, vocabulary is created and filled with 3 phrases. Method `voc.withPhrase` returns phrase descriptor. The trivial version phrase descriptor has 2 fields: `phrase` and `words`. Field `words` is the array of words in the phrase. By default, vocabulary accepts both dot `.`  and space ` ` as delimiter between words.

### Search by subphrase

To find phrases by subphrases use the method `withSubphrase`.

```js
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
```

A partial match of a phrase is enough to get in in the array `found`. If any subsequence of words match with the

### Custom phrase descriptor

To use a custom phrase descriptor pass your implementation of routines `onPhraseDescriptorFrom` and `onPhraseDescriptorIs` to the constructor of the vocabulary.

```js
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
```

Callback `onPhraseDescriptorFrom` accepts 2 arguments, argument phrase either null or phrase of the descriptor. Callback `onPhraseDescriptorIs` answer the question: "is that phrase descriptor?".
