( function _Vocabulary_test_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  let _ = require( '../../../../wtools/Tools.s' );
  require( '../vocabulary/Vocabulary.s' );
  _.include( 'wTesting' );
}

let _ = _global_.wTools;
var vocabulary = new _.Vocabulary();

// --
// context
// --

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
      } )
    } )
  } )

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
      words : _.strSplitNonPreserving( { src : p } ),
    }
    return d;
  } );
}

//

function makeDescriptorMap( makeDescriptorArray )
{
  var descriptorMap = Object.create( null );

  makeDescriptorArray.forEach( ( d ) =>
  {
    descriptorMap[ d.phrase ] = d;
    return d;
  } );

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
      subject.words = _.strSplitNonPreserving( { src : w } );

      subjectMap[ w ].push( subject );
    } )
  } )

  return subjectMap;
}

// --
// tests
// --

/*
qqq : split test cases, please
*/

function phraseAdd( test )
{

  test.case = 'string'
  var c = make();
  var voc = new _.Vocabulary();
  voc.phraseAdd( 'project act' );
  test.identical( voc.phraseArray, c.phraseArray );
  test.identical( voc.descriptorArray, c.descriptorArray );
  test.identical( voc.descriptorMap, c.descriptorMap );
  test.identical( voc.wordMap, c.wordMap );
  test.identical( voc.subjectMap, c.subjectMap );;
  test.identical( voc.clausing, 0 );
  test.identical( voc.clauseMap, {} );
  test.identical( voc.clauseForSubjectMap, {} );

  test.case = 'array'
  var c = make();
  var voc = new _.Vocabulary();
  voc.phraseAdd( [ 'project act', 'executable' ] );
  c.pd.executable = 'executable';
  test.identical( voc.phraseArray, c.phraseArray );
  test.identical( voc.descriptorArray, c.descriptorArray );
  test.identical( voc.descriptorMap, c.descriptorMap );
  test.identical( voc.wordMap, c.wordMap );
  test.identical( voc.subjectMap, c.subjectMap );;
  test.identical( voc.clausing, 0 );
  test.identical( voc.clauseMap, {} );
  test.identical( voc.clauseForSubjectMap, {} );

  test.case = 'array'
  var c = make();
  function executable(){}
  var voc = new _.Vocabulary();
  voc.phraseAdd( [ 'project act', { e : executable, h : 'function' } ] );
  c.pd.executable = executable;
  c.pd.hint = 'function';
  test.identical( voc.phraseArray, c.phraseArray );
  test.identical( voc.descriptorArray, c.descriptorArray );
  test.identical( voc.descriptorMap, c.descriptorMap );
  test.identical( voc.wordMap, c.wordMap );
  test.identical( voc.subjectMap, c.subjectMap );;
  test.identical( voc.clausing, 0 );
  test.identical( voc.clauseMap, {} );
  test.identical( voc.clauseForSubjectMap, {} );
  // c.pd.executable = null; qqq : !
  // c.pd.hint = c.pd.phrase;

  test.case = 'override existing phrase'
  var c = make();
  var pd =
  {
    phrase : 'project.act',
    words : [ 'project', 'act' ],
    hint : 'project act',
    executable : null
  }
  var descriptorArray = [ c.pd ]
  var voc = new _.Vocabulary( { overriding : 1 } );
  voc.phraseAdd( 'project act' );
  voc.phraseAdd( 'project act' );
  test.identical( voc.phraseArray, c.phraseArray );;
  test.identical( voc.descriptorArray, c.descriptorArray );;
  test.identical( voc.descriptorMap, c.descriptorMap );;
  test.identical( voc.wordMap, c.wordMap );;
  test.identical( voc.subjectMap, c.subjectMap );;
  test.identical( voc.clausing, 0 );
  test.identical( voc.clauseMap, {} );
  test.identical( voc.clauseForSubjectMap, {} );

  test.case = 'lock descriptor: on'
  var c = make();
  var voc = new _.Vocabulary( { freezing : 1 } );
  voc.phraseAdd( 'project act' );
  test.identical( voc.descriptorArray[ 0 ], voc.descriptorMap[ 'project.act' ] );
  test.identical( voc.descriptorMap[ 'project.act' ], c.pd );
  test.shouldThrowErrorOfAnyKind( () =>
  {
    voc.descriptorMap[ 'project act' ].someField = 1;
  })

  test.case = 'lock descriptor: off'
  var c = make();
  var voc = new _.Vocabulary( { freezing : 0 } );
  voc.phraseAdd( 'project act' );
  test.identical( voc.descriptorArray[ 0 ], voc.descriptorMap[ 'project.act' ] );
  test.identical( voc.descriptorMap[ 'project.act' ], c.pd );
  test.mustNotThrowError( () =>
  {
    voc.descriptorMap[ 'project.act' ].someField = 1;
  })

  /* - */

  if( !Config.debug )
  return;

  var voc = new _.Vocabulary();
  test.shouldThrowErrorOfAnyKind( () => voc.phraseAdd( 1 ) )
  test.shouldThrowErrorOfAnyKind( () => voc.phraseAdd( { phrase : 'executable' } ) )

  var voc = new _.Vocabulary( { overriding : 0 } );
  voc.phrasesAdd( 'project act' );
  test.shouldThrowErrorOfAnyKind( () => voc.phraseAdd( 'project act' ) )

  function make()
  {
    let c = Object.create( null );
    c.pd =
    {
      phrase : 'project.act',
      words : [ 'project', 'act' ],
      hint : 'project act',
      executable : null
    }
    c.phraseArray = [ 'project.act' ];
    c.descriptorArray = [ c.pd ]
    c.descriptorMap =
    {
      'project.act' : c.pd
    }
    c.wordMap =
    {
      'project' : [ c.pd ],
      'act' : [ c.pd ],
    }
    c.subjectMap =
    {
      '' :
     [
       {
         words : [],
         slicePhrase : '',
         wholePhrase : 'project.act',
         subPhrase : 'project.act',
         phraseDescriptor : c.pd,
         kind : 'subject'
       }
     ],
      'project' :
      [
        {
          words : [ 'project' ],
          slicePhrase : 'project',
          wholePhrase : 'project.act',
          subPhrase : 'act',
          phraseDescriptor : c.pd,
          kind : 'subject'
        }
      ],
      'act' :
      [
        {
          words : [ 'act' ],
          slicePhrase : 'act',
          wholePhrase : 'project.act',
          subPhrase : 'project',
          phraseDescriptor : c.pd,
          kind : 'subject'
        }
      ],
      'project.act' :
      [
        {
          words : [ 'project', 'act' ],
          slicePhrase : 'project.act',
          wholePhrase : 'project.act',
          subPhrase : '',
          phraseDescriptor : c.pd,
          kind : 'subject'
        }
      ]
    }
    return c;
  }
}

