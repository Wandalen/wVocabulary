(function _Vocabulary_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../dwtools/Base.s';
    let toolsExternal = 0;
    try
    {
      toolsPath = require.resolve( toolsPath );
    }
    catch( err )
    {
      toolsExternal = 1;
      require( 'wTools' );
    }
    if( !toolsExternal )
    require( toolsPath );
  }

  var _ = _global_.wTools;

  _.include( 'wCopyable' );

}

//

var _ = _global_.wTools;

/**
* Definitions :

*  word : : smallest part of a phrase( e.g., 'deck' ).
*  phrase : : combination of words with space as separator( e.g., 'deck properties' ).
*  subject : : a word or combination of it, used during search to determine if phrase is related to the subject.
*  clause : : a piece of a phrase( e.g. 'deck' is subphrase of 'deck properties' ).
*  phrase descriptor : : object that contains info about a phrase.


*/

/**
 * Class wVocabulary
 * @class wVocabulary
 */

/**
* Options object for wVocabulary constructor
* @typedef {Object} wVocabulary~wVocabularyOptions
* @property {function} [ onDescriptorMake ] - Creates descriptor based on data of the phrase. By default its a routine that wraps passed phrase into object.
* @property {boolean} [ override=0 ] - Controls overwriting of existing phrases.
* @property {boolean} [ usingClausing=0 ] -
* @property {boolean} [ usingFreeze=1 ] - Prevents future extensions of phrase descriptor.
*/

/**
* Containers of wVocabulary instance
* @typedef {Object} wVocabulary~wVocabularyMaps
* @property {Array} [ phraseArray ] - Contains available phrases.
* @property {Array} [ descriptorArray ] - Contains descriptors of available phrases.
* @property {Object} [ descriptorMap ] - Maps phrase with its descriptor.
* @property {Object} [ wordMap ] - Maps each word of the phrase with descriptors of phrases that contains it.
* @property {Object} [ subjectMap ] - Maps possible subjects with descriptors of phrases that contains it.
* @property {Object} [ clauseForSubjectMap ] - Maps subjects to clause.
* @property {Object} [ clauseMap ] - Maps possible subphrases( clause ) with descriptors of phrases that contains it.
*/

/**
 * Creates instance of wVocabulary
 * @example
   var vocabulary = new wVocabulary();

 * @example
   var o = { usingFreeze : 0 }
   var vocabulary = new wVocabulary( o );

 * @param {wVocabulary~wVocabularyOptions}[o] initialization options {@link wVocabulary~wVocabularyOptions}.
 * @returns {wVocabulary}
 * @constructor
 * @see {@link wVocabulary}
 */

