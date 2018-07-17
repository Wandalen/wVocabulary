( function _Vocabulary_test_s_( ) {

'use strict'; /**/

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
          var descriptor = descriptorMap[ p ];
          if( wordMap[ w ].indexOf( descriptor ) === -1 )
          wordMap[ w ].push( descriptor );
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
      words : _.strSplit( p )
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
      subject.descriptor = d;
      subject.kind = 'subject';
      subject.phrase = w;
      subject.subPhrase = sub;
      subject.words = _.strSplit( w );

      subjectMap[ w ].push( subject );
    })
  })

  return subjectMap;
}

// --
// Tests
// --

function phrasesAdd( test )
{
  var context = this;

  test.case = 'phrase as string';
  var vocabulary = new wVocabulary();

  var phrase = 'project act2';
  vocabulary.phrasesAdd( phrase );

  var phraseArray = [ phrase ];
  var descriptorArray = context.makeDescriptorArray( phraseArray );
  var descriptorMap = context.makeDescriptorMap( descriptorArray );
  var wordMap = context.makeWordMap( phraseArray, descriptorArray, descriptorMap );
  var subjectMap = context.makeSubjectMap( descriptorArray );

  test.identical( vocabulary.phraseArray, phraseArray );
  test.identical( vocabulary.descriptorArray, descriptorArray );
  test.identical( vocabulary.descriptorMap, descriptorMap );
  test.identical( vocabulary.wordMap, wordMap );
  test.identical( vocabulary.subjectMap, subjectMap );

  /**/

  test.case = 'phrases in array';
  var vocabulary = new wVocabulary();

  var phrases =
  [
    'project act1',
    'project act2',
    'project act3',
  ]

  vocabulary.phrasesAdd( phrases );

  var phraseArray = phrases;
  var descriptorArray = context.makeDescriptorArray( phrases );
  var descriptorMap = context.makeDescriptorMap( descriptorArray );
  var wordMap = context.makeWordMap( phraseArray, descriptorArray, descriptorMap );
  var subjectMap = context.makeSubjectMap( descriptorArray );

  test.identical( vocabulary.phraseArray, phraseArray );
  test.identical( vocabulary.descriptorArray, descriptorArray );
  test.identical( vocabulary.descriptorMap, descriptorMap );
  test.identical( vocabulary.wordMap, wordMap );
  test.identical( vocabulary.subjectMap, subjectMap );

  /**/

  test.case = 'phrase already exists, override off';
  var vocabulary = new wVocabulary({ override : 0 });
  var phrase = 'project act1';
  vocabulary.phrasesAdd( phrase );
  test.shouldThrowError( () => vocabulary.phrasesAdd( phrase ) )

  /**/

  test.case = 'phrase already exists, override on';
  var vocabulary = new wVocabulary({ override : 1 });
  var phrase = 'project act1';
  vocabulary.phrasesAdd( phrase );
  vocabulary.phrasesAdd( phrase );

  var phraseArray = [ phrase ];
  var descriptorArray = context.makeDescriptorArray( phraseArray );
  var descriptorMap = context.makeDescriptorMap( descriptorArray );
  var wordMap = context.makeWordMap( phraseArray, descriptorArray, descriptorMap );
  var subjectMap = context.makeSubjectMap( descriptorArray );

  test.identical( vocabulary.phraseArray, phraseArray );
  test.identical( vocabulary.descriptorArray, descriptorArray );
  test.identical( vocabulary.descriptorMap, descriptorMap );
  test.identical( vocabulary.wordMap, wordMap );
  test.identical( vocabulary.subjectMap, subjectMap );

  /**/

  test.case = 'phrase already exists, usingFreeze off';
  var vocabulary = new wVocabulary({ usingFreeze : 0 });
  var phrase = 'project act1';
  vocabulary.phrasesAdd( phrase );
  test.mustNotThrowError( () =>
  {
    vocabulary.descriptorArray[ 0 ].xxx = 1
  });

  /**/

  test.case = 'phrase already exists, usingFreeze on';
  var vocabulary = new wVocabulary({ usingFreeze : 1 });
  var phrase = 'project act1';
  vocabulary.phrasesAdd( phrase );
  test.shouldThrowError( () =>
  {
    vocabulary.descriptorArray[ 0 ].xxx = 1
  })

  /**/

  if( !Config.debug )
  return

  test.shouldThrowError( () => vocabulary.phrasesAdd() );
  test.shouldThrowError( () => vocabulary.phrasesAdd( 1 ) );
  test.shouldThrowError( () => vocabulary.phrasesAdd( '', '' ) );
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

function phrasesForSubject( test )
{
  test.case = 'subject as string';
  var vocabulary = new wVocabulary();
  var phrase = 'project act2'
  vocabulary.phrasesAdd( phrase );

  /**/

  var got = vocabulary.phrasesForSubject( '' );
  var descriptor =
  {
    phrase : phrase,
    words : _.strSplit( phrase )
  };
  var expected =
  [{
    descriptor : descriptor,
    phrase : phrase,
    words : _.strSplit( phrase )
  }];
  test.identical( got, expected );

  /**/

  var got = vocabulary.phrasesForSubject( 'xxx' );
  var expected = [];
  test.identical( got, expected );

  /**/

  var subject = 'act2';
  var got = vocabulary.phrasesForSubject( subject );
  var descriptor =
  {
    phrase : phrase,
    words : _.strSplit( phrase )
  };
  var subPhrase = vocabulary.subPhrase( phrase, subject );
  var expected =
  [{
    descriptor : descriptor,
    kind : 'subject',
    phrase : subject,
    subPhrase : subPhrase,
    words : [ subject ]
  }];
  test.identical( got, expected );

  /**/

  var subject = 'project';
  var got = vocabulary.phrasesForSubject( subject );
  var descriptor =
  {
    phrase : phrase,
    words : _.strSplit( phrase )
  };
  var subPhrase = vocabulary.subPhrase( phrase, subject );
  var expected =
  [{
    descriptor : descriptor,
    kind : 'subject',
    phrase : subject,
    subPhrase : subPhrase,
    words : [ subject ]
  }];
  test.identical( got, expected );

  /**/

  test.case = 'subject as array';
  var subject = [ 'project', 'act2' ];
  var got = vocabulary.phrasesForSubject( subject );
  var descriptor =
  {
    phrase : phrase,
    words : _.strSplit( phrase )
  };
  var expected =
  [{
    descriptor : descriptor,
    kind : 'subject',
    phrase : subject.join( ' ' ),
    subPhrase : '',
    words : subject
  }];
  test.identical( got, expected );

  /**/

  if( !Config.debug )
  return

  test.shouldThrowError( () => vocabulary.phrasesForSubject() );
  test.shouldThrowError( () => vocabulary.phrasesForSubject( 1 ) );
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
    '.project.act1 - Project act1.',
    '.project.act2 - Project act2.',
    '.project.act3 - Project act3.'
  ]
  test.identical( got, expected );

  /**/

  var got = vocabulary.helpForSubject( 'xxx' );
  var expected = '';
  test.identical( got, expected );

  /**/

  var got = vocabulary.helpForSubject( 'project' );
  var expected =
  [
    '.project.act1 - Project act1.',
    '.project.act2 - Project act2.',
    '.project.act3 - Project act3.'
  ]
  test.identical( got, expected );

  /**/

  var got = vocabulary.helpForSubject( 'act1' );
  var expected =
  [
    '.project.act1 - Project act1.',
  ]
  test.identical( got, expected );

  /**/

  var got = vocabulary.helpForSubject( 'act3' );
  var expected =
  [
    '.project.act3 - Project act3.'
  ]
  test.identical( got, expected );

  /**/

  var got = vocabulary.helpForSubject( [ 'project', 'act1' ]);
  var expected =
  [
    '.project.act1 - Project act1.',
  ]
  test.identical( got, expected );

  /**/

  var got = vocabulary.helpForSubject( [ 'project', 'act3' ]);
  var expected =
  [
    '.project.act3 - Project act3.'
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
    phrasesAdd : phrasesAdd,
    subPhrase : subPhrase,
    phrasesForSubject : phrasesForSubject,
    helpForSubject : helpForSubject,
    wordsComplySubject : wordsComplySubject
  }

}

//

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

})( );