//

function phrasesAdd( test )
{

  test.case = 'string'
  var c = make();
  var voc = new _.Vocabulary();
  voc.phrasesAdd( 'project act' );
  test.identical( voc.phraseArray, c.phraseArray );
  test.identical( voc.descriptorArray, c.descriptorArray );
  test.identical( voc.descriptorMap, c.descriptorMap );
  test.identical( voc.wordMap, c.wordMap );
  test.identical( voc.subjectMap, c.subjectMap );;
  test.identical( voc.clausing, 0 );
  test.identical( voc.clauseMap, {} );
  test.identical( voc.clauseForSubjectMap, {} );

  test.case = 'array of strings'
  var c = make();
  var voc = new _.Vocabulary();
  voc.phrasesAdd( [ 'project act' ] );
  test.identical( voc.phraseArray, c.phraseArray );
  test.identical( voc.descriptorArray, c.descriptorArray );
  test.identical( voc.descriptorMap, c.descriptorMap );
  test.identical( voc.wordMap, c.wordMap );
  test.identical( voc.subjectMap, c.subjectMap );;
  test.identical( voc.clausing, 0 );
  test.identical( voc.clauseMap, {} );
  test.identical( voc.clauseForSubjectMap, {} );

  test.case = 'array of arrays'
  var c = make();
  var voc = new _.Vocabulary();
  voc.phrasesAdd( [ [ 'project act', 'executable' ] ] );
  c.pd.executable = 'executable';
  test.identical( voc.phraseArray, c.phraseArray );
  test.identical( voc.descriptorArray, c.descriptorArray );
  test.identical( voc.descriptorMap, c.descriptorMap );
  test.identical( voc.wordMap, c.wordMap );
  test.identical( voc.subjectMap, c.subjectMap );;
  test.identical( voc.clausing, 0 );
  test.identical( voc.clauseMap, {} );
  test.identical( voc.clauseForSubjectMap, {} );
  c.pd.executable = null;

  test.case = 'object'
  var c = make();
  var voc = new _.Vocabulary();
  function executable(){}
  var phrase = [ 'project act', { e : executable, h : 'function' } ];
  voc.phrasesAdd( [ phrase ] );
  c.pd.executable = executable;
  c.pd.hint = 'function';
  test.identical( voc.phraseArray, c.phraseArray );
  test.identical( voc.descriptorArray, c.descriptorArray );
  test.identical( voc.descriptorMap, c.descriptorMap );
  test.identical( voc.wordMap, c.wordMap );
  test.identical( voc.subjectMap, c.subjectMap );;
  test.identical( voc.clausing, 0 );
  test.identical( voc.clauseMap, {} );
  test.identical( voc.clauseForSubjectMap, {} );
  c.pd.executable = null;
  c.pd.hint = c.pd.phrase;

  test.case = 'object'
  var c = make();
  var voc = new _.Vocabulary();
  function executable(){}
  var phrase = { 'project act' : { e : executable, h : 'function' } };
  voc.phrasesAdd( phrase );
  c.pd.executable = executable;
  c.pd.hint = 'function';
  test.identical( voc.phraseArray, c.phraseArray );
  test.identical( voc.descriptorArray, c.descriptorArray );
  test.identical( voc.descriptorMap, c.descriptorMap );
  test.identical( voc.wordMap, c.wordMap );
  test.identical( voc.subjectMap, c.subjectMap );;
  test.identical( voc.clausing, 0 );
  test.identical( voc.clauseMap, {} );
  test.identical( voc.clauseForSubjectMap, {} );
  c.pd.executable = null;
  c.pd.hint = c.pd.phrase;

  test.case = 'several phrases array'
  var c = make();
  var voc = new _.Vocabulary();
  voc.phrasesAdd
  ( [
    'phrase1 act',
    'phrase2 act'
  ] );
  test.identical( voc.phraseArray, [ 'phrase1.act', 'phrase2.act' ] )
  test.identical( voc.descriptorArray.length, 2 )
  test.identical( _.mapOwnKeys( voc.descriptorMap ), [ 'phrase1.act', 'phrase2.act' ] )
  test.identical( _.mapOwnKeys( voc.wordMap ), [ 'phrase1', 'act', 'phrase2' ] )
  test.identical( _.mapOwnKeys( voc.subjectMap ), [ '', 'phrase1', 'act', 'phrase1.act', 'phrase2', 'phrase2.act' ] )
  test.identical( voc.clausing, 0 );
  test.identical( voc.clauseMap, {} );
  test.identical( voc.clauseForSubjectMap, {} );

  test.case = 'several phrases object'
  var c = make();
  var voc = new _.Vocabulary();
  voc.phrasesAdd
  ({
    'phrase1 act' : 'executable1',
    'phrase2 act' : 'executable2'
  });
  test.identical( voc.phraseArray, [ 'phrase1.act', 'phrase2.act' ] )
  test.identical( voc.descriptorArray.length, 2 )
  test.identical( _.mapOwnKeys( voc.descriptorMap ), [ 'phrase1.act', 'phrase2.act' ] )
  test.identical( _.mapOwnKeys( voc.wordMap ), [ 'phrase1', 'act', 'phrase2' ] )
  test.identical( _.mapOwnKeys( voc.subjectMap ), [ '', 'phrase1', 'act', 'phrase1.act', 'phrase2', 'phrase2.act' ] )
  test.identical( voc.clausing, 0 );
  test.identical( voc.clauseMap, {} );
  test.identical( voc.clauseForSubjectMap, {} );

  test.case = 'override existing phrase'
  var c = make();
  var voc = new _.Vocabulary( { overriding : 1 } );
  voc.phrasesAdd( 'project act' );
  voc.phrasesAdd( 'project act' );
  test.identical( voc.phraseArray, c.phraseArray );
  test.identical( voc.descriptorArray, c.descriptorArray );
  test.identical( voc.descriptorMap, c.descriptorMap );
  test.identical( voc.wordMap, c.wordMap );
  test.identical( voc.subjectMap, c.subjectMap );;
  test.identical( voc.clausing, 0 );
  test.identical( voc.clauseMap, {} );
  test.identical( voc.clauseForSubjectMap, {} );

  test.case = 'lock descriptor: on'
  var c = make();
  var voc = new _.Vocabulary( { freezing : 1 } );
  voc.phrasesAdd( 'project act' );
  test.identical( voc.descriptorArray[ 0 ], voc.descriptorMap[ 'project.act' ] );
  test.identical( voc.descriptorMap[ 'project.act' ], c.pd );
  test.shouldThrowErrorOfAnyKind( () =>
  {
    voc.descriptorMap[ 'project.act' ].someField = 1;
  } )

  test.case = 'lock descriptor: off'
  var c = make();
  var voc = new _.Vocabulary( { freezing : 0 } );
  voc.phrasesAdd( 'project act' );
  test.identical( voc.descriptorArray[ 0 ], voc.descriptorMap[ 'project.act' ] );
  test.identical( voc.descriptorMap[ 'project.act' ], c.pd );
  test.mustNotThrowError( () =>
  {
    voc.descriptorMap[ 'project.act' ].someField = 1;
  } )

  if( !Config.debug )
  return;

  var voc = new _.Vocabulary();
  test.shouldThrowErrorOfAnyKind( () => voc.phrasesAdd( 1 ) )
  test.shouldThrowErrorOfAnyKind( () => voc.phrasesAdd( [ 1 ] ) )
  test.shouldThrowErrorOfAnyKind( () => voc.phrasesAdd( [ { phrase : 'executable' } ] ) )

  var voc = new _.Vocabulary( { overriding : 0 } );
  voc.phrasesAdd( 'project act' );
  test.shouldThrowErrorOfAnyKind( () => voc.phrasesAdd( 'project act' ) )

  function make()
  {
    var c = Object.create( null );
    c.pd =
    {
      phrase : 'project.act',
      words : [ 'project', 'act' ],
      hint : 'project act',
      executable : null
    }
    c.phraseArray = [ c.pd.phrase ];
    c.descriptorArray = [ c.pd ]
    c.descriptorMap =
    {
      'project.act' : c.pd
    }
    c.wordMap =
    {
      'project' : [ c.pd ],
      'act' : [ c.pd ],
    }
    c.subjectMap =
    {
      '' :
      [
        {
          words : [],
          slicePhrase : '',
          wholePhrase : 'project.act',
          subPhrase : 'project.act',
          phraseDescriptor : c.pd,
          kind : 'subject'
        }
      ],
      'project' :
      [
        {
          words : [ 'project' ],
          slicePhrase : 'project',
          wholePhrase : 'project.act',
          subPhrase : 'act',
          phraseDescriptor : c.pd,
          kind : 'subject'
        }
      ],
      'act' :
      [
        {
          words : [ 'act' ],
          slicePhrase : 'act',
          wholePhrase : 'project.act',
          subPhrase : 'project',
          phraseDescriptor : c.pd,
          kind : 'subject'
        }
      ],
      'project.act' :
      [ /* qqq : Yevhen review the file and do formatting accurately */
        {
          words : [ 'project', 'act' ],
          slicePhrase : 'project.act',
          wholePhrase : 'project.act',
          subPhrase : '',
          phraseDescriptor : c.pd,
          kind : 'subject'
        }
      ]
    }
    return c;
  }
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
  var expected = { phrase : 'project.a', words : [ 'project', 'a' ] };
  test.identical( got, expected );

  var phrase = ' project a b  ';
  var got = voc.phraseParse( phrase );
  var expected = { phrase : 'project.a.b', words : [ 'project', 'a', 'b' ] };
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
  var expected = { phrase : 'project.a', words : [ 'project', 'a' ] };
  test.identical( got, expected );

  var phrase = ' project.a ';
  var got = voc.phraseParse( phrase );
  var expected = { phrase : 'project.a', words : [ 'project', 'a' ] };
  test.identical( got, expected );

  var phrase = ' . project . a . b . ';
  var got = voc.phraseParse( phrase );
  var expected = { phrase : 'project.a.b', words : [ 'project', 'a', 'b' ] };
  test.identical( got, expected );

  var phrase = ' .. project .. a .. b  .. ';
  var got = voc.phraseParse( phrase );
  var expected = { phrase : 'project.a.b', words : [ 'project', 'a', 'b' ] };
  test.identical( got, expected );

  test.case = 'custom delimeter as option';
  voc = new _.Vocabulary();

  var phrase = '';
  var got = voc.phraseParse( { phrase, delimeter : '.' } );
  var expected = { phrase : '', words : [] };
  test.identical( got, expected );

  var phrase = 'project';
  var got = voc.phraseParse( { phrase, delimeter : '.' } );
  var expected = { phrase : 'project', words : [ 'project' ] };
  test.identical( got, expected );

  var phrase = '  project  ';
  var got = voc.phraseParse( { phrase, delimeter : '.' } );
  var expected = { phrase : 'project', words : [ 'project' ] };
  test.identical( got, expected );

  var phrase = 'project.a';
  var got = voc.phraseParse( { phrase, delimeter : '.' } );
  var expected = { phrase : 'project.a', words : [ 'project', 'a' ] };
  test.identical( got, expected );

  var phrase = ' project.a ';
  var got = voc.phraseParse( { phrase, delimeter : '.' } );
  var expected = { phrase : 'project.a', words : [ 'project', 'a' ] };
  test.identical( got, expected );

  var phrase = ' . project . a . b . ';
  var got = voc.phraseParse( { phrase, delimeter : '.' } );
  var expected = { phrase : 'project.a.b', words : [ 'project', 'a', 'b' ] };
  test.identical( got, expected );

  var phrase = ' .. project .. a .. b  .. ';
  var got = voc.phraseParse( { phrase, delimeter : '.' } );
  var expected = { phrase : 'project.a.b', words : [ 'project', 'a', 'b' ] };
  test.identical( got, expected );

}