var Parent = null;
var Self = function wVocabulary( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.nameShort = 'Vocabulary';

//

/**
 * Initialises instance of wVocabulary
 * @param {wVocabulary~wVocabularyOptions}[o] initialization options {@link wVocabulary~wVocabularyOptions}.
 * @private
 * @method init
 * @memberof wVocabulary#
 */

function init( o )
{
  var self = this;

  _.instanceInit( self );

  if( o )
  self.copy( o );

}

//

/**
 * Adds provided phrase(s) to the vocabulary.
 * Routine analyzes provided phrase(s) and creates descriptor for each phrase by calling ( wVocabulary.onDescriptorMake ) routine and complementing it with additional data.
 * Routine expects that result of ( wVocabulary.onDescriptorMake ) call will be an Object.
 * Data from descriptor is used to update containers of the vocabulary, see {@link wVocabulary~wVocabularyOptions} for details.
 * If phrases are provided in Array, they can have any type.
 * If ( wVocabulary.override ) is enabled, existing phrase can be rewritten by new one.
 * @param {String|Array} src - Source phrase or array of phrases.
 * @returns {wVocabulary} Returns wVocabulary instance.
 *
 * @example
 * var vocabulary = new wVocabulary();
 * var phrase = 'deck properties';
 * vocabulary.phrasesAdd( phrases );
 * console.log( _.toStr( vocabulary, { levels : 99 } ) )
 *
 * @example
 * var vocabulary = new wVocabulary();
 * var phrases =
 * [
 *  'deck properties',
 *  'deck about'
 * ];
 * vocabulary.phrasesAdd( phrases );
 * console.log( _.toStr( vocabulary, { levels : 99 } ) )
 *
 * @method phrasesAdd
 * @throws { Exception } Throw an exception if more than one argument is provided.
 * @throws { Exception } Throw an exception if ( src ) is not a String or Array.
 * @throws { Exception } Throw an exception if ( descriptor ) made by ( onDescriptorMake ) routine is not an Object.
 * @throws { Exception } Throw an exception if ( src ) is an empty phrase.
 * @throws { Exception } Throw an exception if phrase ( src ) already exists and ( wVocabulary.override ) is disabled.
 * @memberof wVocabulary
 *
 */

function phrasesAdd( src )
{
  var self = this;

  _.assert( _.strIs( src ) || _.arrayIs( src ),'phrasesAdd expects string or array' );
  _.assert( arguments.length === 1 );

  var vocabulary = self._phrasesAdd( src );
  return vocabulary;
}

//

function _phrasesAdd( src )
{
  var self = this;
  var vocabulary = this;
  var replaceDescriptor = null;

  _.assert( arguments.length === 1 );

  //var vocabulary = o.vocabulary;
  /*_.assert( _.strIs( src ) || _.arrayIs( src ) );*/

  if( _.arrayIs( src ) )
  {
    for( var s = 0 ; s < src.length ; s++ )
    self._phrasesAdd( src[ s ] );
    return self;
  }

  var descriptor = self.onDescriptorMake( src );
  var words = descriptor.words = _.strSplit( descriptor.phrase );
  var phrase = descriptor.phrase = descriptor.words.join( ' ' );

  if( !_.objectIs( descriptor ) )
  throw _.err( 'phrase descriptor should be object' );

  if( !phrase )
  throw _.err( 'empty phrase' );

  //

  if( self.descriptorMap[ phrase ] )
  {

    //throw _.err( 'not implemented' ); // !!!
    //logger.warn( 'not implemented' );

    if( !descriptor.override && !self.override )
    throw _.err( 'phrase override :',descriptor.phrase );

    //var i = self.descriptorArray.indexOf( self.descriptorMap[ phrase ] );
    //_.assert( i !== -1 );

    replaceDescriptor = self.descriptorMap[ phrase ];

/*
    if( o.usingNounVerb )
    {
      descriptor.noun = replaceDescriptor.noun;
      descriptor.verb = replaceDescriptor.verb;
    }
*/
/*
    if( o.usingClausing )
    {
      descriptor.clauseLimit = replaceDescriptor.clauseLimit;
      descriptor.clauses = replaceDescriptor.clauses;
    }
*/

    //return self;
  }

/*
  phraseArray : [],
  descriptorArray : [],
  descriptorMap : {},

  wordMap : {},
  subjectMap : {},

  clauseForSubjectMap : {},
  clauseMap : {},
*/

  //

  self.descriptorMap[ phrase ] = descriptor;

  if( replaceDescriptor )
  {

    _.arrayReplaceOnceStrictly( self.descriptorArray,replaceDescriptor,descriptor );

  }
  else
  {

    self.phraseArray.push( phrase );
    self.descriptorArray.push( descriptor );

  }

  //

  self._updateWordMap( descriptor,words,phrase,replaceDescriptor );
  self._updateSubjectMap( descriptor,words,phrase,replaceDescriptor );
  self._updateClauseMap( descriptor,words,phrase,replaceDescriptor );

  // freeze

  if( self.usingFreeze )
  Object.preventExtensions( descriptor );

  return self;
}

//

function _updateWordMap( descriptor,words,phrase,replaceDescriptor )
{
  var self = this;

  for( var w = 0 ; w < words.length ; w++ )
  {
    var word = words[ w ];
    self.wordMap[ word ] = _.arrayAs( self.wordMap[ word ] );

    if( replaceDescriptor )
    {
      _.arrayReplaceOnceStrictly( self.wordMap[ word ],replaceDescriptor,descriptor );
    }
    else
    {
      self.wordMap[ word ].push( descriptor );
    }

  }

  return self;
}

//

function _updateSubjectMap( descriptor,words,phrase,replaceDescriptor )
{
  var self = this;

  /*self.subjectMap[ '' ].push({ descriptor : descriptor });*/

  for( var c = 1 ; c <= words.length ; c++ )
  {

    for( var w = 0 ; w <= words.length-c ; w++ )
    {

      var sliceWords = words.slice( w,w+c );
      var slicePhrase = sliceWords.join( ' ' );

      if( replaceDescriptor )
      {
        var i = _.arrayLeftIndexOf( self.subjectMap[ slicePhrase ],replaceDescriptor,function( a ){ return a.descriptor; } );
        _.assert( i >= 0 );
        self.subjectMap[ slicePhrase ][ i ].descriptor = descriptor;
        return;
      }

      var slice = {};

      slice.words = sliceWords;
      slice.phrase = slicePhrase;
      slice.subPhrase = self.subPhrase( descriptor.phrase,slice.phrase );
      slice.descriptor = descriptor;
      slice.kind = 'subject';

      self.subjectMap[ slice.phrase ] = _.arrayAs( self.subjectMap[ slice.phrase ] );
      self.subjectMap[ slice.phrase ].push( slice );

    }

  }

  return self;
}

//

function _updateClauseMap( descriptor,words,phrase,replaceDescriptor )
{
  var self = this;

  // clausing

  // project create
  // project open form catalog
  // project open form files

  // project create
  // project open

  // debugger

  if( !self.usingClausing )
  return;

  if( descriptor.clauseLimit === null )
  descriptor.clauseLimit = [ 1,+Infinity ];
  else if( _.numberIs( descriptor.clauseLimit ) )
  descriptor.clauseLimit = [ 1,descriptor.clauseLimit ];
  else if( !_.arrayIs( descriptor.clauseLimit ) )
  throw _.err( 'expects clauseLimit as number or array' );

  _.assert( descriptor.clauseLimit[ 0 ] >= 1 );

  function dequalizer( a,b ){ return a.descriptor === b };

  var clauseLength = 0;
  var maxClauseLength = Math.min( words.length,descriptor.clauseLimit[ 1 ] );
  for( clauseLength = maxClauseLength ; clauseLength >= descriptor.clauseLimit[ 0 ] ; clauseLength-- )
  {

    for( var w = 0 ; w <= words.length-clauseLength ; w++ )
    {

      var subjectLength = clauseLength - 1;
      var subjectWords = words.slice( w,w+subjectLength );
      var subjectPhrase = subjectWords.join( ' ' );

      var clauseWords = words.slice( w,w+clauseLength );
      var clausePhrase = clauseWords.join( ' ' );
      var clause = self.clauseMap[ clausePhrase ];

      var subject = self.subjectMap[ clausePhrase ];
      subject = _.entityFilter( subject, function( e )
      {
        if( e.descriptor.words.length === clauseLength )
        return;
        if( e.descriptor.clauseLimit[ 0 ] <= clauseLength && clauseLength <= e.descriptor.clauseLimit[ 1 ] )
        return e.descriptor;
      });

      if( subject.length < 2 )
      continue;

      if( clause )
      {

        _.assert( descriptor.phrase.indexOf( clause.phrase ) !== -1 );

        if( replaceDescriptor )
        {
          var i = _.arrayUpdate( clause.descriptors,replaceDescriptor,descriptor );
          _.assert( i >= 0 );
        }
        else
        {
          clause.descriptors.push( descriptor );
        }

        continue;
      }

      var clause = {};
      clause.words = clauseWords;
      clause.phrase = clausePhrase;
      clause.subjectWords = subjectWords;
      clause.subjectPhrase = subjectPhrase;
      clause.subPhrase = self.subPhrase( clausePhrase,subjectPhrase );

      clause.descriptor = clause;
      clause.descriptors = subject;
      clause.kind = 'clause';

      _.assert( !self.clauseMap[ clausePhrase ] );

      self.clauseForSubjectMap[ subjectPhrase ] = _.arrayAs( self.clauseForSubjectMap[ subjectPhrase ] );
      self.clauseForSubjectMap[ subjectPhrase ].push( clause )
      self.clauseMap[ clausePhrase ] = clause;

    }

  }

  return self;
}

//

/**
 * Removes subject from the phrase.
 * After subject removal routine replaces tabs with whitespaces and cuts off leading/trailing whitespaces.
 * If one of arguments is an Array, routine joins it into a String with whitespace as seperator.
 * If ( phrase ) was an Array and wasn't changed, it will be still returned as String.
 * @param {String|Array} phrase - Source phrase or array of words to join into phrase.
 * @param {String|Array} subject - Source subject or array of words to join into subject.
 * @returns {String} Returns adjusted phrase.
 *
 * @example
 * var vocabulary = new wVocabulary();
 * var phrase = 'deck properties';
 * var subject = 'properties';
 * var subPhrase = vocabulary.subPhrase( phrase, subject );
 * console.log( subPhrase );
 * //deck
 *
 * @example
 * var vocabulary = new wVocabulary();
 * var phrase = [ 'deck', 'properties' ];
 * var subject = 'properties';
 * var subPhrase = vocabulary.subPhrase( phrase, subject );
 * console.log( subPhrase );
 * //deck
 *
 * @example
 * var vocabulary = new wVocabulary();
 * var phrase = [ '  deck', 'properties  ' ];
 * var subject = 'xxx';
 * var strippedPhrase = vocabulary.subPhrase( phrase, subject );
 * console.log( strippedPhrase );
 * //deck properties
 *
 * @method subPhrase
 * @throws { Exception } Throw an exception if( phrase ) is not a String.
 * @throws { Exception } Throw an exception if( subject ) is not a String.
 * @memberof wVocabulary
 *
 */

function subPhrase( phrase,subject )
{

  if( _.arrayIs( phrase ) )
  phrase = phrase.join( ' ' );

  if( _.arrayIs( subject ) )
  subject = subject.join( ' ' );

  _.assert( _.strIs( phrase ) );
  _.assert( _.strIs( subject ) );

  phrase = phrase.replace( subject,'' );
  phrase = phrase.replace( '  ',' ' );
  phrase = _.strStrip( phrase );

  return phrase;
}

//

/**
 * Searchs for phrase that has subject( subject ) and returns them in Array.
 * If ( subject ) is an Array, routine joins it into a String with whitespace as seperator.
 * If no phrases found - routine returns an empty Array.
 * If ( subject ) is an empty String - routine returns an Array of available phrases, some phrases can be grouped by their clause.
 * @param {String|Array} subject - Source phrase or array of words to join into phrase.
 * @param {Boolean} usingClausing -
 * @returns {Array} Returns found phrases in Array.
 *
 * @example
 * var vocabulary = new wVocabulary();
 * var phrases =
 * [
 *  'deck properties',
 *  'deck about',
 *  'project about',
 * ];
 * vocabulary.phrasesAdd( phrases );
 * var subject = 'deck';
 * var result = vocabulary.phrasesForSubject( subject );
 * console.log( _.toStr( result, { levels : 3 } ) );
 *
 * @method phrasesForSubject
 * @throws { Exception } Throw an exception if no arguments provided.
 * @throws { Exception } Throw an exception if more than two arguments provided.
 * @throws { Exception } Throw an exception if( wVocabulary.wordMap ) is not a Object.
 * @throws { Exception } Throw an exception if( subject ) is not a String or Array.
 * @memberof wVocabulary
 *
 */

function phrasesForSubject( subject,usingClausing )
{
  var self = this;
  var result = [];
  var added = [];
  var usingClausing = usingClausing !== undefined ? usingClausing : self.usingClausing;

  _.assert( _.mapIs( self.wordMap ) );
  _.assert( _.strIs( subject ) || _.arrayIs( subject ) );
  _.assert( arguments.length === 1 || arguments.length === 2 );

  var subjectWords = _.arrayIs( subject ) ? subject : _.strSplit( subject );
  var subjectPhrase = subjectWords.join( ' ' );
  var subject = self.subjectMap[ subjectPhrase ] || [];

  if( subjectPhrase === '' )
  {
    subject = _.entityMap( self.descriptorArray,function( e )
    {
      return { descriptor : e, phrase : e.phrase, words : e.words };
    });
  }

/*
  if( !subject.length && subjectPhrase === '' )
  {
    debugger;
    result = self.descriptorArray.slice();
    var clauses = _.entityFilter( self.clauseForSubjectMap,function( e ){ if( e.subjectWords.length === 1 ) return e; } );
    for( var c in clauses )
    _.arrayRemoveArrayOnce( result,clauses[ c ].descriptors );
    result = _.entityMap( result,function( e ){ return { descriptor : e } } );
    clauses = _.entityMap( clauses,function( e )
    {
      var result = { descriptors : e.descriptors, words : e.subjectWords, phrase : e.subjectPhrase, kind : 'forSubject' };
      result.descriptor = result;
      return result;
    });
    _.arrayAppendArray( result,_.mapVals( clauses ) );
    return result;
  }
*/

  if( !usingClausing || !self.clauseForSubjectMap[ subjectPhrase ] )
  return subject;

  /* */

  var clauses = self.clauseForSubjectMap[ subjectPhrase ];

  if( clauses.length === 1 && clauses[ 0 ].descriptors.length === subject.length )
  return subject;

  _.arrayAppendArray( result,clauses );
  var added = _.arrayFlatten( [],_.entitySelect( clauses,'*.descriptors' ) );

  for( var s = 0 ; s < subject.length ; s++ )
  if( added.indexOf( subject[ s ].descriptor ) === -1 )
  result.push( subject[ s ] );

  return result;
}

//

/**
 * Generate help string(s) for phrase(s) found by using ( subject ) as query.
 * If no phrase(s) found returns an empty String.
 * If phrase descriptor has 'hint' propery defined, routine uses it, otherwise inserts capitalized phrase literal.
 * Returns generated strings in Array.
 * @param {String|Array} subject - Source phrase or array of words to join into phrase.
 * @param {Boolean} usingClausing -
 * @returns {Array} Returns found phrases in Array.
 *
 * @example
 * var vocabulary = new wVocabulary();
 * var phrases =
 * [
 *  'deck properties',
 *  'deck about',
 *  'project about',
 * ];
 * vocabulary.phrasesAdd( phrases );
 * var subject = 'deck';
 * var result = vocabulary.helpForSubject( subject );
 * console.log( result );
 * //[ '.deck.properties - Deck properties.', '.deck.about - Deck about.' ]
 *
 * @method helpForSubject
 * @throws { Exception } Throw an exception if no arguments provided.
 * @throws { Exception } Throw an exception if more than two arguments provided.
 * @throws { Exception } Throw an exception if( wVocabulary.wordMap ) is not a Object.
 * @throws { Exception } Throw an exception if( subject ) is not a String or Array.
 * @memberof wVocabulary
 *
 */

function helpForSubject( subject,usingClausing )
{
  var self = this;

  var actions = self.phrasesForSubject( subject,usingClausing );

  if( !actions.length )
  return '';

  var part1 = actions.map( function( e ){ return e.descriptor.words.join( '.' ); } );
  var part2 = actions.map( function( e ){ return e.descriptor.hint || _.strCapitalize( e.descriptor.phrase + '.' ); });

  var help = _.strJoin( '.',part1,' - ',part2 );

  return help;
}

//

function wordsComplySubject( words,subject )
{
  var result = [];

  debugger
  _.assert( _.arrayIs( words ) );
  _.assert( _.arrayIs( subject ) );
  _.assert( arguments.length === 2 );

  if( subject.length === 0 ) return true;
  if( words.length === 0 ) return false;

  var w = words.indexOf( subject[ 0 ] )
  if( words.length - w < subject.length )
  return false;

  for( var i = w+1 ; i < w+subject.length ; i++ )
  if( subject[ i-w ] !== words[ i ] )
  return false;

  return true;
}

// --
// relationships
// --

var Composes =
{

  onDescriptorMake : function( src ){ return { phrase : src }; },
  override : 0,
  usingClausing : 0,
  usingFreeze : 1,

}

var Aggregates =
{

  phraseArray : [],
  descriptorArray : [],

  descriptorMap : {},
  wordMap : {},
  subjectMap : {},

  clauseForSubjectMap : {},
  clauseMap : {},

}

var Restricts =
{
}

// --
// proto
// --

var Proto =
{

  init : init,

  phrasesAdd : phrasesAdd,
  _phrasesAdd : _phrasesAdd,

  _updateWordMap : _updateWordMap,
  _updateSubjectMap : _updateSubjectMap,
  _updateClauseMap : _updateClauseMap,

  subPhrase : subPhrase,

  phrasesForSubject : phrasesForSubject,
  helpForSubject : helpForSubject,

  wordsComplySubject : wordsComplySubject,

  // relationships

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Restricts : Restricts,

}

//

_.classMake
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.Copyable.mixin( Self );

// --
// export
// --

_global_[ Self.name ] = _[ Self.nameShort ] = Self;

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
