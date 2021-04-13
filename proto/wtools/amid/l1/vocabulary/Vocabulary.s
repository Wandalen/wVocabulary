( function _Vocabulary_s_()
{

'use strict';

/**
 * Class to operate phrases. A phrase consists of words. Vocabulary enables the design of CLI based on phrases instead of words. It makes possible to group several similar phrases and help a user learn CLI faster. Use it to make your CLI more user-friendly.
 * @module Tools/mid/Vocabulary
*/

/**
 *  */

if( typeof module !== 'undefined' )
{
  const _ = require( '../../../../node_modules/Tools' );
  _.include( 'wCopyable' );
}

//

const _ = _global_.wTools;

/**
* Definitions :

*  word :: smallest part of a phrase( e.g., 'deck' ).
*  phrase :: combination of words with space as separator( e.g., 'deck properties' ).
*  subject :: a word or combination of it, used during search to determine if phrase is related to the subject.
*  clause :: a piece of a phrase( e.g. 'deck' is subphrase of 'deck properties' ).
*  phraseDescriptor :: object that contains info about a phrase.


*/

/**
* Options object for wVocabulary constructor
* @typedef {Object} wVocabularyOptions
* @property {function} [ onPhraseDescriptorFrom ] Creates phraseDescriptor based on data of the phrase. By default its a routine that wraps passed phrase into object.
* @property {boolean} [ overriding=0 ] Controls overwriting of existing phrases.
* @property {boolean} [ freezing=1 ] Prevents future extensions of phrase phraseDescriptor.
* @class wVocabulary
* @module Tools/mid/Vocabulary
*/

/**
* Containers of wVocabulary instance
* @typedef {Object} wVocabularyMaps
* @property {Array} [ descriptorSet ] Contains descriptors of available phrases.
* @property {Object} [ phraseMap ] Maps phrase with its phraseDescriptor.
* @property {Object} [ wordMap ] Maps each word of the phrase with descriptors of phrases that contains it.
* @property {Object} [ subphraseMap ] Maps possible subjects with descriptors of phrases that contains it.
* @class wVocabulary
* @module Tools/mid/Vocabulary
*/

/**
* @summary Creates instance of wVocabulary
*
* @classdesc Class to operate phrases.
* @example
*  let vocabulary = new wVocabulary();
*
* @example
* let o = { freezing : 0 }
* let vocabulary = new wVocabulary( o );
*
* @param {wVocabulary~wVocabularyOptions}[o] initialization options {@link module:Tools/mid/Vocabulary.wVocabulary~wVocabularyOptions}.
* @class wVocabulary
* @returns {Object} Returns instance of `wVocabulary`.
* @namespace wTools
* @module Tools/mid/Vocabulary
*/

const Parent = null;
const Self = wVocabulary;
function wVocabulary( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'Vocabulary';

// --
// inter
// --

/**
 * Initialises instance of wVocabulary
 * @param {wVocabulary~wVocabularyOptions}[o] initialization options {@link module:Tools/mid/Vocabulary.wVocabulary~wVocabularyOptions}.
 * @private
 * @method init
 * @class wVocabulary
 * @namespace wTools
 * @module Tools/mid/Vocabulary
 */

function init( o )
{
  let self = this;

  _.workpiece.initFields( self );
  Object.preventExtensions( self );

  if( o )
  self.copy( o );

  // self.preform();
}

//

function preform()
{
  let self = this;
  _.assert( self.formed === 0 );
  self.formed = 1;

  if( self.defaultDelimeter === null )
  self.defaultDelimeter = _.arrayAs( self.delimeter )[ 0 ]

  // if( self.freezing )
  // {
  //   Object.freeze( self.descriptorSet );
  //   Object.freeze( self.phraseMap );
  //   Object.freeze( self.wordMap );
  // }

  return self;
}

// --
//
// --

/**
 * Shrort-cut for {@link module:Tools/mid/Vocabulary.wVocabulary#phraseAdd wVocabulary.phraseAdd} method.
 * @description
 * Adds provided phrase(s) to the vocabulary.
 * Routine analyzes provided phrase(s) and creates phraseDescriptor for each phrase by calling ( wVocabulary.onPhraseDescriptorFrom ) routine and complementing it with additional data.
 * Routine expects that result of ( wVocabulary.onPhraseDescriptorFrom ) call will be an Object.
 * Data from phraseDescriptor is used to update containers of the vocabulary, see {@link module:Tools/mid/Vocabulary.wVocabulary~wVocabularyOptions} for details.
 * If phrases are provided in Array, they can have any type.
 * If ( wVocabulary.overriding ) is enabled, existing phrase can be rewritten by new one.
 * @param {String|Array} src Source phrase or array of phrases.
 * @returns {wVocabulary} Returns wVocabulary instance.
 *
 * @example
 * let vocabulary = new wVocabulary();
 * let phrase = 'deck properties';
 * vocabulary.phrasesAdd( phrases );
 * console.log( _.entity.exportString( vocabulary, { levels : 99 }) )
 *
 * @example
 * let vocabulary = new wVocabulary();
 * let phrases =
 * [
 *  'deck properties',
 *  'deck about'
 * ];
 * vocabulary.phrasesAdd( phrases );
 * console.log( _.entity.exportString( vocabulary, { levels : 99 }) )
 *
 * @method phrasesAdd
 * @throws { Exception } Throw an exception if more than one argument is provided.
 * @throws { Exception } Throw an exception if ( src ) is not a String or Array.
 * @throws { Exception } Throw an exception if ( phraseDescriptor ) made by ( onPhraseDescriptorFrom ) routine is not an Object.
 * @throws { Exception } Throw an exception if ( src ) is an empty phrase.
 * @throws { Exception } Throw an exception if phrase ( src ) already exists and ( wVocabulary.overriding ) is disabled.
 * @class wVocabulary
 * @namespace wTools
 * @module Tools/mid/Vocabulary
 *
 */

function phrasesAdd( src )
{
  let self = this;
  let vocabulary = this;
  let oldDescriptor = null;

  _.assert( _.strIs( src ) || _.containerIs( src ), 'Expects string or array' );
  _.assert( arguments.length === 1, 'Expects single argument' );

  if( !self.formed )
  self.preform();

  if( _.longIs( src ) )
  _.each( src, ( e, k ) =>
  {
    self._phraseAdd( e, null );
  });
  else if( _.aux.is( src ) )
  _.each( src, ( e, k ) =>
  {
    self._phraseAdd( e, k );
  });
  else
  {
    self._phraseAdd( src, null );
  }

  return self;
}

//

/**
 * @summary Adds provided phraseto the vocabulary.
 * Routine analyzes provided phrase and creates phraseDescriptor for each phrase by calling ( wVocabulary.onPhraseDescriptorFrom ) routine and complementing it with additional data.
 * Routine expects that result of ( wVocabulary.onPhraseDescriptorFrom ) call will be an Object.
 * Data from phraseDescriptor is used to update containers of the vocabulary, see {@link module:Tools/mid/Vocabulary.wVocabulary~wVocabularyOptions} for details.
 * If ( wVocabulary.overriding ) is enabled, existing phrase can be rewritten by new one.
 * @param {String} src Source phrase or array of phrases.
 * @returns {wVocabulary} Returns `wVocabulary` instance.
 *
 * @example
 * let vocabulary = new wVocabulary();
 * let phrase = 'deck properties';
 * vocabulary.phraseAdd( phrase );
 * console.log( _.entity.exportString( vocabulary, { levels : 99 }) )
 *
 * @method phraseAdd
 * @throws { Exception } Throw an exception if more than one argument is provided.
 * @throws { Exception } Throw an exception if ( src ) is not a String.
 * @throws { Exception } Throw an exception if ( phraseDescriptor ) made by ( onPhraseDescriptorFrom ) routine is not an Object.
 * @throws { Exception } Throw an exception if ( src ) is an empty phrase.
 * @throws { Exception } Throw an exception if phrase ( src ) already exists and ( wVocabulary.overriding ) is disabled.
 * @class wVocabulary
 * @namespace wTools
 * @module Tools/mid/Vocabulary
 *
 */

function phraseAdd( src )
{
  let self = this;
  let vocabulary = this;

  if( !self.formed )
  self.preform();

  self._phraseAdd( src, null );

  return self;
}

//

function _phraseAdd( src, phrase )
{
  let self = this;
  let vocabulary = this;
  let oldDescriptor = null;

  /* */

  _.assert( self.formed === 1, 'Vocabulary is not preformed' );
  _.assert( arguments.length === 2 );
  _.assert( _.strsAreAll( self.delimeter ) );

  if( phrase !== null )
  phrase = self.phraseNormalize( phrase );
  let phraseDescriptor = self.onPhraseDescriptorFrom( src, phrase );
  _.assert( self.onPhraseDescriptorIs( phraseDescriptor ) );
  _.assert( _.strDefined( phraseDescriptor.phrase ) );

  self.phraseAnalyzeTolerant({ dst : phraseDescriptor, phrase : phraseDescriptor.phrase });
  _.assert( _.strDefined( phraseDescriptor.phrase ) );
  _.assert( _.arrayIs( phraseDescriptor.words ) );

  /* */

  if( self.phraseMap[ phraseDescriptor.phrase ] )
  {
    _.sure( phraseDescriptor.override || self.overriding, 'Phrase overriding :', phraseDescriptor.phrase );
    oldDescriptor = self.phraseMap[ phraseDescriptor.phrase ];
  }

  self._updateDescriptorSet({ phraseDescriptor, words : phraseDescriptor.words, oldDescriptor });
  self._updateWordMap({ phraseDescriptor, words : phraseDescriptor.words, oldDescriptor });
  if( self.subphraseMap )
  self._updateSubphraseMap({ phraseDescriptor, words : phraseDescriptor.words, oldDescriptor });

  /* freeze */

  if( self.freezing )
  Object.preventExtensions( phraseDescriptor );
  return self;
}

//

function _updateDescriptorSet( o )
{
  let self = this;

  self.phraseMap[ o.phraseDescriptor.phrase ] = o.phraseDescriptor;

  if( o.oldDescriptor )
  self.descriptorSet.delete( o.oldDescriptor );
  self.descriptorSet.add( o.phraseDescriptor );

  return self;
}

_updateDescriptorSet.defaults =
{
  phraseDescriptor : null,
  oldDescriptor : null
}

//

function _updateWordMap( o )
{
  let self = this;

  for( let w = 0 ; w < o.words.length ; w++ )
  {
    let word = o.words[ w ];

    self.wordMap[ word ] = _.arrayAs( self.wordMap[ word ] || [] );

    if( o.oldDescriptor )
    {
      _.arrayReplaceOnceStrictly( self.wordMap[ word ], o.oldDescriptor, o.phraseDescriptor );
    }
    else
    {
      self.wordMap[ word ].push( o.phraseDescriptor );
    }

  }

  return self;
}

_updateWordMap.defaults =
{
  phraseDescriptor : null,
  words : null,
  oldDescriptor : null
}

//

function withPhrase( o )
{
  let self = this;
  let result = [];
  let added = [];

  if( !self.formed )
  self.preform();

  if( !_.objectIs( o ) )
  o = { phrase : arguments[ 0 ] };

  _.assert( _.mapIs( self.wordMap ) );
  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.routineOptions( withPhrase, o );

  let parsed = self.phraseAnalyzeTolerant({ phrase : o.phrase, delimeter : o.delimeter });

  result = self.phraseMap[ parsed.phrase ];

  return result;
}

withPhrase.defaults =
{
  phrase : null,
  delimeter : null,
}

//

function phraseParse_head( routine, args )
{
  let self = this;
  let o = args[ 0 ];
  if( !_.objectIs( o ) )
  o = { phrase : args[ 0 ] };

  _.assert
  (
    _.strIs( o.phrase ) || _.arrayIs( o.phrase ),
    () => `Expects string or array of words, but got ${_.entity.strType( o.phrase )}`
  );
  _.assert( arguments.length === 2 );
  _.assert( args.length === 1 );
  _.routineOptions( routine, o );

  return o;
}

//

function phraseParseNormal_body( o )
{
  let self = this;
  o.delimeter = o.delimeter === null ? self.defaultDelimeter : o.delimeter;
  if( _.arrayIs( o.phrase ) )
  {
    return o.phrase;
  }
  else
  {
    if( o.phrase === '' )
    return [];
    return o.phrase.split( o.delimeter );
  }
}

phraseParseNormal_body.defaults =
{
  phrase : null,
  delimeter : null,
}

let phraseParseNormal = _.routine.unite( phraseParse_head, phraseParseNormal_body );

function phraseParseTolerant_body( o )
{
  let self = this;
  o.delimeter = o.delimeter === null ? self.delimeter : o.delimeter;
  if( _.arrayIs( o.phrase ) )
  return o.phrase;
  else
  return _.strSplitNonPreserving({ src : o.phrase, delimeter : o.delimeter });
}

phraseParseTolerant_body.defaults =
{
  phrase : null,
  delimeter : null,
}

let phraseParseTolerant = _.routine.unite( phraseParse_head, phraseParseTolerant_body );

//

/**
 * @summary Parses provided phrase.
 * @param {String} o Options map.
 * @param {String} o.phrase Source phrase.
 * @param {String} o.delimeter Delimeter used in phrase.
 * @returns {Object} Returns map with results of parsing. Map contains source phrase and array of words that was splitted by `o.delimeneter`.
 *
 * @example
 * let vocabulary = new wVocabulary();
 * let phrase = 'deck.properties';
 * let result = vocabulary.phraseAnalyzeTolerant({ phrase : phrase, delimeneter : '.' });
 * console.log( result );
 *
 * @method phraseAnalyzeTolerant
 * @throws { Exception } Throw an exception if more than one argument is provided.
 * @throws { Exception } Throw an exception if ( src ) is not a String.
 * @class wVocabulary
 * @namespace wTools
 * @module Tools/mid/Vocabulary
 */

function phraseAnalyzeNormal_body( o )
{
  let self = this;
  let result = o.dst = o.dst || Object.create( null );
  if( _.arrayIs( o.phrase ) )
  result.words = o.phrase;
  else
  result.words = self.phraseParseNormal.body.call( self, o );
  result.phrase = result.words.join( self.defaultDelimeter );
  return result;
}

phraseAnalyzeNormal_body.defaults =
{
  dst : null,
  phrase : null,
  delimeter : null,
}

let phraseAnalyzeNormal = _.routine.unite( phraseParse_head, phraseAnalyzeNormal_body );

function phraseAnalyzeTolerant_body( o )
{
  let self = this;
  let result = o.dst = o.dst || Object.create( null );
  if( _.arrayIs( o.phrase ) )
  result.words = o.phrase;
  else
  result.words = self.phraseParseTolerant.body.call( self, o );
  result.phrase = result.words.join( self.defaultDelimeter );
  return result;
}

phraseAnalyzeTolerant_body.defaults =
{
  dst : null,
  phrase : null,
  delimeter : null,
}

let phraseAnalyzeTolerant = _.routine.unite( phraseParse_head, phraseAnalyzeTolerant_body );

//

function phraseNormalize( src )
{
  let self = this;
  return self.phraseAnalyzeTolerant({ phrase : src, delimeter : self.delimeter }).phrase;
}

//

function _onPhraseDescriptorFromSimplest( src, phrase )
{
  let self = this;

  _.assert( _.strIs( src ) );
  _.assert( arguments.length === 2 );

  src = self.phraseNormalize( src );
  _.assert( phrase === null || phrase === src );

  let result = Object.create( null );
  result.phrase = src;
  return result;
}

//

function _onPhraseDescriptorIs( phraseDescriptor )
{
  let self = this;
  return !!phraseDescriptor;
}

// --
// subphrase
// --

/**
 * @summary Returns subphrase descriptors for phrase.
 * @param {String} o Options map.
 * @param {String} o.phrase Source phrase.
 * @param {String} o.delimeter Delimeter used in phrase.
 * @param {Boolean} o.exact Tries to find descriptor with identical phrase.
 * @returns {Object} Returns single descriptor or several in map. Returns `undefined` if `o.exact` is enabled and nothing was found.
 *
 * @example
 * let vocabulary = new wVocabulary();
 * let phrase = 'deck properties';
 * vocabulary.phraseAdd( phrase );
 * let descriptor = vocabulary.withSubphrase({ phrase : phrase });
 * console.log( descriptor );
 *
 * @method withSubphrase
 * @throws { Exception } Throw an exception if more than one argument is provided.
 * @throws { Exception } Throw an exception if ( src ) is not a String.
 * @throws { Exception } Throw an exception if found more than one descriptor with `o.exact` enabled.
 * @class wVocabulary
 * @namespace wTools
 * @module Tools/mid/Vocabulary
 */

function withSubphrase( o )
{
  let self = this;
  let result = [];
  let added = [];

  if( !_.objectIs( o ) )
  o = { phrase : arguments[ 0 ] };

  if( !self.formed )
  self.preform();

  _.assert( _.mapIs( self.wordMap ) );
  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.routineOptions( withSubphrase, o );

  let parsed = self.phraseAnalyzeTolerant({ phrase : o.phrase, delimeter : o.delimeter });

  if( self.subphraseMap === null )
  self.subphrasesForm();

  _.assert( !!self.subphraseMap );
  result = self.subphraseMap[ parsed.phrase ] || [];
  // result = [ ... _.trie.valEachAbove( self.subphraseMap, parsed.words ).vals ];
  // let child = _.trie.withPath( self.subphraseMap, parsed.words ).child;
  // result = [ ... ( child ? child.vals : [] ) ];

  if( result.length > 1 && o.minimal )
  if( self.phraseMap[ parsed.phrase ] )
  {
    let minimal = result.filter( ( descriptor ) => descriptor.phrase === parsed.phrase );
    if( minimal.length )
    return minimal;
  }

  return result;
}

withSubphrase.defaults =
{
  phrase : null,
  delimeter : null,
  minimal : 0, /* xxx : qqq : cover */
}

//

function subphrasesForm()
{
  let self = this;

  if( self.subphraseMap )
  return;

  self.subphraseMap = Object.create( null );
  self.descriptorSet.forEach( ( phraseDescriptor ) =>
  {
    self._updateSubphraseMap({ phraseDescriptor, words : phraseDescriptor.words });
  });

}

//

function _updateSubphraseMap( o )
{
  let self = this;

  use( 0, 0 );

  for( let c = 1 ; c <= o.words.length ; c++ )
  {
    for( let w = 0 ; w <= o.words.length-c ; w++ )
    {
      use( w, c );
    }
  }

  return self;

  function use( w, c )
  {
    let selectedWords = o.words.slice( w, w+c );
    let selectedSubphrase = selectedWords.join( self.defaultDelimeter );

    if( o.oldDescriptor )
    {
      let i = _.longRightIndex( self.subphraseMap[ selectedSubphrase ], o.oldDescriptor, ( e ) => e.phrase, ( e ) => e.phrase ); /* xxx : use set */
      _.assert( i >= 0 );
      return;
    }

    let subphraseDescriptor = Object.create( null );

    subphraseDescriptor.phrase = o.phraseDescriptor.phrase;
    subphraseDescriptor.selectedSubphrase = selectedSubphrase;
    subphraseDescriptor.restSubphrase = self.subphraseRest( o.phraseDescriptor.phrase, selectedSubphrase );
    subphraseDescriptor.words = selectedWords;

    self.subphraseMap[ selectedSubphrase ] = _.arrayAs( self.subphraseMap[ selectedSubphrase ] || [] );
    self.subphraseMap[ selectedSubphrase ].push( subphraseDescriptor );
  }

}

_updateSubphraseMap.defaults =
{
  words : null,
  phraseDescriptor : null,
  oldDescriptor : null
}

// //
//
// function _updateSubphraseMap( o )
// {
//   let self = this;
//   let l = o.words.length;
//
//   _.routineOptions( _updateSubphraseMap, o );
//
//   if( self.subphraseMap === null )
//   self.subphraseMap = _.trie.make();
//
//   _.trie.addDeep
//   ({
//     root : self.subphraseMap,
//     path : o.words,
//     vals : [ o.phraseDescriptor ],
//     onVal,
//   });
//
//   function onVal( phraseDescriptor, op )
//   {
//     let selectedWords = o.words.slice( l - op.trace.length + 1, l );
//     let selectedSubphrase = selectedWords.join( self.defaultDelimeter );
//
//     let subphraseDescriptor = Object.create( null );
//     subphraseDescriptor.phrase = o.phraseDescriptor.phrase;
//     subphraseDescriptor.selectedSubphrase = selectedSubphrase;
//     subphraseDescriptor.restSubphrase = self.subphraseRest( o.phraseDescriptor.phrase, selectedSubphrase );
//     subphraseDescriptor.words = selectedWords;
//
//     console.log( `phrase : ${o.phraseDescriptor.phrase} selectedSubphrase : ${selectedSubphrase}. restSubphrase : ${subphraseDescriptor.restSubphrase}` ); debugger;
//
//     return subphraseDescriptor;
//   }
//
// }
//
// _updateSubphraseMap.defaults =
// {
//   words : null,
//   phraseDescriptor : null,
//   oldDescriptor : null
// }

//

/**
 * Removes subphrase from the phrase.
 * After subphrase removal routine replaces tabs with whitespaces and cuts off leading/trailing whitespaces.
 * If one of arguments is an Array, routine joins it into a String with whitespace as seperator.
 * If ( phrase ) was an Array and wasn't changed, it will be still returned as String.
 * @param {String|Array} phrase Source phrase or array of words to join into phrase.
 * @param {String|Array} subphrase Source subphrase or array of words to join into subphrase.
 * @returns {String} Returns adjusted phrase.
 *
 * @example
 * let vocabulary = new wVocabulary();
 * let phrase = 'deck properties';
 * let subphrase = 'properties';
 * let restSubphrase = vocabulary.subphraseRest( phrase, subphrase );
 * console.log( restSubphrase );
 * //deck
 *
 * @example
 * let vocabulary = new wVocabulary();
 * let phrase = [ 'deck', 'properties' ];
 * let subphrase = 'properties';
 * let restSubphrase = vocabulary.subphraseRest( phrase, subphrase );
 * console.log( restSubphrase );
 * //deck
 *
 * @example
 * let vocabulary = new wVocabulary();
 * let phrase = [ '  deck', 'properties  ' ];
 * let subphrase = 'some';
 * let strippedPhrase = vocabulary.subphraseRest( phrase, subphrase );
 * console.log( strippedPhrase );
 * //deck properties
 *
 * @method restSubphrase
 * @throws { Exception } Throw an exception if( phrase ) is not a String.
 * @throws { Exception } Throw an exception if( subphrase ) is not a String.
 * @class wVocabulary
 * @namespace wTools
 * @module Tools/mid/Vocabulary
 *
 */

function subphraseRest( phrase, subphrase )
{
  let self = this;

  if( _.arrayIs( phrase ) )
  phrase = phrase.join( self.defaultDelimeter );

  if( _.arrayIs( subphrase ) )
  subphrase = subphrase.join( self.defaultDelimeter );

  _.assert( _.strIs( phrase ) );
  _.assert( _.strIs( subphrase ) );

  if( subphrase )
  phrase = phrase.replace( subphrase, '' );

  let delimeter = _.arrayAs( self.delimeter ); /* xxx : optimize. use set */
  delimeter.forEach( ( del ) =>
  {
    phrase = _.strReplace( phrase, del + del, del );
    phrase = phrase.trim();
    phrase = _.strRemoveBegin( phrase, del );
    phrase = _.strRemoveEnd( phrase, del );
  });

  phrase = phrase.trim();

  return phrase;
}

// //
//
// /**
//  * @summary Filters array of `subphraseDescriptorArray` using selector `selector`.
//  * @param {Array} subphraseDescriptorArray Array of subphraseDescriptorArray.
//  * @param {Object} selector Selector for filter.
//  * @param {Object} selector.selectedSubphrase Part of targer phrase.
//  * @param {Object} selector.phrase Target phrase.
//  * @param {Object} selector.restSubphrase Subject of target phrase.
//  * @method subphraseDescriptorArrayFilter
//  * @throws { Exception } Throw an exception if arguments length is not equal 2.
//  * @returns {Array} Returns found subphraseDescriptorArray.
//  * @class wVocabulary
//  * @namespace wTools
//  * @module Tools/mid/Vocabulary
//  */
//
// function subphraseDescriptorArrayFilter( subphraseDescriptorArray, selector )
// {
//   let self = this;
//
//   _.assert( arguments.length === 2 );
//   _.assert( _.arrayIs( subphraseDescriptorArray ) );
//   _.map.assertHasOnly( selector, subphraseDescriptorArrayFilter.defaults );
//
//   if( selector.phrase )
//   selector.phrase = self.phraseAnalyzeTolerant({ phrase : selector.phrase }).phrase;
//   if( selector.selectedSubphrase )
//   selector.selectedSubphrase = self.phraseAnalyzeTolerant({ phrase : selector.selectedSubphrase }).phrase;
//   if( selector.restSubphrase )
//   selector.restSubphrase = self.phraseAnalyzeTolerant({ phrase : selector.restSubphrase }).phrase;
//
//   let _onEach = _._filter_functor( selector, 1 );
//   let result = _.filter_( null, subphraseDescriptorArray, _onEach );
//   return result;
// }
//
// subphraseDescriptorArrayFilter.defaults =
// {
//   selectedSubphrase : null,
//   phrase : null,
//   restSubphrase : null,
// }

// //
//
// function SubphraseInsidePhrase( subphrase, phrase )
// {
//
//   _.assert( _.arrayIs( phrase ) );
//   _.assert( _.arrayIs( subphrase ) );
//   _.assert( arguments.length === 2, 'Expects exactly two arguments' );
//
//   if( subphrase.length === 0 )
//   return true;
//   if( phrase.length === 0 )
//   return false;
//
//   let w = phrase.indexOf( subphrase[ 0 ] )
//   if( phrase.length - w < subphrase.length )
//   return false;
//
//   for( let i = w+1 ; i < w+subphrase.length ; i++ )
//   if( subphrase[ i-w ] !== phrase[ i ] )
//   return false;
//
//   return true;
// }

// --
// relations
// --

let Composes =
{

  onPhraseDescriptorFrom : _onPhraseDescriptorFromSimplest,
  onPhraseDescriptorIs : _onPhraseDescriptorIs,

  defaultDelimeter : null,
  delimeter : _.define.own([ '.', ' ' ]),
  overriding : 0,
  freezing : 1,

}

let Aggregates =
{
  descriptorSet : _.define.own( new Set ),
  phraseMap : _.define.own({}),
  wordMap : _.define.own({}),
  subphraseMap : null,
}

let Restricts =
{
  formed : 0,
}

let Statics =
{
  // SubphraseInsidePhrase,
}

let Accessors =
{
}

let Forbids =
{
  lookingDelimeter : 'lookingDelimeter',
  clausing : 'clausing',
  clauseForSubjectMap : 'clauseForSubjectMap',
  clauseMap : 'clauseMap',
  phraseArray : 'phraseArray',
}

// --
// declare
// --

let Proto =
{

  // inter

  init,
  preform,

  // phrase

  phrasesAdd,
  phraseAdd,
  _phraseAdd,
  _updateDescriptorSet,
  _updateWordMap,

  withPhrase,
  phraseParseNormal,
  phraseParseTolerant,
  phraseAnalyzeNormal,
  phraseAnalyzeTolerant,
  phraseAnalyze : phraseAnalyzeTolerant,
  phraseNormalize,

  _onPhraseDescriptorFromSimplest,
  _onPhraseDescriptorIs,

  // subphrase

  withSubphrase,
  subphrasesForm,
  _updateSubphraseMap,

  subphraseRest,
  // subphraseDescriptorArrayFilter,
  // SubphraseInsidePhrase,

  // relations

  Composes,
  Aggregates,
  Restricts,
  Statics,
  Accessors,
  Forbids,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.Copyable.mixin( Self );

// --
// export
// --

_global_[ Self.name ] = _[ Self.shortName ] = Self;
if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();

