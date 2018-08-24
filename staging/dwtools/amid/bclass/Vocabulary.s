(function _Vocabulary_s_() {

'use strict';

/**
  @module Tools/mid/Vocabulary - Class to operate phrases. A phrase consists of words. Vocabulary enables the design of CLI based on phrases instead of words. It makes possible to group several similar phrases and help a user learn CLI faster. Use it to make your CLI more user-friendly.
*/

/**
 * @file Vocabulary.s.
 */

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

  let _ = _global_.wTools;

  _.include( 'wCopyable' );

}

//

let _ = _global_.wTools;

/**
* Definitions :

*  word : : smallest part of a phrase( e.g., 'deck' ).
*  phrase : : combination of words with space as separator( e.g., 'deck properties' ).
*  subject : : a word or combination of it, used during search to determine if phrase is related to the subject.
*  clause : : a piece of a phrase( e.g. 'deck' is subphrase of 'deck properties' ).
*  phraseDescriptor : : object that contains info about a phrase.


*/

/**
 * Class wVocabulary
 * @class wVocabulary
 */

/**
* Options object for wVocabulary constructor
* @typedef {Object} wVocabulary~wVocabularyOptions
* @property {function} [ onPhraseDescriptorMake ] - Creates phraseDescriptor based on data of the phrase. By default its a routine that wraps passed phrase into object.
* @property {boolean} [ overriding=0 ] - Controls overwriting of existing phrases.
* @property {boolean} [ clausing=0 ] -
* @property {boolean} [ freezing=1 ] - Prevents future extensions of phrase phraseDescriptor.
*/

/**
* Containers of wVocabulary instance
* @typedef {Object} wVocabulary~wVocabularyMaps
* @property {Array} [ phraseArray ] - Contains available phrases.
* @property {Array} [ descriptorArray ] - Contains descriptors of available phrases.
* @property {Object} [ descriptorMap ] - Maps phrase with its phraseDescriptor.
* @property {Object} [ wordMap ] - Maps each word of the phrase with descriptors of phrases that contains it.
* @property {Object} [ subjectMap ] - Maps possible subjects with descriptors of phrases that contains it.
* @property {Object} [ clauseForSubjectMap ] - Maps subjects to clause.
* @property {Object} [ clauseMap ] - Maps possible subphrases( clause ) with descriptors of phrases that contains it.
*/

/**
 * Creates instance of wVocabulary
 * @example
   let vocabulary = new wVocabulary();

 * @example
   let o = { freezing : 0 }
   let vocabulary = new wVocabulary( o );

 * @param {wVocabulary~wVocabularyOptions}[o] initialization options {@link wVocabulary~wVocabularyOptions}.
 * @returns {wVocabulary}
 * @constructor
 * @see {@link wVocabulary}
 */

let Parent = null;
let Self = function wVocabulary( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'Vocabulary';

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
  let self = this;

  _.instanceInit( self );
  Object.preventExtensions( self );

  if( o )
  self.copy( o );

}

//

/**
 * Adds provided phrase(s) to the vocabulary.
 * Routine analyzes provided phrase(s) and creates phraseDescriptor for each phrase by calling ( wVocabulary.onPhraseDescriptorMake ) routine and complementing it with additional data.
 * Routine expects that result of ( wVocabulary.onPhraseDescriptorMake ) call will be an Object.
 * Data from phraseDescriptor is used to update containers of the vocabulary, see {@link wVocabulary~wVocabularyOptions} for details.
 * If phrases are provided in Array, they can have any type.
 * If ( wVocabulary.overriding ) is enabled, existing phrase can be rewritten by new one.
 * @param {String|Array} src - Source phrase or array of phrases.
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
 * @memberof wVocabulary
 *
 */

function phrasesAdd( src )
{
  let self = this;
  let vocabulary = this;
  let replaceDescriptor = null;

  _.assert( _.strIs( src ) || _.containerIs( src ), 'expects string or array' );
  _.assert( arguments.length === 1, 'expects single argument' );

  if( _.arrayIs( src ) )
  _.each( src, ( e,k ) =>
  {
    self.phraseAdd( e );
  });
  else if( _.objectIs( src ) )
  _.each( src, ( e,k ) =>
  {
    self.phraseAdd([ k,e ]);
  });
  else
  {
    self.phraseAdd( src );
  }

  return self;
}

//

function phraseAdd( src )
{
  let self = this;
  let vocabulary = this;
  let replaceDescriptor = null;
  let phraseDescriptor = self.onPhraseDescriptorMake( src );
  let words = phraseDescriptor.words = _.strSplitNonPreserving({ src : phraseDescriptor.phrase, delimeter : self.addingDelimeter });
  let phrase = phraseDescriptor.phrase = phraseDescriptor.words.join( ' ' );

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.strIs( self.addingDelimeter ) );
  _.assert( _.objectIs( phraseDescriptor ), 'phrase phraseDescriptor should be object' );
  _.assert( _.strIs( phrase ), 'empty phrase' );

  /* */

  if( self.descriptorMap[ phrase ] )
  {

    _.assert( phraseDescriptor.override || self.overriding, 'phrase overriding :',phraseDescriptor.phrase );

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

  self._updateWordMap( phraseDescriptor,words,phrase,replaceDescriptor );
  self._updateSubjectMap( phraseDescriptor,words,phrase,replaceDescriptor );
  self._updateClauseMap( phraseDescriptor,words,phrase,replaceDescriptor );

  /* freeze */

  if( self.freezing )
  Object.preventExtensions( phraseDescriptor );

  return self;
}

//

function _updateWordMap( phraseDescriptor,words,phrase,replaceDescriptor )
{
  let self = this;

  for( let w = 0 ; w < words.length ; w++ )
  {
    let word = words[ w ];
    self.wordMap[ word ] = _.arrayAs( self.wordMap[ word ] || [] );

    if( replaceDescriptor )
    {
      _.arrayReplaceOnceStrictly( self.wordMap[ word ], replaceDescriptor, phraseDescriptor );
    }
    else
    {
      self.wordMap[ word ].push( phraseDescriptor );
    }

  }

  return self;
}

//

function _updateSubjectMap( phraseDescriptor, words, phrase, replaceDescriptor )
{
  let self = this;

  function use( w,c )
  {
    let sliceWords = words.slice( w,w+c );
    let slicePhrase = sliceWords.join( ' ' );

    if( replaceDescriptor )
    {
      // debugger;
      let i = _.arrayRightIndex( self.subjectMap[ slicePhrase ], replaceDescriptor, ( e ) => e.phraseDescriptor, ( e ) => e );
      _.assert( i >= 0 );
      self.subjectMap[ slicePhrase ][ i ].phraseDescriptor = phraseDescriptor;
      return;
    }

    let subject = Object.create( null );

    subject.words = sliceWords;
    subject.slicePhrase = slicePhrase;
    subject.wholePhrase = phraseDescriptor.phrase;
    subject.subPhrase = self.subPhrase( phraseDescriptor.phrase, slicePhrase );
    subject.phraseDescriptor = phraseDescriptor;
    subject.kind = 'subject';

    _.accessorForbid( subject, 'phrase' );

    self.subjectMap[ slicePhrase ] = _.arrayAs( self.subjectMap[ slicePhrase ] || [] );
    self.subjectMap[ slicePhrase ].push( subject );
  }

  use( 0,0 );

  for( let c = 1 ; c <= words.length ; c++ )
  {
    for( let w = 0 ; w <= words.length-c ; w++ )
    {
      use( w,c );
    }
  }

  return self;
}

//

function _updateClauseMap( phraseDescriptor,words,phrase,replaceDescriptor )
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

  if( phraseDescriptor.clauseLimit === null )
  phraseDescriptor.clauseLimit = [ 1,+Infinity ];
  else if( _.numberIs( phraseDescriptor.clauseLimit ) )
  phraseDescriptor.clauseLimit = [ 1,phraseDescriptor.clauseLimit ];
  else if( !_.arrayIs( phraseDescriptor.clauseLimit ) )
  _.assert( 0, 'expects clauseLimit as number or array' );

  _.assert( phraseDescriptor.clauseLimit[ 0 ] >= 1 );

  function dequalizer( a,b ){ return a.phraseDescriptor === b };

  let clauseLength = 0;
  let maxClauseLength = Math.min( words.length,phraseDescriptor.clauseLimit[ 1 ] );
  for( clauseLength = maxClauseLength ; clauseLength >= phraseDescriptor.clauseLimit[ 0 ] ; clauseLength-- )
  {

    for( let w = 0 ; w <= words.length-clauseLength ; w++ )
    {

      let subjectLength = clauseLength - 1;
      let subjectWords = words.slice( w,w+subjectLength );
      let subjectPhrase = subjectWords.join( ' ' );

      let clauseWords = words.slice( w,w+clauseLength );
      let clausePhrase = clauseWords.join( ' ' );
      let clause = self.clauseMap[ clausePhrase ];

      let subject = self.subjectMap[ clausePhrase ];
      subject = _.entityFilter( subject, function( e )
      {
        if( e.phraseDescriptor.words.length === clauseLength )
        return;
        if( e.phraseDescriptor.clauseLimit[ 0 ] <= clauseLength && clauseLength <= e.phraseDescriptor.clauseLimit[ 1 ] )
        return e.phraseDescriptor;
      });

      if( subject.length < 2 )
      continue;

      if( clause )
      {

        _.assert( phraseDescriptor.phrase.indexOf( clause.phrase ) !== -1 );

        if( replaceDescriptor )
        {
          let i = _.arrayUpdate( clause.descriptors,replaceDescriptor,phraseDescriptor );
          _.assert( i >= 0 );
        }
        else
        {
          clause.descriptors.push( phraseDescriptor );
        }

        continue;
      }

      clause = Object.create( null );
      clause.words = clauseWords;
      clause.phrase = clausePhrase;
      clause.subjectWords = subjectWords;
      clause.subjectPhrase = subjectPhrase;
      clause.subPhrase = self.subPhrase( clausePhrase,subjectPhrase );

      clause.phraseDescriptor = clause;
      clause.descriptors = subject;
      clause.kind = 'clause';

      _.assert( !self.clauseMap[ clausePhrase ] );

      self.clauseForSubjectMap[ subjectPhrase ] = _.arrayAs( self.clauseForSubjectMap[ subjectPhrase ] || [] );
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
 * let subject = 'xxx';
 * let strippedPhrase = vocabulary.subPhrase( phrase, subject );
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
    });
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
 * @memberof wVocabulary
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

/*
  if( !subject.length && parsed.phrase === '' )
  {
    debugger;
    result = self.descriptorArray.slice();
    let clauses = _.entityFilter( self.clauseForSubjectMap,function( e ){ if( e.subjectWords.length === 1 ) return e; } );
    for( let c in clauses )
    _.arrayRemoveArrayOnce( result,clauses[ c ].descriptors );
    result = _.entityMap( result,function( e ){ return { phraseDescriptor : e } } );
    clauses = _.entityMap( clauses,function( e )
    {
      let result = { descriptors : e.descriptors, words : e.subjectWords, phrase : e.parsed.phrase, kind : 'subjectDescriptorForWithClause' };
      result.phraseDescriptor = result;
      return result;
    });
    _.arrayAppendArray( result,_.mapVals( clauses ) );
    return result;
  }
*/

  if( !o.clausing || !self.clauseForSubjectMap[ parsed.phrase ] )
  return subject;

  let clauses = self.clauseForSubjectMap[ parsed.phrase ];

  debugger;

  if( clauses.length === 1 && clauses[ 0 ].descriptors.length === subject.length )
  return subject;

  _.arrayAppendArray( result, clauses );
  added = _.arrayFlatten( [], _.entitySelect( clauses, '*.descriptors' ) );

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

function helpForSubject_pre( routine, args )
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
 * @memberof wVocabulary
 *
 */

function helpForSubject_body( o )
{
  let self = this;

  _.assert( arguments.length === 1 );

  let actions = self.subjectDescriptorForWithClause( o );

  if( !actions.length )
  return '';

  let part1 = actions.map( ( e ) => e.phraseDescriptor.words.join( '.' ) );
  let part2 = actions.map( ( e ) => e.phraseDescriptor.hint || _.strCapitalize( e.phraseDescriptor.phrase + '.' ) );
  let help = _.strJoin( '.', part1, ' - ', part2 );

  return help;
}

helpForSubject_body.defaults = Object.create( subjectDescriptorForWithClause.defaults );

let helpForSubject = _.routineForPreAndBody( helpForSubject_pre, helpForSubject_body );

//

function helpForSubjectAsString_body( o )
{
  let self = this;
  return _.toStr( self.helpForSubject( o ), { levels : 2, wrap : 0, stringWrapper : '', multiline : 1 } );
}

helpForSubjectAsString_body.defaults = Object.create( helpForSubject.defaults );

let helpForSubjectAsString = _.routineForPreAndBody( helpForSubject_pre, helpForSubjectAsString_body );

//

function phraseParse( o )
{
  let self = this;
  let result = Object.create( null );

  if( !_.objectIs( o ) )
  o = { phrase : arguments[ 0 ] };

  _.assert( _.mapIs( self.wordMap ) );
  _.assert( _.strIs( o.phrase ) || _.arrayIs( o.phrase ), () => 'expects string or array of words, but got ' + _.strTypeOf( o.phrase ) );
  _.assert( arguments.length === 1 );
  _.routineOptions( phraseParse, o );

  o.delimeter = o.delimeter === null ? self.lookingDelimeter : o.delimeter;

  result.words = _.arrayIs( o.phrase ) ? o.phrase : _.strSplitNonPreserving({ src : o.phrase, delimeter : o.delimeter });
  result.phrase = result.words.join( self.addingDelimeter );

  return result;
}

phraseParse.defaults =
{
  phrase : null,
  delimeter : null,
}

//

function subjectsFilter( subjects, selector )
{
  let self = this;

  _.assert( arguments.length === 2 );
  _.assert( _.arrayIs( subjects ) );
  _.assertMapHasOnly( selector, subjectsFilter.defaults );

  if( selector.wholePhrase )
  selector.wholePhrase = self.phraseParse({ phrase : selector.wholePhrase }).phrase;
  if( selector.slicePhrase )
  selector.slicePhrase = self.phraseParse({ phrase : selector.slicePhrase }).phrase;
  if( selector.subPhrase )
  selector.subPhrase = self.phraseParse({ phrase : selector.subPhrase }).phrase;

  let _onEach = _._selectorMake( selector, 1 );
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
  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  if( subject.length === 0 ) return true;
  if( words.length === 0 ) return false;

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

  _.assert(  _.strIs( src ) || _.arrayIs( src ) );
  _.assert( arguments.length === 1 );

  let self = this;
  let result = Object.create( null );
  let phrase = src;
  let executable = null;

  if( _.arrayIs( phrase ) )
  {
    _.assert( phrase.length === 2 );
    executable = phrase[ 1 ];
    phrase = phrase[ 0 ];
  }

  let hint = phrase;

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
}

// --
// relations
// --

let Composes =
{

  onPhraseDescriptorMake : _onPhraseDescriptorMake,

  addingDelimeter : ' ',
  lookingDelimeter : _.define.own([ ' ' ]),
  overriding : 0,
  clausing : 0,
  freezing : 1,

}

let Aggregates =
{

  phraseArray : _.define.own([]),
  descriptorArray : _.define.own([]),

  descriptorMap : _.define.own({}),
  wordMap : _.define.own({}),
  subjectMap : _.define.own({}),

  clauseForSubjectMap : _.define.own({}),
  clauseMap : _.define.own({}),

}

let Restricts =
{
}

// --
// declare
// --

let Proto =
{

  init : init,

  phrasesAdd : phrasesAdd,
  phraseAdd : phraseAdd,

  _updateWordMap : _updateWordMap,
  _updateSubjectMap : _updateSubjectMap,
  _updateClauseMap : _updateClauseMap,

  subPhrase : subPhrase,

  subjectDescriptorFor : subjectDescriptorFor,
  subjectDescriptorForWithClause : subjectDescriptorForWithClause,
  helpForSubject : helpForSubject,
  helpForSubjectAsString : helpForSubjectAsString,

  phraseParse : phraseParse,
  subjectsFilter : subjectsFilter,
  wordsComplySubject : wordsComplySubject,

  _onDescriptorSimplestMake : _onDescriptorSimplestMake,
  _onPhraseDescriptorMake : _onPhraseDescriptorMake,

  // relations

  Composes : Composes,
  Aggregates : Aggregates,
  Restricts : Restricts,

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
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