//

function subPhrase( test )
{
  test.case = 'remove part of a phrase';
  var vocabulary = new _.Vocabulary();

  /* strings */

  var got = vocabulary.subPhrase( '', '' );
  var expected = '';
  test.identical( got, expected );

  var got = vocabulary.subPhrase( 'project', '' );
  var expected = 'project';
  test.identical( got, expected );

  var got = vocabulary.subPhrase( 'project', 'x' );
  var expected = 'project';
  test.identical( got, expected );

  var got = vocabulary.subPhrase( 'project act2', 'act2' );
  var expected = 'project';
  test.identical( got, expected );

  var got = vocabulary.subPhrase( 'project act2 abc', 'abc' );
  var expected = 'project act2';
  test.identical( got, expected );

  var got = vocabulary.subPhrase( '.project.act2.abc.', 'abc' );
  var expected = 'project.act2';
  test.identical( got, expected );

  var got = vocabulary.subPhrase( '.project.act2.abc.', 'act2' );
  var expected = 'project.abc';
  test.identical( got, expected );

  var got = vocabulary.subPhrase( '  project   act2   ', 'act2' );
  var expected = 'project';
  test.identical( got, expected );

  /* arrays */

  var got = vocabulary.subPhrase( [ 'project', 'act2' ], 'act2' );
  var expected = 'project';
  test.identical( got, expected );

  var got = vocabulary.subPhrase( [ 'project', 'act2', 'abc' ], [ 'act2', 'abc' ] );
  var expected = 'project';
  test.identical( got, expected );

  var got = vocabulary.subPhrase( [ 'project', 'act2', 'abc' ], [ 'act2', 'x' ] );
  var expected = 'project.act2.abc';
  test.identical( got, expected );

  var got = vocabulary.subPhrase( 'project.act2.abc', [ 'act2', 'abc' ] );
  var expected = 'project';
  test.identical( got, expected );

  var got = vocabulary.subPhrase( [ 'project', 'act2   ' ], [ 'act2' ] );
  var expected = 'project';
  test.identical( got, expected );

  /**/

  if( !Config.debug )
  return

  test.shouldThrowErrorOfAnyKind( () => vocabulary.subPhrase() );
  test.shouldThrowErrorOfAnyKind( () => vocabulary.subPhrase( 1, '' ) );
  test.shouldThrowErrorOfAnyKind( () => vocabulary.subPhrase( '', 1 ) );

}

