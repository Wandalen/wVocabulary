( function _Vocabulary_test_s_( ) {

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

  require( '../bclass/Vocabulary.s' );

  _.include( 'wTesting' );

}

var _ = _global_.wTools;
var vocabulary = new wVocabulary();

//

function makeWordMap( phrases, descriptorArray, descriptorMap )
{
  var wordMap = Object.create( null );
  descriptorArray.forEach( ( d ) =>
  {
    var words = d.words;

    words.forEach( ( w ) =>
    {
      if( wordMap[ w ] === undefined )
      wordMap[ w ] = [];

      phrases.forEach( ( p ) =>
      {
        if( _.strHas( p, w ) )
        {
          var phraseDescriptor = descriptorMap[ p ];
          if( wordMap[ w ].indexOf( phraseDescriptor ) === -1 )
          wordMap[ w ].push( phraseDescriptor );
        }
      })
    })
  })

  return wordMap;
}

//

function makeDescriptorArray( phrases )
{
  return phrases.map( ( p ) =>
  {
    var d =
    {
      phrase : p,
      words : _.strSplitNonPreserving({ src : p }),
    }
    return d;
  });
}

//

function makeDescriptorMap( makeDescriptorArray )
{
  var descriptorMap = Object.create( null );

  makeDescriptorArray.forEach( ( d ) =>
  {
    descriptorMap[ d.phrase ] = d;
    return d;
  });

  return descriptorMap;
}

//

function makeSubjectMap( descriptorArray )
{
  var subjectMap = Object.create( null );

  descriptorArray.forEach( ( d ) =>
  {
    var words = d.words.slice();
    words.unshift( d.phrase );

    words.forEach( ( w ) =>
    {
      var sub = vocabulary.subPhrase( d.phrase, w );

      if( subjectMap[ w ] === undefined )
      subjectMap[ w ] = [];

      var subject = Object.create( null );
      subject.phraseDescriptor = d;
      subject.kind = 'subject';
      subject.phrase = w;
      subject.subPhrase = sub;
      subject.words = _.strSplitNonPreserving({ src : w });

      subjectMap[ w ].push( subject );
    })
  })

  return subjectMap;
}

// --
// Tests
// --

function phraseAdd( test )
{
  var pd =
  {
    phrase : 'project act',
    words : [ 'project', 'act' ],
    hint : 'project act',
    executable : null
  }
  var phraseArray = [ pd.phrase ];
  var descriptorArray = [ pd ]
  var descriptorMap =
  {
    'project act' : pd
  }
  var wordMap =
  {
    'project' : [ pd ],
    'act' : [ pd ],
  }
  var subjectMap =
  {
   '' :
   [
     {
       words : [],
       slicePhrase : '',
       wholePhrase : 'project act',
       subPhrase : 'project act',
       phraseDescriptor : pd,
       kind : 'subject'
     }
   ],
   'project' :
   [
     {
       words : [ 'project' ],
       slicePhrase : 'project',
       wholePhrase : 'project act',
       subPhrase : 'act',
       phraseDescriptor : pd,
       kind : 'subject'
     }
   ],
   'act' :
   [
     {
       words : [ 'act' ],
       slicePhrase : 'act',
       wholePhrase : 'project act',
       subPhrase : 'project',
       phraseDescriptor : pd,
       kind : 'subject'
     }
   ],
   'project act' :
   [
     {
       words : [ 'project', 'act' ],
       slicePhrase : 'project act',
       wholePhrase : 'project act',
       subPhrase : '',
       phraseDescriptor : pd,
       kind : 'subject'
     }
   ]
  }

  test.case = 'string'
  var voc = new _.Vocabulary();
  voc.phraseAdd( 'project act' );
  test.identical( voc.phraseArray, phraseArray )
  test.identical( voc.descriptorArray, descriptorArray )
  test.identical( voc.descriptorMap, descriptorMap )
  test.identical( voc.wordMap,wordMap )
  test.identical( voc.subjectMap, subjectMap );
  test.identical( voc.clausing, 0 );
  test.identical( voc.clauseMap, {} );
  test.identical( voc.clauseForSubjectMap, {} );

  test.case = 'array'
  var voc = new _.Vocabulary();
  voc.phraseAdd([ 'project act', 'executable' ]);
  pd.executable = 'executable';
  test.identical( voc.phraseArray, phraseArray )
  test.identical( voc.descriptorArray, descriptorArray )
  test.identical( voc.descriptorMap, descriptorMap )
  test.identical( voc.wordMap,wordMap )
  test.identical( voc.subjectMap, subjectMap );
  test.identical( voc.clausing, 0 );
  test.identical( voc.clauseMap, {} );
  test.identical( voc.clauseForSubjectMap, {} );

  test.case = 'array'
  function executable(){}
  var voc = new _.Vocabulary();
  voc.phraseAdd([ 'project act', { e : executable, h : 'function' } ]);
  pd.executable = executable;
  pd.hint = 'function';
  test.identical( voc.phraseArray, phraseArray )
  test.identical( voc.descriptorArray, descriptorArray )
  test.identical( voc.descriptorMap, descriptorMap )
  test.identical( voc.wordMap,wordMap )
  test.identical( voc.subjectMap, subjectMap );
  test.identical( voc.clausing, 0 );
  test.identical( voc.clauseMap, {} );
  test.identical( voc.clauseForSubjectMap, {} );
  pd.executable = null;
  pd.hint = pd.phrase;

  test.case = 'override existing phrase'
  var voc = new _.Vocabulary({ overriding : 1 });
  voc.phraseAdd( 'project act' );
  voc.phraseAdd( 'project act' );
  test.identical( voc.phraseArray, phraseArray )
  test.identical( voc.descriptorArray, descriptorArray )
  test.identical( voc.descriptorMap, descriptorMap )
  test.identical( voc.wordMap,wordMap )
  test.identical( voc.subjectMap, subjectMap );
  test.identical( voc.clausing, 0 );
  test.identical( voc.clauseMap, {} );
  test.identical( voc.clauseForSubjectMap, {} );

  test.case = 'lock descriptor: on'
  var voc = new _.Vocabulary({ freezing : 1 });
  voc.phraseAdd( 'project act' );
  test.identical( voc.descriptorArray[ 0 ], voc.descriptorMap[ 'project act' ] );
  test.identical( voc.descriptorMap[ 'project act' ], pd );
  test.shouldThrowError( () =>
  {
    voc.descriptorMap[ 'project act' ].someField = 1;
  })

  test.case = 'lock descriptor: off'
  var voc = new _.Vocabulary({ freezing : 0 });
  voc.phraseAdd( 'project act' );
  test.identical( voc.descriptorArray[ 0 ], voc.descriptorMap[ 'project act' ] );
  test.identical( voc.descriptorMap[ 'project act' ], pd );
  test.mustNotThrowError( () =>
  {
    voc.descriptorMap[ 'project act' ].someField = 1;
  })

  //

  if( !Config.debug )
  return;

  var voc = new _.Vocabulary();
  test.shouldThrowError( () => voc.phraseAdd( 1 ) )
  test.shouldThrowError( () => voc.phraseAdd( { phrase : 'executable' } ) )

  var voc = new _.Vocabulary({ overriding : 0 });
  voc.phrasesAdd( 'project act' );
  test.shouldThrowError( () => voc.phraseAdd( 'project act' ) )
}

//

function phrasesAdd( test )
{
  var pd =
  {
    phrase : 'project act',
    words : [ 'project', 'act' ],
    hint : 'project act',
    executable : null
  }
  var phraseArray = [ pd.phrase ];
  var descriptorArray = [ pd ]
  var descriptorMap =
  {
    'project act' : pd
  }
  var wordMap =
  {
    'project' : [ pd ],
    'act' : [ pd ],
  }
  var subjectMap =
  {
   '' :
   [
     {
       words : [],
       slicePhrase : '',
       wholePhrase : 'project act',
       subPhrase : 'project act',
       phraseDescriptor : pd,
       kind : 'subject'
     }
   ],
   'project' :
   [
     {
       words : [ 'project' ],
       slicePhrase : 'project',
       wholePhrase : 'project act',
       subPhrase : 'act',
       phraseDescriptor : pd,
       kind : 'subject'
     }
   ],
   'act' :
   [
     {
       words : [ 'act' ],
       slicePhrase : 'act',
       wholePhrase : 'project act',
       subPhrase : 'project',
       phraseDescriptor : pd,
       kind : 'subject'
     }
   ],
   'project act' :
   [
     {
       words : [ 'project', 'act' ],
       slicePhrase : 'project act',
       wholePhrase : 'project act',
       subPhrase : '',
       phraseDescriptor : pd,
       kind : 'subject'
     }
   ]
  }

  test.case = 'string'
  var voc = new _.Vocabulary();
  voc.phrasesAdd( 'project act' );
  test.identical( voc.phraseArray, phraseArray )
  test.identical( voc.descriptorArray, descriptorArray )
  test.identical( voc.descriptorMap, descriptorMap )
  test.identical( voc.wordMap,wordMap )
  test.identical( voc.subjectMap, subjectMap );
  test.identical( voc.clausing, 0 );
  test.identical( voc.clauseMap, {} );
  test.identical( voc.clauseForSubjectMap, {} );

  test.case = 'array of strings'
  var voc = new _.Vocabulary();
  voc.phrasesAdd([ 'project act' ]);
  test.identical( voc.phraseArray, phraseArray )
  test.identical( voc.descriptorArray, descriptorArray )
  test.identical( voc.descriptorMap, descriptorMap )
  test.identical( voc.wordMap,wordMap )
  test.identical( voc.subjectMap, subjectMap );
  test.identical( voc.clausing, 0 );
  test.identical( voc.clauseMap, {} );
  test.identical( voc.clauseForSubjectMap, {} );

  test.case = 'array of arrays'
  var voc = new _.Vocabulary();
  voc.phrasesAdd([ [ 'project act', 'executable' ] ]);
  pd.executable = 'executable';
  test.identical( voc.phraseArray, phraseArray )
  test.identical( voc.descriptorArray, descriptorArray )
  test.identical( voc.descriptorMap, descriptorMap )
  test.identical( voc.wordMap,wordMap )
  test.identical( voc.subjectMap, subjectMap );
  test.identical( voc.clausing, 0 );
  test.identical( voc.clauseMap, {} );
  test.identical( voc.clauseForSubjectMap, {} );
  pd.executable = null;

  test.case = 'object'
  var voc = new _.Vocabulary();
  function executable(){}
  var phrase = [ 'project act', { e : executable, h : 'function' } ];
  voc.phrasesAdd([ phrase ]);
  pd.executable = executable;
  pd.hint = 'function';
  test.identical( voc.phraseArray, phraseArray )
  test.identical( voc.descriptorArray, descriptorArray )
  test.identical( voc.descriptorMap, descriptorMap )
  test.identical( voc.wordMap,wordMap )
  test.identical( voc.subjectMap, subjectMap );
  test.identical( voc.clausing, 0 );
  test.identical( voc.clauseMap, {} );
  test.identical( voc.clauseForSubjectMap, {} );
  pd.executable = null;
  pd.hint = pd.phrase;

  test.case = 'object'
  var voc = new _.Vocabulary();
  function executable(){}
  var phrase = { 'project act' : { e : executable, h : 'function' } };
  voc.phrasesAdd( phrase );
  pd.executable = executable;
  pd.hint = 'function';
  test.identical( voc.phraseArray, phraseArray )
  test.identical( voc.descriptorArray, descriptorArray )
  test.identical( voc.descriptorMap, descriptorMap )
  test.identical( voc.wordMap,wordMap )
  test.identical( voc.subjectMap, subjectMap );
  test.identical( voc.clausing, 0 );
  test.identical( voc.clauseMap, {} );
  test.identical( voc.clauseForSubjectMap, {} );
  pd.executable = null;
  pd.hint = pd.phrase;

  test.case = 'several phrases array'
  var voc = new _.Vocabulary();
  voc.phrasesAdd
  ([
    'phrase1 act',
    'phrase2 act'
  ]);
  test.identical( voc.phraseArray, [ 'phrase1 act', 'phrase2 act' ] )
  test.identical( voc.descriptorArray.length, 2 )
  test.identical( _.mapOwnKeys( voc.descriptorMap ), [ 'phrase1 act', 'phrase2 act' ] )
  test.identical( _.mapOwnKeys( voc.wordMap ),[ 'phrase1', 'act', 'phrase2' ] )
  test.identical( _.mapOwnKeys( voc.subjectMap ),[ '', 'phrase1', 'act', 'phrase1 act', 'phrase2', 'phrase2 act' ] )
  test.identical( voc.clausing, 0 );
  test.identical( voc.clauseMap, {} );
  test.identical( voc.clauseForSubjectMap, {} );

  test.case = 'several phrases object'
  var voc = new _.Vocabulary();
  voc.phrasesAdd
  ({
    'phrase1 act' : 'executable1',
    'phrase2 act' : 'executable2'
  });
  test.identical( voc.phraseArray, [ 'phrase1 act', 'phrase2 act' ] )
  test.identical( voc.descriptorArray.length, 2 )
  test.identical( _.mapOwnKeys( voc.descriptorMap ), [ 'phrase1 act', 'phrase2 act' ] )
  test.identical( _.mapOwnKeys( voc.wordMap ),[ 'phrase1', 'act', 'phrase2' ] )
  test.identical( _.mapOwnKeys( voc.subjectMap ),[ '', 'phrase1', 'act', 'phrase1 act', 'phrase2', 'phrase2 act' ] )
  test.identical( voc.clausing, 0 );
  test.identical( voc.clauseMap, {} );
  test.identical( voc.clauseForSubjectMap, {} );

  test.case = 'override existing phrase'
  var voc = new _.Vocabulary({ overriding : 1 });
  voc.phrasesAdd( 'project act' );
  voc.phrasesAdd( 'project act' );
  test.identical( voc.phraseArray, phraseArray )
  test.identical( voc.descriptorArray, descriptorArray )
  test.identical( voc.descriptorMap, descriptorMap )
  test.identical( voc.wordMap,wordMap )
  test.identical( voc.subjectMap, subjectMap );
  test.identical( voc.clausing, 0 );
  test.identical( voc.clauseMap, {} );
  test.identical( voc.clauseForSubjectMap, {} );

  test.case = 'lock descriptor: on'
  var voc = new _.Vocabulary({ freezing : 1 });
  voc.phrasesAdd( 'project act' );
  test.identical( voc.descriptorArray[ 0 ], voc.descriptorMap[ 'project act' ] );
  test.identical( voc.descriptorMap[ 'project act' ], pd );
  test.shouldThrowError( () =>
  {
    voc.descriptorMap[ 'project act' ].someField = 1;
  })

  test.case = 'lock descriptor: off'
  var voc = new _.Vocabulary({ freezing : 0 });
  voc.phrasesAdd( 'project act' );
  test.identical( voc.descriptorArray[ 0 ], voc.descriptorMap[ 'project act' ] );
  test.identical( voc.descriptorMap[ 'project act' ], pd );
  test.mustNotThrowError( () =>
  {
    voc.descriptorMap[ 'project act' ].someField = 1;
  })

  if( !Config.debug )
  return;

  var voc = new _.Vocabulary();
  test.shouldThrowError( () => voc.phrasesAdd( 1 ) )
  test.shouldThrowError( () => voc.phrasesAdd( [ 1 ] ) )
  test.shouldThrowError( () => voc.phrasesAdd( [ { phrase : 'executable' } ] ) )

  var voc = new _.Vocabulary({ overriding : 0 });
  voc.phrasesAdd( 'project act' );
  test.shouldThrowError( () => voc.phrasesAdd( 'project act' ) )
}

//

function phraseParse( test )
{
  let voc = new _.Vocabulary();

  test.case = 'default delimeter';

  var phrase = '';
  var got = voc.phraseParse( phrase );
  var expected = { phrase : '', words : [] };
  test.identical( got, expected );

  var phrase = 'project';
  var got = voc.phraseParse( phrase );
  var expected = { phrase : 'project', words : [ 'project' ] };
  test.identical( got, expected );

  var phrase = 'project a';
  var got = voc.phraseParse( phrase );
  var expected = { phrase : 'project a', words : [ 'project', 'a' ] };
  test.identical( got, expected );

  var phrase = ' project a b  ';
  var got = voc.phraseParse( phrase );
  var expected = { phrase : 'project a b', words : [ 'project', 'a', 'b' ] };
  test.identical( got, expected );

  test.case = 'custom delimeter';

  voc.lookingDelimeter = '.';

  var phrase = '';
  var got = voc.phraseParse( phrase );
  var expected = { phrase : '', words : [] };
  test.identical( got, expected );

  var phrase = 'project';
  var got = voc.phraseParse( phrase );
  var expected = { phrase : 'project', words : [ 'project' ] };
  test.identical( got, expected );

  var phrase = '  project  ';
  var got = voc.phraseParse( phrase );
  var expected = { phrase : 'project', words : [ 'project' ] };
  test.identical( got, expected );

  var phrase = 'project.a';
  var got = voc.phraseParse( phrase );
  var expected = { phrase : 'project a', words : [ 'project', 'a' ] };
  test.identical( got, expected );

  var phrase = ' project.a ';
  var got = voc.phraseParse( phrase );
  var expected = { phrase : 'project a', words : [ 'project', 'a' ] };
  test.identical( got, expected );

  var phrase = ' . project . a . b . ';
  var got = voc.phraseParse( phrase );
  var expected = { phrase : 'project a b', words : [ 'project', 'a', 'b' ] };
  test.identical( got, expected );

  var phrase = ' .. project .. a .. b  .. ';
  var got = voc.phraseParse( phrase );
  var expected = { phrase : 'project a b', words : [ 'project', 'a', 'b' ] };
  test.identical( got, expected );

  test.case = 'custom delimeter as option';
  voc = new _.Vocabulary();

  var phrase = '';
  var got = voc.phraseParse({ phrase : phrase , delimeter : '.' });
  var expected = { phrase : '', words : [] };
  test.identical( got, expected );

  var phrase = 'project';
  var got = voc.phraseParse({ phrase : phrase , delimeter : '.' });
  var expected = { phrase : 'project', words : [ 'project' ] };
  test.identical( got, expected );

  var phrase = '  project  ';
  var got = voc.phraseParse({ phrase : phrase , delimeter : '.' });
  var expected = { phrase : 'project', words : [ 'project' ] };
  test.identical( got, expected );

  var phrase = 'project.a';
  var got = voc.phraseParse({ phrase : phrase , delimeter : '.' });
  var expected = { phrase : 'project a', words : [ 'project', 'a' ] };
  test.identical( got, expected );

  var phrase = ' project.a ';
  var got = voc.phraseParse({ phrase : phrase , delimeter : '.' });
  var expected = { phrase : 'project a', words : [ 'project', 'a' ] };
  test.identical( got, expected );

  var phrase = ' . project . a . b . ';
  var got = voc.phraseParse({ phrase : phrase , delimeter : '.' });
  var expected = { phrase : 'project a b', words : [ 'project', 'a', 'b' ] };
  test.identical( got, expected );

  var phrase = ' .. project .. a .. b  .. ';
  var got = voc.phraseParse({ phrase : phrase , delimeter : '.' });
  var expected = { phrase : 'project a b', words : [ 'project', 'a', 'b' ] };
  test.identical( got, expected );

}


//

function subPhrase( test )
{
  test.case = 'remove part of a phrase';
  var vocabulary = new wVocabulary();

  /* strings */

  var got = vocabulary.subPhrase( '', '' );
  var expected = '';
  test.identical( got, expected );

  var got = vocabulary.subPhrase( 'project', '' );
  var expected = 'project';
  test.identical( got, expected );

  var got = vocabulary.subPhrase( 'project', 'xxx' );
  var expected = 'project';
  test.identical( got, expected );

  var got = vocabulary.subPhrase( 'project act2', 'act2' );
  var expected = 'project';
  test.identical( got, expected );

  var got = vocabulary.subPhrase( 'project act2 abc', 'abc' );
  var expected = 'project act2';
  test.identical( got, expected );

  var got = vocabulary.subPhrase( '  project   act2   ', 'act2' );
  var expected = 'project';
  test.identical( got, expected );

  /* arrays */

  var got = vocabulary.subPhrase( [ 'project', 'act2' ], 'act2' );
  var expected = 'project';
  test.identical( got, expected );

  var got = vocabulary.subPhrase( [ 'project', 'act2', 'abc' ], [ 'act2', 'abc' ]);
  var expected = 'project';
  test.identical( got, expected );

  var got = vocabulary.subPhrase( [ 'project', 'act2', 'abc' ], [ 'act2', 'xxx' ]);
  var expected = 'project act2 abc';
  test.identical( got, expected );

  var got = vocabulary.subPhrase( 'project act2 abc', [ 'act2', 'abc' ]);
  var expected = 'project';
  test.identical( got, expected );

  var got = vocabulary.subPhrase( [ 'project', 'act2   '], [ 'act2' ] );
  var expected = 'project';
  test.identical( got, expected );

  /**/

  if( !Config.debug )
  return

  test.shouldThrowError( () => vocabulary.subPhrase() );
  test.shouldThrowError( () => vocabulary.subPhrase( 1, '' ) );
  test.shouldThrowError( () => vocabulary.subPhrase( '', 1 ) );

}

//

function subjectDescriptorForWithClause( test )
{
  test.case = 'subject as string';
  var vocabulary = new wVocabulary();
  var phrase = 'project act2'
  vocabulary.phrasesAdd( phrase );

  /**/

  var got = vocabulary.subjectDescriptorForWithClause( '' );
  var expected =
  [
    {
      words : [],
      slicePhrase : '',
      wholePhrase : 'project act2',
      subPhrase : 'project act2',
      phraseDescriptor :
      {
        phrase : 'project act2',
        hint : 'project act2',
        words : [ 'project', 'act2' ],
        executable : null
      },
      kind : 'subject'
    }
  ]
  test.identical( got, expected );

  /**/

  var got = vocabulary.subjectDescriptorForWithClause( 'xxx' );
  var expected = [];
  test.identical( got, expected );

  /**/

  var subject = 'act2';
  var got = vocabulary.subjectDescriptorForWithClause( subject );
  var expected =
  [
    {
      words : [ 'act2' ],
      slicePhrase : 'act2',
      wholePhrase : 'project act2',
      subPhrase : 'project',
      phraseDescriptor :
      {
        phrase : 'project act2',
        hint : 'project act2',
        words : [ 'project', 'act2' ],
        executable : null
      },
      kind : 'subject'
    }
  ]
  test.identical( got, expected );

  /**/

  var subject = 'project';
  var got = vocabulary.subjectDescriptorForWithClause( subject );
  var expected =
  [
    {
      words : [ 'project' ],
      slicePhrase : 'project',
      wholePhrase : 'project act2',
      subPhrase : 'act2',
      phraseDescriptor :
      {
        phrase : 'project act2',
        hint : 'project act2',
        words : [ 'project', 'act2' ],
        executable : null
      },
      kind : 'subject'
    }
  ]
  test.identical( got, expected );

  /**/

  test.case = 'subject as array';
  var subject = [ 'project', 'act2' ];
  var got = vocabulary.subjectDescriptorForWithClause( subject );
  var expected =
  [
    {
      words : [ 'project', 'act2' ],
      slicePhrase : 'project act2',
      wholePhrase : 'project act2',
      subPhrase : '',
      phraseDescriptor :
      {
        phrase : 'project act2',
        hint : 'project act2',
        words : [ 'project', 'act2' ],
        executable : null
      },
      kind : 'subject'
    }
  ]
  test.identical( got, expected );

  /**/

  test.case = 'clausing';
  let onPdMake = ( src ) => src;
  var vocabulary = new wVocabulary({ clausing : 1, onPhraseDescriptorMake : onPdMake });
  var pd =
  {
    phrase : 'project act act2',
    clauseLimit : 2,
    hint : 'project act',
    executable : null
  }
  vocabulary.phraseAdd
  ({
    phrase : 'project act act1',
    clauseLimit : null,
    hint : 'project act',
    executable : null
  });
  vocabulary.phraseAdd
  ({
    phrase : 'project act act2',
    clauseLimit : null,
    hint : 'project act',
    executable : null
  });
  vocabulary.phraseAdd
  ({
    phrase : 'project act act3',
    clauseLimit : null,
    hint : 'project act',
    executable : null
  });

  /**/

  var got = vocabulary.subjectDescriptorForWithClause( '' );
  logger.log( _.toStr( got, { levels : 3} ) )
  var expected =
  [
    {
      words : [ 'project' ],
      phrase : 'project',
      subjectWords : [],
      subjectPhrase : '',
      subPhrase : 'project',
      descriptors : vocabulary.descriptorArray,
      kind : 'clause'
    },
    {
      words : [ 'act' ],
      phrase : 'act',
      subjectWords : [],
      subjectPhrase : '',
      subPhrase : 'act',
      descriptors : vocabulary.descriptorArray,
      kind : 'clause'
    }
  ]

  test.contains( got, expected );

  /**/

  if( !Config.debug )
  return

  test.shouldThrowError( () => vocabulary.subjectDescriptorForWithClause() );
  test.shouldThrowError( () => vocabulary.subjectDescriptorForWithClause( 1 ) );
}

//

function subjectsFilter( test )
{
  let voc = new _.Vocabulary();
  let phrases =
  [
    'project act1',
  ]
  voc.phrasesAdd( phrases );

  let subjects =
  [
    {
      words : [],
      slicePhrase : '',
      wholePhrase : 'project act1',
      subPhrase : 'project act1',
      phraseDescriptor :
      {
        phrase : 'project act1',
        hint : 'project act1',
        executable : null,
        words : [ 'project', 'act1' ]
      },
      kind : 'subject'
    },
    {
      words : [ 'project' ],
      slicePhrase : 'project',
      wholePhrase : 'project act1',
      subPhrase : 'act1',
      phraseDescriptor :
      {
        phrase : 'project act1',
        hint : 'project act1',
        executable : null,
        words : [ 'project', 'act1' ]
      },
      kind : 'subject'
    },
    {
      words : [ 'act1' ],
      slicePhrase : 'act1',
      wholePhrase : 'project act1',
      subPhrase : 'project',
      phraseDescriptor :
      {
        phrase : 'project act1',
        hint : 'project act1',
        executable : null,
        words : [ 'project', 'act1' ]
      },
      kind : 'subject'
    },
    {
      words : [ 'project', 'act1' ],
      slicePhrase : 'project act1',
      wholePhrase : 'project act1',
      subPhrase : '',
      phraseDescriptor :
      {
        phrase : 'project act1',
        hint : 'project act1',
        executable : null,
        words : [ 'project', 'act1' ]
      },
      kind : 'subject'
    }
  ];

  test.case = 'slicePhrase';

  var src = 'project';
  var selector = { slicePhrase : src }
  var got = voc.subjectsFilter( subjects, selector )
  var expected = subjects[ 1 ];
  test.identical( got, _.arrayAs( expected ) );

  var src = 'act1';
  var selector = { slicePhrase : src }
  var got = voc.subjectsFilter( subjects, selector )
  var expected = subjects[ 2 ];
  test.identical( got, _.arrayAs( expected ) );

  var src = 'proj';
  var selector = { slicePhrase : src }
  var got = voc.subjectsFilter( subjects, selector )
  var expected = [];
  test.identical( got, expected );

  //

  test.case = 'wholePhrase';

  var src = 'project';
  var selector = { wholePhrase : src }
  var got = voc.subjectsFilter( subjects, selector )
  var expected = [];
  test.identical( got, _.arrayAs( expected ) );

  var src = 'act1';
  var selector = { wholePhrase : src }
  var got = voc.subjectsFilter( subjects, selector )
  var expected = [];
  test.identical( got, _.arrayAs( expected ) );

  var src = 'project act1';
  var selector = { wholePhrase : src }
  var got = voc.subjectsFilter( subjects, selector )
  var expected = subjects;
  test.identical( got, expected );

  test.case = 'subPhrase';

  var src = 'sub';
  var selector = { subPhrase : src }
  var got = voc.subjectsFilter( subjects, selector )
  var expected = [];
  test.identical( got, _.arrayAs( expected ) );

  var src = '';
  var selector = { subPhrase : src }
  var got = voc.subjectsFilter( subjects, selector )
  var expected = subjects[ 3 ];
  test.identical( got, _.arrayAs( expected ) );

  var src = 'project';
  var selector = { subPhrase : src }
  var got = voc.subjectsFilter( subjects, selector )
  var expected = subjects[ 2 ];
  test.identical( got, _.arrayAs( expected ) );

  var src = 'act1';
  var selector = { subPhrase : src }
  var got = voc.subjectsFilter( subjects, selector )
  var expected = subjects[ 1 ];
  test.identical( got, _.arrayAs( expected ) );
}

//

function helpForSubject( test )
{
  var vocabulary = new wVocabulary();
  var phrases =
  [
    'project act1',
    'project act2',
    'project act3',
  ]
  vocabulary.phrasesAdd( phrases );

  /**/

  var got = vocabulary.helpForSubject( '' );
  var expected =
  [
    '.project.act1 - project act1',
    '.project.act2 - project act2',
    '.project.act3 - project act3'
  ]
  test.identical( got, expected );

  /**/

  var got = vocabulary.helpForSubject( 'some subject' );
  var expected = '';
  test.identical( got, expected );

  /**/

  var got = vocabulary.helpForSubject( 'project' );
  var expected =
  [
    '.project.act1 - project act1',
    '.project.act2 - project act2',
    '.project.act3 - project act3'
  ]
  test.identical( got, expected );

  /**/

  var got = vocabulary.helpForSubject( 'act1' );
  var expected =
  [
    '.project.act1 - project act1',
  ]
  test.identical( got, expected );

  /**/

  var got = vocabulary.helpForSubject( 'act3' );
  var expected =
  [
    '.project.act3 - project act3'
  ]
  test.identical( got, expected );

  /**/

  var got = vocabulary.helpForSubject( [ 'project', 'act1' ]);
  var expected =
  [
    '.project.act1 - project act1',
  ]
  test.identical( got, expected );

  /**/

  var got = vocabulary.helpForSubject( [ 'project', 'act3' ]);
  var expected =
  [
    '.project.act3 - project act3'
  ]
  test.identical( got, expected );
}

//

function wordsComplySubject( test )
{
  var vocabulary = new wVocabulary();
  var wordsComplySubject = vocabulary.wordsComplySubject;

  /**/

  test.is( !wordsComplySubject( [], [ 'a' ] ) );
  test.is( wordsComplySubject( [ 'a' ], [] ) );
  test.is( wordsComplySubject( [], [] ) );
  test.is( wordsComplySubject( [], [] ) );
  test.is( wordsComplySubject( [ 'a', 'b' ], [ 'a', 'b' ] ) );
  test.is( wordsComplySubject( [ 'a', 'b' ], [] ) );
  test.is( wordsComplySubject( [ 'a', 'b' ], [ '' ] ) );
  test.is( !wordsComplySubject( [ 'a', 'b' ], [ 'b', 'c' ] ) );
  test.is( wordsComplySubject( [ 'a', 'b', 'c' ], [ 'b', 'c' ] ) );
  test.is( wordsComplySubject( [ 'a', 'b', 'c' ], [ 'b' ] ) );
  test.is( wordsComplySubject( [ 'a', 'b', 'c', 'x' ], [ 'b', 'c' ] ) );
  test.is( !wordsComplySubject( [ 'a', 'b', 'c' ], [ 'b', 'c', 'x' ] ) );
  test.is( !wordsComplySubject( [ 'a', 'b', 'c' ], [ 'b', 'c', 'x', 'y' ] ) );

  /**/

  if( !Config.debug )
  return

  test.shouldThrowError( () => wordsComplySubject() );
  test.shouldThrowError( () => wordsComplySubject( '', [] ) );
  test.shouldThrowError( () => wordsComplySubject( [], '' ) );
}

//

var Self =
{

  name : 'Tools/mid/Vocabulary',
  silencing : 1,

  context :
  {
    makeWordMap : makeWordMap,
    makeDescriptorArray : makeDescriptorArray,
    makeDescriptorMap : makeDescriptorMap,
    makeSubjectMap : makeSubjectMap,
  },

  tests :
  {
    phraseAdd : phraseAdd,
    phrasesAdd : phrasesAdd,
    phraseParse : phraseParse,
    subPhrase : subPhrase,
    subjectDescriptorForWithClause : subjectDescriptorForWithClause,
    subjectsFilter : subjectsFilter,
    helpForSubject : helpForSubject,
    wordsComplySubject : wordsComplySubject
  }

}

//

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

})( );
