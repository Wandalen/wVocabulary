( function _Vocabulary_s_()
{

'use strict';

/**
 * Class to operate phrases. A phrase consists of words. Vocabulary enables the design of CLI based on phrases instead of words. It makes possible to group several similar phrases and help a user learn CLI faster. Use it to make your CLI more user-friendly.
  @module Tools/mid/Vocabulary
*/

/**
 *  */

if( typeof module !== 'undefined' )
{
  let _ = require( '../../../../wtools/Tools.s' );
  _.include( 'wCopyable' );
}

//

let _ = _global_.wTools;

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
* @property {function} [ onPhraseDescriptorMake ] Creates phraseDescriptor based on data of the phrase. By default its a routine that wraps passed phrase into object.
* @property {boolean} [ overriding=0 ] Controls overwriting of existing phrases.
* @property {boolean} [ clausing=0 ]
* @property {boolean} [ freezing=1 ] Prevents future extensions of phrase phraseDescriptor.
* @class wVocabulary
* @module Tools/mid/Vocabulary
*/

/**
* Containers of wVocabulary instance
* @typedef {Object} wVocabularyMaps
* @property {Array} [ phraseArray ] Contains available phrases.
* @property {Array} [ descriptorArray ] Contains descriptors of available phrases.
* @property {Object} [ descriptorMap ] Maps phrase with its phraseDescriptor.
* @property {Object} [ wordMap ] Maps each word of the phrase with descriptors of phrases that contains it.
* @property {Object} [ subjectMap ] Maps possible subjects with descriptors of phrases that contains it.
* @property {Object} [ clauseForSubjectMap ] Maps subjects to clause.
* @property {Object} [ clauseMap ] Maps possible subphrases( clause ) with descriptors of phrases that contains it.
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

let Parent = null;
let Self = wVocabulary;
function wVocabulary( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'Vocabulary';

//

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

  self.form();
}

//

function form()
{
  let self = this;

  if( self.addingDelimeterDefault === null )
  self.addingDelimeterDefault = _.arrayAs( self.addingDelimeter )[ 0 ]

  return self;
}

//

/**
 * Shrort-cut for {@link module:Tools/mid/Vocabulary.wVocabulary#phraseAdd wVocabulary.phraseAdd} method.
 * @description
 * Adds provided phrase(s) to the vocabulary.
 * Routine analyzes provided phrase(s) and creates phraseDescriptor for each phrase by calling ( wVocabulary.onPhraseDescriptorMake ) routine and complementing it with additional data.
 * Routine expects that result of ( wVocabulary.onPhraseDescriptorMake ) call will be an Object.
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
 * console.log( _.toStr( vocabulary, { levels : 99 } ) )
 *
 * @example
 * let vocabulary = new wVocabulary();
 * let phrases =
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
 * @throws { Exception } Throw an exception if ( phraseDescriptor ) made by ( onPhraseDescriptorMake ) routine is not an Object.
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
  let replaceDescriptor = null;

  _.assert( _.strIs( src ) || _.containerIs( src ), 'Expects string or array' );
  _.assert( arguments.length === 1, 'Expects single argument' );

  if( _.arrayIs( src ) )
  _.each( src, ( e, k ) =>
  {
    self.phraseAdd( e );
  });
  else if( _.objectIs( src ) )
  _.each( src, ( e, k ) =>
  {
    self.phraseAdd( [ k, e ] );
  });
  else
  {
    self.phraseAdd( src );
  }

  return self;
}

//

/**
 * @summary Adds provided phraseto the vocabulary.
 * Routine analyzes provided phrase and creates phraseDescriptor for each phrase by calling ( wVocabulary.onPhraseDescriptorMake ) routine and complementing it with additional data.
 * Routine expects that result of ( wVocabulary.onPhraseDescriptorMake ) call will be an Object.
 * Data from phraseDescriptor is used to update containers of the vocabulary, see {@link module:Tools/mid/Vocabulary.wVocabulary~wVocabularyOptions} for details.
 * If ( wVocabulary.overriding ) is enabled, existing phrase can be rewritten by new one.
 * @param {String} src Source phrase or array of phrases.
 * @returns {wVocabulary} Returns `wVocabulary` instance.
 *
 * @example
 * let vocabulary = new wVocabulary();
 * let phrase = 'deck properties';
 * vocabulary.phraseAdd( phrase );
 * console.log( _.toStr( vocabulary, { levels : 99 } ) )
 *
 * @method phraseAdd
 * @throws { Exception } Throw an exception if more than one argument is provided.
 * @throws { Exception } Throw an exception if ( src ) is not a String.
 * @throws { Exception } Throw an exception if ( phraseDescriptor ) made by ( onPhraseDescriptorMake ) routine is not an Object.
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
  let replaceDescriptor = null;
  let phraseDescriptor = self.onPhraseDescriptorMake( src );
  let words = phraseDescriptor.words = _.strSplitNonPreserving
  ({
    src : phraseDescriptor.phrase,
    delimeter : self.addingDelimeter
  });
  let phrase = phraseDescriptor.phrase = phraseDescriptor.words.join( self.addingDelimeterDefault );

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.strsAreAll( self.addingDelimeter ) );
  _.assert( _.objectIs( phraseDescriptor ), 'phrase phraseDescriptor should be object' );
  _.assert( _.strIs( phrase ), 'empty phrase' );

  /* */

  if( self.descriptorMap[ phrase ] )
  {

    _.assert( phraseDescriptor.override || self.overriding, 'phrase overriding :', phraseDescriptor.phrase );

    replaceDescriptor = self.descriptorMap[ phrase ];

    /*
    if( o.usingNounVerb )
    {
      phraseDescriptor.noun = replaceDescriptor.noun;
      phraseDescriptor.verb = replaceDescriptor.verb;
    }
*/
    /*
    if( o.clausing )
    {
      phraseDescriptor.clauseLimit = replaceDescriptor.clauseLimit;
      phraseDescriptor.clauses = replaceDescriptor.clauses;
    }
*/

    //return self;
  }

  /* */

  self.descriptorMap[ phrase ] = phraseDescriptor;

  if( replaceDescriptor )
  {

    _.arrayReplaceOnceStrictly( self.descriptorArray, replaceDescriptor, phraseDescriptor );

  }
  else
  {

    self.phraseArray.push( phrase );
    self.descriptorArray.push( phraseDescriptor );

  }

  /* */

  self._updateWordMap({ phraseDescriptor, words, replaceDescriptor });
  self._updateSubjectMap({ phraseDescriptor, words, replaceDescriptor });
  self._updateClauseMap({ phraseDescriptor, words, replaceDescriptor });

  /* freeze */

  if( self.freezing )
  Object.preventExtensions( phraseDescriptor );

  return self;
}

//

function _updateWordMap( o )
{
  let self = this;

  _.routineOptions( _updateWordMap, o );

  for( let w = 0 ; w < o.words.length ; w++ )
  {
    let word = o.words[ w ];
    self.wordMap[ word ] = _.arrayAs( self.wordMap[ word ] || [] );

    if( o.replaceDescriptor )
    {
      _.arrayReplaceOnceStrictly( self.wordMap[ word ], o.replaceDescriptor, o.phraseDescriptor );
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
  replaceDescriptor : null
}

//

function _updateSubjectMap( o )
{
  let self = this;

  _.routineOptions( _updateSubjectMap, o );

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
    let sliceWords = o.words.slice( w, w+c );
    let slicePhrase = sliceWords.join( self.addingDelimeterDefault );

    if( o.replaceDescriptor )
    {
      let i = _.longRightIndex( self.subjectMap[ slicePhrase ], o.replaceDescriptor, ( e ) => e.phraseDescriptor, ( e ) => e );
      _.assert( i >= 0 );
      self.subjectMap[ slicePhrase ][ i ].phraseDescriptor = o.phraseDescriptor;
      return;
    }

    let subject = Object.create( null );

    subject.words = sliceWords;
    subject.slicePhrase = slicePhrase;
    subject.wholePhrase = o.phraseDescriptor.phrase;
    subject.subPhrase = self.subPhrase( o.phraseDescriptor.phrase, slicePhrase );
    subject.phraseDescriptor = o.phraseDescriptor;
    subject.kind = 'subject';

    _.accessor.forbid( subject, 'phrase' );

    self.subjectMap[ slicePhrase ] = _.arrayAs( self.subjectMap[ slicePhrase ] || [] );
    self.subjectMap[ slicePhrase ].push( subject );
  }

}

_updateSubjectMap.defaults =
{
  phraseDescriptor : null,
  words : null,
  replaceDescriptor : null
}

//

function _updateClauseMap( o )
{
  let self = this;

  // clausing

  // project create
  // project open form catalog
  // project open form files

  // project create
  // project open

  // debugger

  if( !self.clausing )
  return;

  _.routineOptions( _updateSubjectMap, o );

  if( o.phraseDescriptor.clauseLimit === null )
  o.phraseDescriptor.clauseLimit = [ 1, +Infinity ];
  else if( _.numberIs( o.phraseDescriptor.clauseLimit ) )
  o.phraseDescriptor.clauseLimit = [ 1, o.phraseDescriptor.clauseLimit ];
  else if( !_.arrayIs( o.phraseDescriptor.clauseLimit ) )
  _.assert( 0, 'Expects clauseLimit as number or array' );

  _.assert( o.phraseDescriptor.clauseLimit[ 0 ] >= 1 );

  function dequalizer( a, b ){ return a.phraseDescriptor === b };

  let clauseLength = 0;
  let maxClauseLength = Math.min( o.words.length, o.phraseDescriptor.clauseLimit[ 1 ] );
  for( clauseLength = maxClauseLength ; clauseLength >= o.phraseDescriptor.clauseLimit[ 0 ] ; clauseLength-- )
  {

    for( let w = 0 ; w <= o.words.length-clauseLength ; w++ )
    {

      let subjectLength = clauseLength - 1;
      let subjectWords = o.words.slice( w, w+subjectLength );
      let subjectPhrase = subjectWords.join( self.addingDelimeterDefault );

      let clauseWords = o.words.slice( w, w+clauseLength );
      let clausePhrase = clauseWords.join( self.addingDelimeterDefault );
      let clause = self.clauseMap[ clausePhrase ];

      let subject = self.subjectMap[ clausePhrase ];
      subject = _.entityFilter( subject, function( e )
      {
        if( e.phraseDescriptor.words.length === clauseLength )
        return;
        if( e.phraseDescriptor.clauseLimit[ 0 ] <= clauseLength && clauseLength <= e.phraseDescriptor.clauseLimit[ 1 ] )
        return e.phraseDescriptor;
      } );

      if( subject.length < 2 )
      continue;

      if( clause )
      {

        _.assert( o.phraseDescriptor.phrase.indexOf( clause.phrase ) !== -1 );

        if( o.replaceDescriptor )
        {
          let i = _.arrayUpdate( clause.descriptors, o.replaceDescriptor, o.phraseDescriptor );
          _.assert( i >= 0 );
        }
        else
        {
          clause.descriptors.push( o.phraseDescriptor );
        }

        continue;
      }

      clause = Object.create( null );
      clause.words = clauseWords;
      clause.phrase = clausePhrase;
      clause.subjectWords = subjectWords;
      clause.subjectPhrase = subjectPhrase;
      clause.subPhrase = self.subPhrase( clausePhrase, subjectPhrase );

      clause.phraseDescriptor = clause;
      clause.descriptors = subject;
      clause.kind = 'clause';

      _.assert( !self.clauseMap[ clausePhrase ] );

      debugger;
      self.clauseForSubjectMap[ subjectPhrase ] = _.arrayAs( self.clauseForSubjectMap[ subjectPhrase ] || [] );
      self.clauseForSubjectMap[ subjectPhrase ].push( clause )
      self.clauseMap[ clausePhrase ] = clause;

    }

  }

  return self;
}

_updateClauseMap.defaults =
{
  phraseDescriptor : null,
  words : null,
  replaceDescriptor : null
}

//

/**
 * Removes subject from the phrase.
 * After subject removal routine replaces tabs with whitespaces and cuts off leading/trailing whitespaces.
 * If one of arguments is an Array, routine joins it into a String with whitespace as seperator.
 * If ( phrase ) was an Array and wasn't changed, it will be still returned as String.
 * @param {String|Array} phrase Source phrase or array of words to join into phrase.
 * @param {String|Array} subject Source subject or array of words to join into subject.
 * @returns {String} Returns adjusted phrase.
 *
 * @example
 * let vocabulary = new wVocabulary();
 * let phrase = 'deck properties';
 * let subject = 'properties';
 * let subPhrase = vocabulary.subPhrase( phrase, subject );
 * console.log( subPhrase );
 * //deck
 *
 * @example
 * let vocabulary = new wVocabulary();
 * let phrase = [ 'deck', 'properties' ];
 * let subject = 'properties';
 * let subPhrase = vocabulary.subPhrase( phrase, subject );
 * console.log( subPhrase );
 * //deck
 *
 * @example
 * let vocabulary = new wVocabulary();
 * let phrase = [ '  deck', 'properties  ' ];
 * let subject = 'some';
 * let strippedPhrase = vocabulary.subPhrase( phrase, subject );
 * console.log( strippedPhrase );
 * //deck properties
 *
 * @method subPhrase
 * @throws { Exception } Throw an exception if( phrase ) is not a String.
 * @throws { Exception } Throw an exception if( subject ) is not a String.
 * @class wVocabulary
 * @namespace wTools
 * @module Tools/mid/Vocabulary
 *
 */

function subPhrase( phrase, subject )
{
  let self = this;

  if( _.arrayIs( phrase ) )
  phrase = phrase.join( self.addingDelimeterDefault );

  if( _.arrayIs( subject ) )
  subject = subject.join( self.addingDelimeterDefault );

  _.assert( _.strIs( phrase ) );
  _.assert( _.strIs( subject ) );

  if( subject )
  phrase = phrase.replace( subject, '' );

  let addingDelimeter = _.arrayAs( self.addingDelimeter );
  addingDelimeter.forEach( ( del ) =>
  {
    phrase = _.strReplace( phrase, del + del, del );
    phrase = phrase.trim();
    phrase = _.strRemoveBegin( phrase, del );
    phrase = _.strRemoveEnd( phrase, del );
  });

  phrase = phrase.trim();

  return phrase;
}

//

/**
 * @summary Returns subject descriptor for phrase.
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
 * let descriptor = vocabulary.subjectDescriptorFor({ phrase : phrase });
 * console.log( descriptor );
 *
 * @method subjectDescriptorFor
 * @throws { Exception } Throw an exception if more than one argument is provided.
 * @throws { Exception } Throw an exception if ( src ) is not a String.
 * @throws { Exception } Throw an exception if found more than one descriptor with `o.exact` enabled.
 * @class wVocabulary
 * @namespace wTools
 * @module Tools/mid/Vocabulary
 */

function subjectDescriptorFor( o )
{
  let self = this;
  let result = [];
  let added = [];

  if( !_.objectIs( o ) )
  o = { phrase : arguments[ 0 ] };

  _.assert( _.mapIs( self.wordMap ) );
  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.routineOptions( subjectDescriptorFor, o );

  let parsed = self.phraseParse({ phrase : o.phrase, delimeter : o.delimeter });

  result = self.subjectMap[ parsed.phrase ] || [];

  if( o.exact )
  {
    result = result.filter( ( e ) =>
    {
      if( e.phraseDescriptor.phrase === parsed.phrase )
      return e;
    } );
    _.assert( result.length <= 1 );
    return result[ 0 ];
  }

  return result;
}

subjectDescriptorFor.defaults =
{
  phrase : null,
  delimeter : null,
  exact : 0,
}

//

/**
 * Searchs for phrase that has subject( subject ) and returns them in Array.
 * If ( subject ) is an Array, routine joins it into a String with whitespace as seperator.
 * If no phrases found - routine returns an empty Array.
 * If ( subject ) is an empty String - routine returns an Array of available phrases, some phrases can be grouped by their clause.
 * @param {String|Array} subject - Source phrase or array of words to join into phrase.
 * @param {Boolean} clausing -
 * @returns {Array} Returns found phrases in Array.
 *
 * @example
 * let vocabulary = new wVocabulary();
 * let phrases =
 * [
 *  'deck properties',
 *  'deck about',
 *  'project about',
 * ];
 * vocabulary.phrasesAdd( phrases );
 * let subject = 'deck';
 * let result = vocabulary.subjectDescriptorForWithClause( subject );
 * console.log( _.toStr( result, { levels : 3 } ) );
 *
 * @method subjectDescriptorForWithClause
 * @throws { Exception } Throw an exception if no arguments provided.
 * @throws { Exception } Throw an exception if more than two arguments provided.
 * @throws { Exception } Throw an exception if( wVocabulary.wordMap ) is not a Object.
 * @throws { Exception } Throw an exception if( subject ) is not a String or Array.
 * @class wVocabulary
 * @namespace wTools
 * @module Tools/mid/Vocabulary
 *
 */

function subjectDescriptorForWithClause( o )
{
  let self = this;
  let result = [];
  let added = [];

  if( !_.objectIs( o ) )
  o = { phrase : arguments[ 0 ], clausing : arguments[ 1 ] };

  _.assert( _.mapIs( self.wordMap ) );
  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.routineOptions( subjectDescriptorForWithClause, o );

  o.clausing = o.clausing === null ? self.clausing : o.clausing;

  let parsed = self.phraseParse({ phrase : o.phrase, delimeter : o.delimeter });

  let subject = self.subjectMap[ parsed.phrase ] || [];

  if( !o.clausing || !self.clauseForSubjectMap[ parsed.phrase ] )
  return subject;

  let clauses = self.clauseForSubjectMap[ parsed.phrase ];

  if( clauses.length === 1 && clauses[ 0 ].descriptors.length === subject.length )
  return subject;

  _.arrayAppendArray( result, clauses );
  added = _.arrayFlatten( [], _.select( clauses, '*/descriptors' ) );

  for( let s = 0 ; s < subject.length ; s++ )
  if( added.indexOf( subject[ s ].phraseDescriptor ) === -1 )
  result.push( subject[ s ] );

  return result;
}

subjectDescriptorForWithClause.defaults =
{
  phrase : null,
  clausing : null,
  delimeter : null,
}

//

function helpForSubject_head( routine, args )
{
  let self = this;

  let o = args[ 0 ];

  if( !_.objectIs( o ) )
  o = { phrase : args[ 0 ], clausing : args[ 1 ] };

  _.assert( arguments.length === 2 );
  _.assert( args.length === 1 || args.length === 2 );
  _.routineOptions( routine, o );

  return o;
}

//

/**
 * Generate help string(s) for phrase(s) found by using ( subject ) as query.
 * Tries to find exact match of phrase first, then looks for phrase using `o.clausing`.
 * If no phrase(s) found returns an empty String.
 * If phrase phraseDescriptor has 'hint' propery defined, routine uses it, otherwise inserts capitalized phrase literal.
 * Returns generated strings in Array.
 * @param {String|Array} subject - Source phrase or array of words to join into phrase.
 * @param {Boolean} clausing -
 * @returns {Array} Returns found phrases in Array.
 *
 * @example
 * let vocabulary = new wVocabulary();
 * let phrases =
 * [
 *  'deck properties',
 *  'deck about',
 *  'project about',
 * ];
 * vocabulary.phrasesAdd( phrases );
 * let subject = 'deck';
 * let result = vocabulary.helpForSubject( subject );
 * console.log( result );
 * //[ '.deck.properties - Deck properties.', '.deck.about - Deck about.' ]
 *
 * @method helpForSubject
 * @throws { Exception } Throw an exception if no arguments provided.
 * @throws { Exception } Throw an exception if more than two arguments provided.
 * @throws { Exception } Throw an exception if( wVocabulary.wordMap ) is not a Object.
 * @throws { Exception } Throw an exception if( subject ) is not a String or Array.
 * @class wVocabulary
 * @namespace wTools
 * @module Tools/mid/Vocabulary
 *
 */

function helpForSubject_body( o )
{
  let self = this;

  _.assert( arguments.length === 1 );

  let o2 = _.mapOnly( o, self.subjectDescriptorFor.defaults );
  o2.exact = 1;
  let actions = self.subjectDescriptorFor( o2 );

  if( !actions )
  {
    let o2 = _.mapOnly( o, self.subjectDescriptorForWithClause.defaults );
    actions = self.subjectDescriptorForWithClause( o2 );
  }

  actions = _.arrayAs( actions );

  if( !actions.length )
  return '';

  let part1 = actions.map( ( e ) => e.phraseDescriptor.words.join( '.' ) );
  let part2 = actions.map( ( e ) => e.phraseDescriptor.hint || _.strCapitalize( e.phraseDescriptor.phrase + '.' ) );
  let help = _.strJoin( [ o.decorating ? _.ct.format( '.', 'code' ) : '.', o.decorating ? _.ct.format( part1, 'code' ) : part1, ' - ', part2 ] );

  return help;
}

var defaults = helpForSubject_body.defaults = Object.create( subjectDescriptorForWithClause.defaults );
defaults.decorating = 1;

let helpForSubject = _.routineUnite( helpForSubject_head, helpForSubject_body );

//

function helpForSubjectAsString_body( o )
{
  let self = this;
  return _.toStr( self.helpForSubject( o ), { levels : 2, wrap : 0, stringWrapper : '', multiline : 1 } );
}

helpForSubjectAsString_body.defaults = Object.create( helpForSubject.defaults );

let helpForSubjectAsString = _.routineUnite( helpForSubject_head, helpForSubjectAsString_body );

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
 * let result = vocabulary.phraseParse({ phrase : phrase, delimeneter : '.' });
 * console.log( result );
 *
 * @method phraseParse
 * @throws { Exception } Throw an exception if more than one argument is provided.
 * @throws { Exception } Throw an exception if ( src ) is not a String.
 * @class wVocabulary
 * @namespace wTools
 * @module Tools/mid/Vocabulary
 */

function phraseParse( o )
{
  let self = this;
  let result = Object.create( null );

  if( !_.objectIs( o ) )
  o = { phrase : arguments[ 0 ] };

  _.assert( _.mapIs( self.wordMap ) );
  _.assert( _.strIs( o.phrase ) || _.arrayIs( o.phrase ), () => 'Expects string or array of words, but got ' + _.strType( o.phrase ) );
  _.assert( arguments.length === 1 );
  _.routineOptions( phraseParse, o );

  o.delimeter = o.delimeter === null ? self.lookingDelimeter : o.delimeter;

  result.words = _.arrayIs( o.phrase ) ? o.phrase : _.strSplitNonPreserving( { src : o.phrase, delimeter : o.delimeter } );
  // result.phrase = result.words.join( self.addingDelimeter );
  result.phrase = result.words.join( self.addingDelimeterDefault );
  // result.phrasePrefixed = ( self.addingDelimeterDefault + result.phrase ).trim();

  return result;
}

phraseParse.defaults =
{
  phrase : null,
  delimeter : null,
}

//

/**
 * @summary Filters array of `subjects` using selector `selector`.
 * @param {Array} subjects Array of subjects.
 * @param {Object} selector Selector for filter.
 * @param {Object} selector.slicePhrase Part of targer phrase.
 * @param {Object} selector.wholePhrase Target phrase.
 * @param {Object} selector.subPhrase Subject of target phrase.
 * @method subjectsFilter
 * @throws { Exception } Throw an exception if arguments length is not equal 2.
 * @returns {Array} Returns found subjects.
 * @class wVocabulary
 * @namespace wTools
 * @module Tools/mid/Vocabulary
 */

function subjectsFilter( subjects, selector )
{
  let self = this;

  _.assert( arguments.length === 2 );
  _.assert( _.arrayIs( subjects ) );
  _.assertMapHasOnly( selector, subjectsFilter.defaults );

  if( selector.wholePhrase )
  selector.wholePhrase = self.phraseParse( { phrase : selector.wholePhrase } ).phrase;
  if( selector.slicePhrase )
  selector.slicePhrase = self.phraseParse( { phrase : selector.slicePhrase } ).phrase;
  if( selector.subPhrase )
  selector.subPhrase = self.phraseParse( { phrase : selector.subPhrase } ).phrase;

  let _onEach = _._filter_functor( selector, 1 );
  let result = _.entityFilter( subjects, _onEach );

  return result;
}

subjectsFilter.defaults =
{
  slicePhrase : null,
  wholePhrase : null,
  subPhrase : null,
}

//

function wordsComplySubject( words, subject )
{
  let result = [];

  debugger
  _.assert( _.arrayIs( words ) );
  _.assert( _.arrayIs( subject ) );
  _.assert( arguments.length === 2, 'Expects exactly two arguments' );

  if( subject.length === 0 )return true;
  if( words.length === 0 )return false;

  let w = words.indexOf( subject[ 0 ] )
  if( words.length - w < subject.length )
  return false;

  for( let i = w+1 ; i < w+subject.length ; i++ )
  if( subject[ i-w ] !== words[ i ] )
  return false;

  return true;
}

//

function _onDescriptorSimplestMake( src )
{
  let result = Object.create( null );
  _.assert( _.strIs( src ) );
  _.assert( arguments.length === 1 );
  result.phrase = src;
  return result;
}

//

function _onPhraseDescriptorMake( src )
{

  _.assert( _.strIs( src ) || _.arrayIs( src ) );
  _.assert( arguments.length === 1 );

  let self = this;
  let result = Object.create( null );
  let phrase = src;
  let executable = null;
  let hint = hintFrom( phrase );

  if( _.arrayIs( phrase ) )
  {
    _.assert( phrase.length === 2 );
    executable = phrase[ 1 ];
    phrase = phrase[ 0 ];
    hint = hintFrom( phrase );
  }

  if( _.objectIs( executable ) )
  {
    _.assertMapHasOnly( executable, { e : null, h : null } );
    hint = executable.h;
    executable = executable.e;
  }

  result.phrase = phrase;
  result.hint = hint;
  result.executable = executable;

  return result;

  function hintFrom( phrase )
  {
    if( _.strIs( phrase ) )
    phrase = phrase.split( self.addingDelimeterDefault );
    let hint = phrase ? phrase.join( ' ' ) : null;
    return hint;
  }

}

// --
// relations
// --

let Composes =
{

  onPhraseDescriptorMake : _onPhraseDescriptorMake,

  addingDelimeterDefault : '.',
  addingDelimeter : _.define.own([ '.', ' ' ]),
  lookingDelimeter : _.define.own([ '.', ' ' ]),
  overriding : 0,
  clausing : 0,
  freezing : 1,
  coloring : 1,

}

let Aggregates =
{

  phraseArray : _.define.own( [] ),
  descriptorArray : _.define.own( [] ),

  descriptorMap : _.define.own( {} ),
  wordMap : _.define.own( {} ),
  subjectMap : _.define.own( {} ),

  clauseForSubjectMap : _.define.own( {} ),
  clauseMap : _.define.own( {} ),

}

let Restricts =
{
}

// --
// declare
// --

let Proto =
{

  init,
  form,

  phrasesAdd,
  phraseAdd,

  _updateWordMap,
  _updateSubjectMap,
  _updateClauseMap,

  subPhrase,

  subjectDescriptorFor,
  subjectDescriptorForWithClause,
  helpForSubject,
  helpForSubjectAsString,

  phraseParse,
  subjectsFilter,
  wordsComplySubject,

  _onDescriptorSimplestMake,
  _onPhraseDescriptorMake,

  // relations

  Composes,
  Aggregates,
  Restricts,

}

//

_.classDeclare
( {
  cls : Self,
  parent : Parent,
  extend : Proto,
} );

_.Copyable.mixin( Self );

// --
// export
// --

_global_[ Self.name ] = _[ Self.shortName ] = Self;
if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

} )();