//

function subjectDescriptorForWithClause( test )
{

  test.case = 'subject as string';
  var vocabulary = new _.Vocabulary();
  var phrase = 'project act2'
  vocabulary.phrasesAdd( phrase );

  /**/

  var got = vocabulary.subjectDescriptorForWithClause( '' );
  var expected =
  [
    {
      words : [],
      slicePhrase : '',
      wholePhrase : 'project.act2',
      subPhrase : 'project.act2',
      phraseDescriptor :
      {
        phrase : 'project.act2',
        hint : 'project act2',
        words : [ 'project', 'act2' ],
        executable : null
      },
      kind : 'subject'
    }
  ]
  test.identical( got, expected );

  /**/

  var got = vocabulary.subjectDescriptorForWithClause( 'x' );
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
      wholePhrase : 'project.act2',
      subPhrase : 'project',
      phraseDescriptor :
      {
        phrase : 'project.act2',
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
      wholePhrase : 'project.act2',
      subPhrase : 'act2',
      phraseDescriptor :
      {
        phrase : 'project.act2',
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
      slicePhrase : 'project.act2',
      wholePhrase : 'project.act2',
      subPhrase : '',
      phraseDescriptor :
      {
        phrase : 'project.act2',
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
  var vocabulary = new _.Vocabulary( { clausing : 1, onPhraseDescriptorMake : onPdMake } );
  var pd =
  {
    phrase : 'project.act.act2',
    clauseLimit : 2,
    hint : 'project act',
    executable : null
  }
  vocabulary.phraseAdd
  ({
    phrase : '.project.act.act1',
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
  logger.log( _.toStr( got, { levels : 3 } ) )
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

  test.shouldThrowErrorOfAnyKind( () => vocabulary.subjectDescriptorForWithClause() );
  test.shouldThrowErrorOfAnyKind( () => vocabulary.subjectDescriptorForWithClause( 1 ) );
}

//

function subjectDescriptorFor( test )
{

  /* */

  test.case = '.command.one';
  var vocabulary = new _.Vocabulary();
  vocabulary.phraseAdd( '.command.one' );
  vocabulary.phraseAdd( '.command.two' );
  var exp =
  [
    {
      'words' : [ 'command', 'one' ],
      'slicePhrase' : 'command.one',
      'wholePhrase' : 'command.one',
      'subPhrase' : '',
      'phraseDescriptor' :
      {
        'phrase' : 'command.one',
        'hint' : ' command one',
        'executable' : null,
        'words' : [ 'command', 'one' ],
      },
      'kind' : 'subject'
    }
  ]
  var got = vocabulary.subjectDescriptorFor( '.command.one' );
  test.identical( got, exp );

  /* */

  test.case = 'command one';
  var vocabulary = new _.Vocabulary();
  vocabulary.phraseAdd( '.command.one' );
  vocabulary.phraseAdd( '.command.two' );
  var exp =
  [
    {
      'words' : [ 'command', 'one' ],
      'slicePhrase' : 'command.one',
      'wholePhrase' : 'command.one',
      'subPhrase' : '',
      'phraseDescriptor' :
      {
        'phrase' : 'command.one',
        'hint' : ' command one',
        'executable' : null,
        'words' : [ 'command', 'one' ],
      },
      'kind' : 'subject'
    }
  ]
  var got = vocabulary.subjectDescriptorFor( 'command one' );
  test.identical( got, exp );

  /* */

  test.case = '.command';
  var vocabulary = new _.Vocabulary();
  vocabulary.phraseAdd( '.command.one' );
  vocabulary.phraseAdd( '.command.two' );
  var exp =
  [
    {
      'words' : [ 'command' ],
      'slicePhrase' : 'command',
      'wholePhrase' : 'command.one',
      'subPhrase' : 'one',
      'phraseDescriptor' :
      {
        'phrase' : 'command.one',
        'hint' : ' command one',
        'executable' : null,
        'words' : [ 'command', 'one' ],
      },
      'kind' : 'subject'
    },
    {
      'words' : [ 'command' ],
      'slicePhrase' : 'command',
      'wholePhrase' : 'command.two',
      'subPhrase' : 'two',
      'phraseDescriptor' :
      {
        'phrase' : 'command.two',
        'hint' : ' command two',
        'executable' : null,
        'words' : [ 'command', 'two' ],
      },
      'kind' : 'subject'
    }
  ]
  var got = vocabulary.subjectDescriptorFor( '.command' );
  test.identical( got, exp );

  /* */

}

//

function subjectsFilter( test )
{
  let voc = new _.Vocabulary();
  let phrases =
  [ 'project act1' ]
  voc.phrasesAdd( phrases );

  let subjects =
  [
    {
      words : [],
      slicePhrase : '',
      wholePhrase : 'project.act1',
      subPhrase : 'project.act1',
      phraseDescriptor :
      {
        phrase : 'project.act1',
        hint : 'project act1',
        executable : null,
        words : [ 'project', 'act1' ]
      },
      kind : 'subject'
    },
    {
      words : [ 'project' ],
      slicePhrase : 'project',
      wholePhrase : 'project.act1',
      subPhrase : 'act1',
      phraseDescriptor :
      {
        phrase : 'project.act1',
        hint : 'project act1',
        executable : null,
        words : [ 'project', 'act1' ]
      },
      kind : 'subject'
    },
    {
      words : [ 'act1' ],
      slicePhrase : 'act1',
      wholePhrase : 'project.act1',
      subPhrase : 'project',
      phraseDescriptor :
      {
        phrase : 'project.act1',
        hint : 'project act1',
        executable : null,
        words : [ 'project', 'act1' ]
      },
      kind : 'subject'
    },
    {
      words : [ 'project', 'act1' ],
      slicePhrase : 'project.act1',
      wholePhrase : 'project.act1',
      subPhrase : '',
      phraseDescriptor :
      {
        phrase : 'project.act1',
        hint : 'project act1',
        executable : null,
        words : [ 'project', 'act1' ]
      },
      kind : 'subject'
    }
  ];

  test.identical( _.arrayFlatten( null, _.mapVals( voc.subjectMap ) ), subjects );

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

  /* - */

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

  var src = 'project.act1';
  var selector = { wholePhrase : src }
  debugger;
  var got = voc.subjectsFilter( subjects, selector )
  debugger;
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
  var vocabulary = new _.Vocabulary();
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
  test.identical( _.ct.strip( got ), expected );

  /**/

  var got = vocabulary.helpForSubject( 'some subject' );
  var expected = '';
  test.identical( _.ct.strip( got ), expected );

  /**/

  var got = vocabulary.helpForSubject( 'project' );
  var expected =
  [
    '.project.act1 - project act1',
    '.project.act2 - project act2',
    '.project.act3 - project act3'
  ]
  test.identical( _.ct.strip( got ), expected );

  /**/

  var got = vocabulary.helpForSubject( 'act1' );
  var expected =
  [ '.project.act1 - project act1' ]
  test.identical( _.ct.strip( got ), expected );

  /**/

  var got = vocabulary.helpForSubject( 'act3' );
  var expected =
  [ '.project.act3 - project act3' ]
  test.identical( _.ct.strip( got ), expected );

  /**/

  var got = vocabulary.helpForSubject( [ 'project', 'act1' ] );
  var expected =
  [ '.project.act1 - project act1' ]
  test.identical( _.ct.strip( got ), expected );

  /**/

  var got = vocabulary.helpForSubject( [ 'project', 'act3' ] );
  var expected =
  [ '.project.act3 - project act3' ]
  test.identical( _.ct.strip( got ), expected );

}

//

function helpForSubjectAsString( test )
{
  var vocabulary = new _.Vocabulary();
  var phrases =
  [
    'project act1',
    'project act2',
    'project act3',
  ];
  vocabulary.phrasesAdd( phrases );

  /* */

  test.open( 'without filter' );

  test.case = 'subject - empty string';
  var got = vocabulary.helpForSubjectAsString( '' );
  var expected =
`  .project.act1 - project act1
  .project.act2 - project act2
  .project.act3 - project act3`;
  test.equivalent( _.ct.strip( got ), expected );

  /* */

  test.case = 'unknown subject';
  var got = vocabulary.helpForSubjectAsString( 'some subject' );
  var expected = '';
  test.equivalent( _.ct.strip( got ), expected );

  /* */

  test.case = 'subject - common part of each phrase';
  var got = vocabulary.helpForSubjectAsString( 'project' );
  var expected =
`  .project.act1 - project act1
  .project.act2 - project act2
  .project.act3 - project act3`;
  test.equivalent( _.ct.strip( got ), expected );

  /* */

  test.case = 'subject - part of single phrase';
  var got = vocabulary.helpForSubjectAsString( 'act1' );
  var expected = '  .project.act1 - project act1';
  test.equivalent( _.ct.strip( got ), expected );

  /* */

  test.case = 'subject - array with words';
  var got = vocabulary.helpForSubjectAsString( [ 'project', 'act3' ] );
  var expected = '  .project.act3 - project act3';
  test.identical( _.ct.strip( got ), expected );

  test.close( 'without filter' );

  /* */

  test.open( 'with filter' );

  test.case = 'subject - empty string';
  var filter = ( e ) => _.strQuote( e.words.join( '.' ) );
  var got = vocabulary.helpForSubjectAsString({ phrase : '', filter });
  var expected =
`  .project.act1 - ""
  .project.act2 - ""
  .project.act3 - ""`;
  test.equivalent( _.ct.strip( got ), expected );

  /* */

  test.case = 'unknown subject';
  var filter = ( e ) => _.strQuote( e.words.join( '.' ) );
  var got = vocabulary.helpForSubjectAsString({ phrase : 'some subject', filter });
  var expected = '';
  test.equivalent( _.ct.strip( got ), expected );

  /* */

  test.case = 'subject - common part of each phrase';
  var filter = ( e ) => _.strQuote( e.words.join( '.' ) );
  var got = vocabulary.helpForSubjectAsString({ phrase : 'project', filter });
  var expected =
`  .project.act1 - "project"
  .project.act2 - "project"
  .project.act3 - "project"`;
  test.equivalent( _.ct.strip( got ), expected );

  /* */

  test.case = 'subject - part of single phrase';
  var filter = ( e ) => _.strQuote( e.words.join( '.' ) );
  var got = vocabulary.helpForSubjectAsString({ phrase : 'act1', filter });
  var expected = '  .project.act1 - "act1"';
  test.equivalent( _.ct.strip( got ), expected );

  /* */

  test.case = 'subject - array with words';
  var filter = ( e ) => _.strQuote( e.words.join( '.' ) );
  var got = vocabulary.helpForSubjectAsString({ phrase : [ 'project', 'act3' ], filter });
  var expected = '  .project.act3 - "project.act3"';
  test.identical( _.ct.strip( got ), expected );

  test.close( 'with filter' );
}

//

function wordsComplySubject( test )
{
  var vocabulary = new _.Vocabulary();
  var wordsComplySubject = vocabulary.wordsComplySubject;

  /**/

  test.true( !wordsComplySubject( [], [ 'a' ] ) );
  test.true( wordsComplySubject( [ 'a' ], [] ) );
  test.true( wordsComplySubject( [], [] ) );
  test.true( wordsComplySubject( [], [] ) );
  test.true( wordsComplySubject( [ 'a', 'b' ], [ 'a', 'b' ] ) );
  test.true( wordsComplySubject( [ 'a', 'b' ], [] ) );
  test.true( wordsComplySubject( [ 'a', 'b' ], [ '' ] ) );
  test.true( !wordsComplySubject( [ 'a', 'b' ], [ 'b', 'c' ] ) );
  test.true( wordsComplySubject( [ 'a', 'b', 'c' ], [ 'b', 'c' ] ) );
  test.true( wordsComplySubject( [ 'a', 'b', 'c' ], [ 'b' ] ) );
  test.true( wordsComplySubject( [ 'a', 'b', 'c', 'x' ], [ 'b', 'c' ] ) );
  test.true( !wordsComplySubject( [ 'a', 'b', 'c' ], [ 'b', 'c', 'x' ] ) );
  test.true( !wordsComplySubject( [ 'a', 'b', 'c' ], [ 'b', 'c', 'x', 'y' ] ) );

  /**/

  if( !Config.debug )
  return

  test.shouldThrowErrorOfAnyKind( () => wordsComplySubject() );
  test.shouldThrowErrorOfAnyKind( () => wordsComplySubject( '', [] ) );
  test.shouldThrowErrorOfAnyKind( () => wordsComplySubject( [], '' ) );
}

//

let Self =
{

  name : 'Tools.mid.Vocabulary',
  silencing : 1,

  context :
  {
    makeWordMap,
    makeDescriptorArray,
    makeDescriptorMap,
    makeSubjectMap,
  },

  tests :
  {
    phraseAdd,
    phrasesAdd,
    phraseParse,
    subPhrase,
    subjectDescriptorForWithClause,
    subjectDescriptorFor,
    subjectsFilter,
    helpForSubject,
    helpForSubjectAsString,
    wordsComplySubject
  }

}

//

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
