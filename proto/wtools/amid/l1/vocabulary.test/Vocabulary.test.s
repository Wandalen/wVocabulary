( function _Vocabulary_test_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( 'Tools' );
  require( '../vocabulary/Vocabulary.s' );
  _.include( 'wTesting' );
}

const _ = _global_.wTools;

// --
// tests
// --

function phraseAdd( test )
{

  test.case = 'string'
  var c = make();
  var voc = new _.Vocabulary({}).preform();
  voc.phraseAdd( 'prefix act' );
  test.identical( voc.descriptorSet, c.descriptorSet );
  test.identical( voc.phraseMap, c.phraseMap );
  test.identical( voc.wordMap, c.wordMap );
  test.identical( voc.subphraseMap, null );
  voc.subphrasesForm();
  test.identical( voc.subphraseMap, c.subphraseMap );

  test.case = 'override existing phrase'
  var c = make();
  var pd =
  {
    phrase : 'prefix.act',
    words : [ 'prefix', 'act' ],
    hint : 'prefix act',
    executable : null
  }
  var descriptorSet = [ c.pd ]
  var voc = new _.Vocabulary({ overriding : 1 }).preform();
  voc.phraseAdd( 'prefix act' );
  voc.phraseAdd( 'prefix act' );
  test.identical( voc.descriptorSet, c.descriptorSet );
  test.identical( voc.phraseMap, c.phraseMap );
  test.identical( voc.wordMap, c.wordMap );
  test.identical( voc.subphraseMap, null );
  voc.subphrasesForm();
  test.identical( voc.subphraseMap, c.subphraseMap );


  test.case = 'lock descriptor: on'
  var c = make();
  var voc = new _.Vocabulary({ freezing : 1 }).preform();
  voc.phraseAdd( 'prefix act' );
  test.identical( [ ... voc.descriptorSet ][ 0 ], voc.phraseMap[ 'prefix.act' ] );
  test.identical( voc.phraseMap[ 'prefix.act' ], c.pd );
  test.shouldThrowErrorOfAnyKind( () =>
  {
    voc.phraseMap[ 'prefix act' ].someField = 1;
  })

  test.case = 'lock descriptor: off'
  var c = make();
  var voc = new _.Vocabulary({ freezing : 0 }).preform();
  voc.phraseAdd( 'prefix act' );
  test.identical( [ ... voc.descriptorSet ][ 0 ], voc.phraseMap[ 'prefix.act' ] );
  test.identical( voc.phraseMap[ 'prefix.act' ], c.pd );
  test.mustNotThrowError( () =>
  {
    voc.phraseMap[ 'prefix.act' ].someField = 1;
  })

  /* - */

  if( !Config.debug )
  return;

  var voc = new _.Vocabulary({}).preform();
  test.shouldThrowErrorOfAnyKind( () => voc.phraseAdd( 1 ) )

  var voc = new _.Vocabulary({ overriding : 0 }).preform();
  voc.phrasesAdd( 'prefix act' );
  test.shouldThrowErrorOfAnyKind( () => voc.phraseAdd( 'prefix act' ) )

  function make()
  {
    let c = Object.create( null );
    c.pd =
    {
      phrase : 'prefix.act',
      words : [ 'prefix', 'act' ],
    }
    c.descriptorSet = new Set([ c.pd ]);
    c.phraseMap =
    {
      'prefix.act' : c.pd
    }
    c.wordMap =
    {
      'prefix' : [ c.pd ],
      'act' : [ c.pd ],
    }
    c.subphraseMap =
    {
      '' : new Set([ 'prefix.act' ]),
      'prefix' : new Set([ 'prefix.act' ]),
      'act' : new Set([ 'prefix.act' ]),
      'prefix.act' : new Set([ 'prefix.act' ]),
     //  '' : new Set
     // ([
     //   {
     //     words : [],
     //     selectedSubphrase : '',
     //     phrase : 'prefix.act',
     //     restSubphrase : 'prefix.act',
     //     phraseDescriptor : c.pd,
     //   }
     // ]),
     //  'prefix' : new Set
     //  ([
     //    {
     //      words : [ 'prefix' ],
     //      selectedSubphrase : 'prefix',
     //      phrase : 'prefix.act',
     //      restSubphrase : 'act',
     //      phraseDescriptor : c.pd,
     //    }
     //  ]),
     //  'act' : new Set
     //  ([
     //    {
     //      words : [ 'act' ],
     //      selectedSubphrase : 'act',
     //      phrase : 'prefix.act',
     //      restSubphrase : 'prefix',
     //      phraseDescriptor : c.pd,
     //    }
     //  ]),
     //  'prefix.act' : new Set
     //  ([
     //    {
     //      words : [ 'prefix', 'act' ],
     //      selectedSubphrase : 'prefix.act',
     //      phrase : 'prefix.act',
     //      restSubphrase : '',
     //      phraseDescriptor : c.pd,
     //    }
     //  ])
    }
    return c;
  }

}

//

function phraseAddCustomFrom( test )
{

  var voc = new _.Vocabulary({ onPhraseDescriptorFrom, onPhraseDescriptorIs });

  voc.phraseAdd( 'do this' );
  voc.phraseAdd( 'do that' );
  voc.phraseAdd( 'that is' );

  var exp = new Set
  ([
    {
      'phrase' : 'do.this',
      'type' : 'custom.phrase.descriptor',
      'words' : [ 'do', 'this' ]
    },
    {
      'phrase' : 'do.that',
      'type' : 'custom.phrase.descriptor',
      'words' : [ 'do', 'that' ]
    },
    {
      'phrase' : 'that.is',
      'type' : 'custom.phrase.descriptor',
      'words' : [ 'that', 'is' ]
    }
  ])
  test.identical( voc.descriptorSet, exp );
  var exp =
  {
    'do.this' :
    {
      'phrase' : 'do.this',
      'type' : 'custom.phrase.descriptor',
      'words' : [ 'do', 'this' ]
    },
    'do.that' :
    {
      'phrase' : 'do.that',
      'type' : 'custom.phrase.descriptor',
      'words' : [ 'do', 'that' ]
    },
    'that.is' :
    {
      'phrase' : 'that.is',
      'type' : 'custom.phrase.descriptor',
      'words' : [ 'that', 'is' ]
    }
  }
  test.identical( voc.phraseMap, exp );
  var exp =
  {
    'do' :
    [
      {
        'phrase' : 'do.this',
        'type' : 'custom.phrase.descriptor',
        'words' : [ 'do', 'this' ],
      },
      {
        'phrase' : 'do.that',
        'type' : 'custom.phrase.descriptor',
        'words' : [ 'do', 'that' ],
      }
    ],
    'this' :
    [
      {
        'phrase' : 'do.this',
        'type' : 'custom.phrase.descriptor',
        'words' : [ 'do', 'this' ],
      }
    ],
    'that' :
    [
      {
        'phrase' : 'do.that',
        'type' : 'custom.phrase.descriptor',
        'words' : [ 'do', 'that' ],
      },
      {
        'phrase' : 'that.is',
        'type' : 'custom.phrase.descriptor',
        'words' : [ 'that', 'is' ],
      }
    ],
    'is' :
    [
      {
        'phrase' : 'that.is',
        'type' : 'custom.phrase.descriptor',
        'words' : [ 'that', 'is' ],
      }
    ]
  }
  test.identical( voc.wordMap, exp );
  var exp = {};
  test.identical( voc.subphraseMap, null );
  voc.subphrasesForm();
  var exp =
  {
    '' : new Set([ 'do.this', 'do.that', 'that.is' ]),
    'do' : new Set([ 'do.this', 'do.that' ]),
    'this' : new Set([ 'do.this' ]),
    'do.this' : new Set([ 'do.this' ]),
    'that' : new Set([ 'do.that', 'that.is' ]),
    'do.that' : new Set([ 'do.that' ]),
    'is' : new Set([ 'that.is' ]),
    'that.is' : new Set([ 'that.is' ]),
    // '' : new Set
    // ([
    //   {
    //     'phrase' : `do.this`,
    //     'selectedSubphrase' : ``,
    //     'restSubphrase' : `do.this`,
    //     'words' : [],
    //     'phraseDescriptor' : voc.phraseMap[ 'do.this' ],
    //   },
    //   {
    //     'phrase' : `do.that`,
    //     'selectedSubphrase' : ``,
    //     'restSubphrase' : `do.that`,
    //     'words' : [],
    //     'phraseDescriptor' : voc.phraseMap[ 'do.that' ],
    //   },
    //   {
    //     'phrase' : `that.is`,
    //     'selectedSubphrase' : ``,
    //     'restSubphrase' : `that.is`,
    //     'words' : [],
    //     'phraseDescriptor' : voc.phraseMap[ 'that.is' ],
    //   }
    // ]),
    // 'do' : new Set
    // ([
    //   {
    //     'phrase' : `do.this`,
    //     'selectedSubphrase' : `do`,
    //     'restSubphrase' : `this`,
    //     'words' : [ `do` ],
    //     'phraseDescriptor' : voc.phraseMap[ 'do.this' ],
    //   },
    //   {
    //     'phrase' : `do.that`,
    //     'selectedSubphrase' : `do`,
    //     'restSubphrase' : `that`,
    //     'words' : [ `do` ],
    //     'phraseDescriptor' : voc.phraseMap[ 'do.that' ],
    //   }
    // ]),
    // 'this' : new Set
    // ([
    //   {
    //     'phrase' : `do.this`,
    //     'selectedSubphrase' : `this`,
    //     'restSubphrase' : `do`,
    //     'words' : [ `this` ],
    //     'phraseDescriptor' : voc.phraseMap[ 'do.this' ],
    //   }
    // ]),
    // 'do.this' : new Set
    // ([
    //   {
    //     'phrase' : `do.this`,
    //     'selectedSubphrase' : `do.this`,
    //     'restSubphrase' : ``,
    //     'words' : [ `do`, `this` ],
    //     'phraseDescriptor' : voc.phraseMap[ 'do.this' ],
    //   }
    // ]),
    // 'that' : new Set
    // ([
    //   {
    //     'phrase' : `do.that`,
    //     'selectedSubphrase' : `that`,
    //     'restSubphrase' : `do`,
    //     'words' : [ `that` ],
    //     'phraseDescriptor' : voc.phraseMap[ 'do.that' ],
    //   },
    //   {
    //     'phrase' : `that.is`,
    //     'selectedSubphrase' : `that`,
    //     'restSubphrase' : `is`,
    //     'words' : [ `that` ],
    //     'phraseDescriptor' : voc.phraseMap[ 'that.is' ],
    //   }
    // ]),
    // 'do.that' : new Set
    // ([
    //   {
    //     'phrase' : `do.that`,
    //     'selectedSubphrase' : `do.that`,
    //     'restSubphrase' : ``,
    //     'words' : [ `do`, `that` ],
    //     'phraseDescriptor' : voc.phraseMap[ 'do.that' ],
    //   }
    // ]),
    // 'is' : new Set
    // ([
    //   {
    //     'phrase' : `that.is`,
    //     'selectedSubphrase' : `is`,
    //     'restSubphrase' : `that`,
    //     'words' : [ `is` ],
    //     'phraseDescriptor' : voc.phraseMap[ 'that.is' ],
    //   }
    // ]),
    // 'that.is' : new Set
    // ([
    //   {
    //     'phrase' : `that.is`,
    //     'selectedSubphrase' : `that.is`,
    //     'restSubphrase' : ``,
    //     'words' : [ `that`, `is` ],
    //     'phraseDescriptor' : voc.phraseMap[ 'that.is' ],
    //   }
    // ]),
  }
  test.identical( voc.subphraseMap, exp );

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

}

//

/*
qqq : split test cases, please
*/

function phraseAddWithCustomDescriptorMaker( test )
{

  test.case = 'string'
  var c = make();
  var voc = new _.Vocabulary({ onPhraseDescriptorFrom }).preform();
  voc.phraseAdd( 'prefix act' );
  test.identical( voc.descriptorSet, c.descriptorSet );
  test.identical( voc.phraseMap, c.phraseMap );
  test.identical( voc.wordMap, c.wordMap );
  test.identical( voc.subphraseMap, null );
  voc.subphrasesForm();
  test.identical( voc.subphraseMap, c.subphraseMap );

  test.case = 'array'
  var c = make();
  var voc = new _.Vocabulary({ onPhraseDescriptorFrom }).preform();
  voc.phraseAdd( [ 'prefix act', 'executable' ] );
  c.pd.executable = 'executable';
  test.identical( voc.descriptorSet, c.descriptorSet );
  test.identical( voc.phraseMap, c.phraseMap );
  test.identical( voc.wordMap, c.wordMap );
  test.identical( voc.subphraseMap, null );
  voc.subphrasesForm();
  test.identical( voc.subphraseMap, c.subphraseMap );


  test.case = 'array'
  var c = make();
  function executable(){}
  var voc = new _.Vocabulary({ onPhraseDescriptorFrom }).preform();
  voc.phraseAdd( [ 'prefix act', { e : executable, h : 'function' } ] );
  c.pd.executable = executable;
  c.pd.hint = 'function';
  test.identical( voc.descriptorSet, c.descriptorSet );
  test.identical( voc.phraseMap, c.phraseMap );
  test.identical( voc.wordMap, c.wordMap );
  test.identical( voc.subphraseMap, null );
  voc.subphrasesForm();
  test.identical( voc.subphraseMap, c.subphraseMap );

  test.case = 'override existing phrase'
  var c = make();
  var pd =
  {
    phrase : 'prefix.act',
    words : [ 'prefix', 'act' ],
    hint : 'prefix act',
    executable : null
  }
  var descriptorSet = [ c.pd ]
  var voc = new _.Vocabulary({ overriding : 1, onPhraseDescriptorFrom }).preform();
  voc.phraseAdd( 'prefix act' );
  voc.phraseAdd( 'prefix act' );
  test.identical( voc.descriptorSet, c.descriptorSet );
  test.identical( voc.phraseMap, c.phraseMap );
  test.identical( voc.wordMap, c.wordMap );
  test.identical( voc.subphraseMap, null );
  voc.subphrasesForm();
  test.identical( voc.subphraseMap, c.subphraseMap );


  test.case = 'lock descriptor: on'
  var c = make();
  var voc = new _.Vocabulary({ freezing : 1, onPhraseDescriptorFrom }).preform();
  voc.phraseAdd( 'prefix act' );
  test.identical( [ ... voc.descriptorSet ][ 0 ], voc.phraseMap[ 'prefix.act' ] );
  test.identical( voc.phraseMap[ 'prefix.act' ], c.pd );
  test.shouldThrowErrorOfAnyKind( () =>
  {
    voc.phraseMap[ 'prefix act' ].someField = 1;
  })

  test.case = 'lock descriptor: off'
  var c = make();
  var voc = new _.Vocabulary({ freezing : 0, onPhraseDescriptorFrom }).preform();
  voc.phraseAdd( 'prefix act' );
  test.identical( [ ... voc.descriptorSet ][ 0 ], voc.phraseMap[ 'prefix.act' ] );
  test.identical( voc.phraseMap[ 'prefix.act' ], c.pd );
  test.mustNotThrowError( () =>
  {
    voc.phraseMap[ 'prefix.act' ].someField = 1;
  })

  /* - */

  if( !Config.debug )
  return;

  var voc = new _.Vocabulary({ onPhraseDescriptorFrom }).preform();
  test.shouldThrowErrorOfAnyKind( () => voc.phraseAdd( 1 ) )
  test.shouldThrowErrorOfAnyKind( () => voc.phraseAdd({ phrase : 'executable' }) )

  var voc = new _.Vocabulary({ overriding : 0 }).preform();
  voc.phrasesAdd( 'prefix act' );
  test.shouldThrowErrorOfAnyKind( () => voc.phraseAdd( 'prefix act' ) )

  function make()
  {
    let c = Object.create( null );
    c.pd =
    {
      phrase : 'prefix.act',
      words : [ 'prefix', 'act' ],
      hint : 'prefix act',
      executable : null
    }
    c.descriptorSet = new Set([ c.pd ]);
    c.phraseMap =
    {
      'prefix.act' : c.pd
    }
    c.wordMap =
    {
      'prefix' : [ c.pd ],
      'act' : [ c.pd ],
    }
    c.subphraseMap =
    {
      '' : new Set([ 'prefix.act' ]),
      'prefix' : new Set([ 'prefix.act' ]),
      'act' : new Set([ 'prefix.act' ]),
      'prefix.act' : new Set([ 'prefix.act' ]),
     //  '' :
     // [
     //   {
     //     words : [],
     //     selectedSubphrase : '',
     //     phrase : 'prefix.act',
     //     restSubphrase : 'prefix.act',
     //   }
     // ],
     //  'prefix' :
     //  [
     //    {
     //      words : [ 'prefix' ],
     //      selectedSubphrase : 'prefix',
     //      phrase : 'prefix.act',
     //      restSubphrase : 'act',
     //
     //    }
     //  ],
     //  'act' :
     //  [
     //    {
     //      words : [ 'act' ],
     //      selectedSubphrase : 'act',
     //      phrase : 'prefix.act',
     //      restSubphrase : 'prefix',
     //
     //    }
     //  ],
     //  'prefix.act' :
     //  [
     //    {
     //      words : [ 'prefix', 'act' ],
     //      selectedSubphrase : 'prefix.act',
     //      phrase : 'prefix.act',
     //      restSubphrase : '',
     //
     //    }
     //  ]
    }
    return c;
  }

  /* */

  function onPhraseDescriptorFrom( src )
  {

    _.assert( _.strIs( src ) || _.arrayIs( src ) );
    // _.assert( arguments.length === 1 );

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
      _.map.assertHasOnly( executable, { e : null, h : null });
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
      phrase = phrase.split( self.defaultDelimeter );
      let hint = phrase ? phrase.join( ' ' ) : null;
      return hint;
    }

  }

  /* */

}

//

function phrasesAdd( test )
{

  test.case = 'string'
  var c = make();
  var voc = new _.Vocabulary({}).preform();
  voc.phrasesAdd( 'prefix act' );
  test.identical( voc.descriptorSet, c.descriptorSet );
  test.identical( voc.phraseMap, c.phraseMap );
  test.identical( voc.wordMap, c.wordMap );
  test.identical( voc.subphraseMap, null );
  voc.subphrasesForm();
  test.identical( voc.subphraseMap, c.subphraseMap );


  test.case = 'map'
  var c = make();
  var voc = new _.Vocabulary({}).preform();
  voc.phrasesAdd({ 'prefix act' : 'executable' });
  test.identical( voc.descriptorSet, c.descriptorSet );
  test.identical( voc.phraseMap, c.phraseMap );
  test.identical( voc.wordMap, c.wordMap );
  test.identical( voc.subphraseMap, null );
  voc.subphrasesForm();
  test.identical( voc.subphraseMap, c.subphraseMap );


  test.case = 'array of strings'
  var c = make();
  var voc = new _.Vocabulary({}).preform();
  voc.phrasesAdd( [ 'prefix act' ] );
  test.identical( voc.descriptorSet, c.descriptorSet );
  test.identical( voc.phraseMap, c.phraseMap );
  test.identical( voc.wordMap, c.wordMap );
  test.identical( voc.subphraseMap, null );
  voc.subphrasesForm();
  test.identical( voc.subphraseMap, c.subphraseMap );


  test.case = 'several phrases array'
  var c = make();
  var voc = new _.Vocabulary({}).preform();
  voc.phrasesAdd
  ([
    'phrase1 act',
    'phrase2 act'
  ]);
  test.identical( voc.descriptorSet.size, 2 )
  test.identical( _.props.onlyOwnKeys( voc.phraseMap ), [ 'phrase1.act', 'phrase2.act' ] )
  test.identical( _.props.onlyOwnKeys( voc.wordMap ), [ 'phrase1', 'act', 'phrase2' ] )
  test.identical( _.props.onlyOwnKeys( voc.subphraseMap ), [ '', 'phrase1', 'act', 'phrase1.act', 'phrase2', 'phrase2.act' ] )

  test.case = 'several phrases object'
  var c = make();
  var voc = new _.Vocabulary({}).preform();
  voc.phrasesAdd
  ({
    'phrase1 act' : 'executable1',
    'phrase2 act' : 'executable2'
  });
  test.identical( voc.descriptorSet.size, 2 )
  test.identical( _.props.onlyOwnKeys( voc.phraseMap ), [ 'phrase1.act', 'phrase2.act' ] )
  test.identical( _.props.onlyOwnKeys( voc.wordMap ), [ 'phrase1', 'act', 'phrase2' ] )
  test.identical( _.props.onlyOwnKeys( voc.subphraseMap ), [ '', 'phrase1', 'act', 'phrase1.act', 'phrase2', 'phrase2.act' ] )

  test.case = 'override existing phrase'
  var c = make();
  var voc = new _.Vocabulary({ overriding : 1 }).preform();
  voc.phrasesAdd( 'prefix act' );
  voc.phrasesAdd( 'prefix act' );
  test.identical( voc.descriptorSet, c.descriptorSet );
  test.identical( voc.phraseMap, c.phraseMap );
  test.identical( voc.wordMap, c.wordMap );
  test.identical( voc.subphraseMap, null );
  voc.subphrasesForm();
  test.identical( voc.subphraseMap, c.subphraseMap );


  test.case = 'lock descriptor: on'
  var c = make();
  var voc = new _.Vocabulary({ freezing : 1 }).preform();
  voc.phrasesAdd( 'prefix act' );
  test.identical( [ ... voc.descriptorSet ][ 0 ], voc.phraseMap[ 'prefix.act' ] );
  test.identical( voc.phraseMap[ 'prefix.act' ], c.pd );
  test.shouldThrowErrorOfAnyKind( () =>
  {
    voc.phraseMap[ 'prefix.act' ].someField = 1;
  })

  test.case = 'lock descriptor: off'
  var c = make();
  var voc = new _.Vocabulary({ freezing : 0 }).preform();
  voc.phrasesAdd( 'prefix act' );
  test.identical( [ ... voc.descriptorSet ][ 0 ], voc.phraseMap[ 'prefix.act' ] );
  test.identical( voc.phraseMap[ 'prefix.act' ], c.pd );
  test.mustNotThrowError( () =>
  {
    voc.phraseMap[ 'prefix.act' ].someField = 1;
  })

  if( !Config.debug )
  return;

  var voc = new _.Vocabulary({}).preform();
  test.shouldThrowErrorOfAnyKind( () => voc.phrasesAdd( 1 ) )
  test.shouldThrowErrorOfAnyKind( () => voc.phrasesAdd( [ 1 ] ) )

  var voc = new _.Vocabulary({ overriding : 0 }).preform();
  voc.phrasesAdd( 'prefix act' );
  test.shouldThrowErrorOfAnyKind( () => voc.phrasesAdd( 'prefix act' ) )

  function make()
  {
    var c = Object.create( null );
    c.pd =
    {
      phrase : 'prefix.act',
      words : [ 'prefix', 'act' ],
    }
    c.descriptorSet = new Set([ c.pd ]);
    c.phraseMap =
    {
      'prefix.act' : c.pd
    }
    c.wordMap =
    {
      'prefix' : [ c.pd ],
      'act' : [ c.pd ],
    }
    c.subphraseMap =
    {
      '' :
      [
        {
          words : [],
          selectedSubphrase : '',
          phrase : 'prefix.act',
          restSubphrase : 'prefix.act',

        }
      ],
      'prefix' :
      [
        {
          words : [ 'prefix' ],
          selectedSubphrase : 'prefix',
          phrase : 'prefix.act',
          restSubphrase : 'act',

        }
      ],
      'act' :
      [
        {
          words : [ 'act' ],
          selectedSubphrase : 'act',
          phrase : 'prefix.act',
          restSubphrase : 'prefix',

        }
      ],
      'prefix.act' :
      [ /* qqq : Yevhen review the file and do formatting accurately */
        {
          words : [ 'prefix', 'act' ],
          selectedSubphrase : 'prefix.act',
          phrase : 'prefix.act',
          restSubphrase : '',

        }
      ]
    }
    return c;
  }

  /* */

}

//

function phrasesAddWithCustomDescirptorMaker( test )
{

  test.case = 'string'
  var c = make();
  var voc = new _.Vocabulary({ onPhraseDescriptorFrom }).preform();
  voc.phrasesAdd( 'prefix act' );
  test.identical( voc.descriptorSet, c.descriptorSet );
  test.identical( voc.phraseMap, c.phraseMap );
  test.identical( voc.wordMap, c.wordMap );
  test.identical( voc.subphraseMap, null );
  voc.subphrasesForm();
  test.identical( voc.subphraseMap, c.subphraseMap );

  test.case = 'array of strings'
  var c = make();
  var voc = new _.Vocabulary({ onPhraseDescriptorFrom }).preform();
  voc.phrasesAdd( [ 'prefix act' ] );
  test.identical( voc.descriptorSet, c.descriptorSet );
  test.identical( voc.phraseMap, c.phraseMap );
  test.identical( voc.wordMap, c.wordMap );
  test.identical( voc.subphraseMap, null );
  voc.subphrasesForm();
  test.identical( voc.subphraseMap, c.subphraseMap );

  test.case = 'array of arrays'
  var c = make();
  var voc = new _.Vocabulary({ onPhraseDescriptorFrom }).preform();
  voc.phrasesAdd( [ [ 'prefix act', 'executable' ] ] );
  c.pd.executable = 'executable';
  test.identical( voc.descriptorSet, c.descriptorSet );
  test.identical( voc.phraseMap, c.phraseMap );
  test.identical( voc.wordMap, c.wordMap );
  test.identical( voc.subphraseMap, null );
  voc.subphrasesForm();
  test.identical( voc.subphraseMap, c.subphraseMap );
  c.pd.executable = null;

  test.case = 'object'
  var c = make();
  var voc = new _.Vocabulary({ onPhraseDescriptorFrom }).preform();
  function executable(){}
  var phrase = [ 'prefix act', { e : executable, h : 'function' } ];
  voc.phrasesAdd( [ phrase ] );
  c.pd.executable = executable;
  c.pd.hint = 'function';
  test.identical( voc.descriptorSet, c.descriptorSet );
  test.identical( voc.phraseMap, c.phraseMap );
  test.identical( voc.wordMap, c.wordMap );
  test.identical( voc.subphraseMap, null );
  voc.subphrasesForm();
  test.identical( voc.subphraseMap, c.subphraseMap );
  c.pd.executable = null;
  c.pd.hint = c.pd.phrase;

  test.case = 'object'
  var c = make();
  var voc = new _.Vocabulary({ onPhraseDescriptorFrom }).preform();
  function executable(){}
  var phrase = { 'prefix act' : { e : executable, h : 'function' } };
  voc.phrasesAdd( phrase );
  c.pd.executable = executable;
  c.pd.hint = 'function';
  test.identical( voc.descriptorSet, c.descriptorSet );
  test.identical( voc.phraseMap, c.phraseMap );
  test.identical( voc.wordMap, c.wordMap );
  test.identical( voc.subphraseMap, null );
  voc.subphrasesForm();
  test.identical( voc.subphraseMap, c.subphraseMap );
  c.pd.executable = null;
  c.pd.hint = c.pd.phrase;

  test.case = 'several phrases array'
  var c = make();
  var voc = new _.Vocabulary({ onPhraseDescriptorFrom }).preform();
  voc.phrasesAdd
  ([
    'phrase1 act',
    'phrase2 act'
  ]);
  test.identical( voc.descriptorSet.size, 2 )
  test.identical( _.props.onlyOwnKeys( voc.phraseMap ), [ 'phrase1.act', 'phrase2.act' ] )
  test.identical( _.props.onlyOwnKeys( voc.wordMap ), [ 'phrase1', 'act', 'phrase2' ] )
  test.identical( _.props.onlyOwnKeys( voc.subphraseMap ), [ '', 'phrase1', 'act', 'phrase1.act', 'phrase2', 'phrase2.act' ] )

  test.case = 'several phrases object'
  var c = make();
  var voc = new _.Vocabulary({ onPhraseDescriptorFrom }).preform();
  voc.phrasesAdd
  ({
    'phrase1 act' : 'executable1',
    'phrase2 act' : 'executable2'
  });
  test.identical( voc.descriptorSet.size, 2 )
  test.identical( _.props.onlyOwnKeys( voc.phraseMap ), [ 'phrase1.act', 'phrase2.act' ] )
  test.identical( _.props.onlyOwnKeys( voc.wordMap ), [ 'phrase1', 'act', 'phrase2' ] )
  test.identical( _.props.onlyOwnKeys( voc.subphraseMap ), [ '', 'phrase1', 'act', 'phrase1.act', 'phrase2', 'phrase2.act' ] )

  test.case = 'override existing phrase'
  var c = make();
  var voc = new _.Vocabulary({ overriding : 1, onPhraseDescriptorFrom }).preform();
  voc.phrasesAdd( 'prefix act' );
  voc.phrasesAdd( 'prefix act' );
  test.identical( voc.descriptorSet, c.descriptorSet );
  test.identical( voc.phraseMap, c.phraseMap );
  test.identical( voc.wordMap, c.wordMap );
  test.identical( voc.subphraseMap, null );
  voc.subphrasesForm();
  test.identical( voc.subphraseMap, c.subphraseMap );

  test.case = 'lock descriptor: on'
  var c = make();
  var voc = new _.Vocabulary({ freezing : 1, onPhraseDescriptorFrom }).preform();
  voc.phrasesAdd( 'prefix act' );
  test.identical( [ ... voc.descriptorSet ][ 0 ], voc.phraseMap[ 'prefix.act' ] );
  test.identical( voc.phraseMap[ 'prefix.act' ], c.pd );
  test.shouldThrowErrorOfAnyKind( () =>
  {
    voc.phraseMap[ 'prefix.act' ].someField = 1;
  })

  test.case = 'lock descriptor: off'
  var c = make();
  var voc = new _.Vocabulary({ freezing : 0, onPhraseDescriptorFrom }).preform();
  voc.phrasesAdd( 'prefix act' );
  test.identical( [ ... voc.descriptorSet ][ 0 ], voc.phraseMap[ 'prefix.act' ] );
  test.identical( voc.phraseMap[ 'prefix.act' ], c.pd );
  test.mustNotThrowError( () =>
  {
    voc.phraseMap[ 'prefix.act' ].someField = 1;
  })

  if( !Config.debug )
  return;

  var voc = new _.Vocabulary({ onPhraseDescriptorFrom }).preform();
  test.shouldThrowErrorOfAnyKind( () => voc.phrasesAdd( 1 ) )
  test.shouldThrowErrorOfAnyKind( () => voc.phrasesAdd( [ 1 ] ) )
  test.shouldThrowErrorOfAnyKind( () => voc.phrasesAdd( [ { phrase : 'executable' } ] ) )

  var voc = new _.Vocabulary({ overriding : 0, onPhraseDescriptorFrom }).preform();
  voc.phrasesAdd( 'prefix act' );
  test.shouldThrowErrorOfAnyKind( () => voc.phrasesAdd( 'prefix act' ) )

  function make()
  {
    var c = Object.create( null );
    c.pd =
    {
      phrase : 'prefix.act',
      words : [ 'prefix', 'act' ],
      hint : 'prefix act',
      executable : null
    }
    c.descriptorSet = new Set([ c.pd ]);
    c.phraseMap =
    {
      'prefix.act' : c.pd
    }
    c.wordMap =
    {
      'prefix' : [ c.pd ],
      'act' : [ c.pd ],
    }
    c.subphraseMap =
    {
      '' :
      [
        {
          words : [],
          selectedSubphrase : '',
          phrase : 'prefix.act',
          restSubphrase : 'prefix.act',

        }
      ],
      'prefix' :
      [
        {
          words : [ 'prefix' ],
          selectedSubphrase : 'prefix',
          phrase : 'prefix.act',
          restSubphrase : 'act',

        }
      ],
      'act' :
      [
        {
          words : [ 'act' ],
          selectedSubphrase : 'act',
          phrase : 'prefix.act',
          restSubphrase : 'prefix',

        }
      ],
      'prefix.act' :
      [
        {
          words : [ 'prefix', 'act' ],
          selectedSubphrase : 'prefix.act',
          phrase : 'prefix.act',
          restSubphrase : '',

        }
      ]
    }
    return c;
  }

  /* */

  function onPhraseDescriptorFrom( src )
  {

    _.assert( _.strIs( src ) || _.arrayIs( src ) );
    // _.assert( arguments.length === 1 );

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
      _.map.assertHasOnly( executable, { e : null, h : null });
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
      phrase = phrase.split( self.defaultDelimeter );
      let hint = phrase ? phrase.join( ' ' ) : null;
      return hint;
    }

  }

  /* */

}

//

function phraseAnalyzeNormal( test )
{
  let voc = new _.Vocabulary().preform();

  var phrase = '';
  var got = voc.phraseAnalyzeNormal( phrase );
  var exp = { phrase : '', words : [] };
  test.identical( got, exp );

  var phrase = 'prefix';
  var got = voc.phraseAnalyzeNormal( phrase );
  var exp = { phrase : 'prefix', words : [ 'prefix' ] };
  test.identical( got, exp );

  var phrase = 'prefix.a';
  var got = voc.phraseAnalyzeNormal( phrase );
  var exp = { phrase : 'prefix.a', words : [ 'prefix', 'a' ] };
  test.identical( got, exp );

  var phrase = ' prefix.a.b  ';
  var got = voc.phraseAnalyzeNormal( phrase );
  var exp = { phrase : ' prefix.a.b  ', words : [ ' prefix', 'a', 'b  ' ] };
  test.identical( got, exp );

  var phrase = 'prefix a';
  var got = voc.phraseAnalyzeNormal( phrase );
  var exp = { phrase : 'prefix a', words : [ 'prefix a' ] };
  test.identical( got, exp );

  var phrase = '  prefix  ';
  var got = voc.phraseAnalyzeNormal( phrase );
  var exp = { phrase : '  prefix  ', words : [ '  prefix  ' ] };
  test.identical( got, exp );

  var phrase = ' prefix.a ';
  var got = voc.phraseAnalyzeNormal( phrase );
  var exp = { phrase : ' prefix.a ', words : [ ' prefix', 'a ' ] };
  test.identical( got, exp );

  var phrase = ' . prefix . a . b . ';
  var got = voc.phraseAnalyzeNormal( phrase );
  var exp = { phrase : ' . prefix . a . b . ', words : [ ' ', ' prefix ', ' a ', ' b ', ' ' ] };
  test.identical( got, exp );

  var phrase = ' prefix   a  b    ';
  var got = voc.phraseAnalyzeNormal({ phrase });
  var exp = { phrase : ' prefix   a  b    ', words : [ ' prefix   a  b    ' ] };
  test.identical( got, exp );

  var phrase = ' prefix  ... a  b    ';
  var got = voc.phraseAnalyzeNormal({ phrase });
  var exp = { phrase : ' prefix  ... a  b    ', words : [ ' prefix  ', '', '', ' a  b    ' ] };
  test.identical( got, exp );

}

//

function phraseAnalyzeTolerant( test )
{
  let voc = new _.Vocabulary().preform();

  var phrase = '';
  var got = voc.phraseAnalyzeTolerant( phrase );
  var exp = { phrase : '', words : [] };
  test.identical( got, exp );

  var phrase = 'prefix';
  var got = voc.phraseAnalyzeTolerant( phrase );
  var exp = { phrase : 'prefix', words : [ 'prefix' ] };
  test.identical( got, exp );

  var phrase = 'prefix a';
  var got = voc.phraseAnalyzeTolerant( phrase );
  var exp = { phrase : 'prefix.a', words : [ 'prefix', 'a' ] };
  test.identical( got, exp );

  var phrase = ' prefix a b  ';
  var got = voc.phraseAnalyzeTolerant( phrase );
  var exp = { phrase : 'prefix.a.b', words : [ 'prefix', 'a', 'b' ] };
  test.identical( got, exp );

  var phrase = '  prefix  ';
  var got = voc.phraseAnalyzeTolerant( phrase );
  var exp = { phrase : 'prefix', words : [ 'prefix' ] };
  test.identical( got, exp );

  var phrase = 'prefix.a';
  var got = voc.phraseAnalyzeTolerant( phrase );
  var exp = { phrase : 'prefix.a', words : [ 'prefix', 'a' ] };
  test.identical( got, exp );

  var phrase = ' prefix.a ';
  var got = voc.phraseAnalyzeTolerant( phrase );
  var exp = { phrase : 'prefix.a', words : [ 'prefix', 'a' ] };
  test.identical( got, exp );

  var phrase = ' . prefix . a . b . ';
  var got = voc.phraseAnalyzeTolerant( phrase );
  var exp = { phrase : 'prefix.a.b', words : [ 'prefix', 'a', 'b' ] };
  test.identical( got, exp );

  var phrase = ' .. prefix .. a .. b  .. ';
  var got = voc.phraseAnalyzeTolerant( phrase );
  var exp = { phrase : 'prefix.a.b', words : [ 'prefix', 'a', 'b' ] };
  test.identical( got, exp );

  var phrase = '  prefix  ';
  var got = voc.phraseAnalyzeTolerant({ phrase });
  var exp = { phrase : 'prefix', words : [ 'prefix' ] };
  test.identical( got, exp );

  var phrase = 'prefix.a';
  var got = voc.phraseAnalyzeTolerant({ phrase });
  var exp = { phrase : 'prefix.a', words : [ 'prefix', 'a' ] };
  test.identical( got, exp );

  var phrase = ' prefix.a ';
  var got = voc.phraseAnalyzeTolerant({ phrase });
  var exp = { phrase : 'prefix.a', words : [ 'prefix', 'a' ] };
  test.identical( got, exp );

  var phrase = ' . prefix . a . b . ';
  var got = voc.phraseAnalyzeTolerant({ phrase });
  var exp = { phrase : 'prefix.a.b', words : [ 'prefix', 'a', 'b' ] };
  test.identical( got, exp );

  var phrase = ' .. prefix .. a .. b  .. ';
  var got = voc.phraseAnalyzeTolerant({ phrase });
  var exp = { phrase : 'prefix.a.b', words : [ 'prefix', 'a', 'b' ] };
  test.identical( got, exp );

  var phrase = ' prefix a ';
  var got = voc.phraseAnalyzeTolerant({ phrase });
  var exp = { phrase : 'prefix.a', words : [ 'prefix', 'a' ] };
  test.identical( got, exp );

  var phrase = ' . prefix   a   b . ';
  var got = voc.phraseAnalyzeTolerant({ phrase });
  var exp = { phrase : 'prefix.a.b', words : [ 'prefix', 'a', 'b' ] };
  test.identical( got, exp );

  var phrase = ' prefix   a  b    ';
  var got = voc.phraseAnalyzeTolerant({ phrase });
  var exp = { phrase : 'prefix.a.b', words : [ 'prefix', 'a', 'b' ] };
  test.identical( got, exp );

  var phrase = ' prefix  ... a  b    ';
  var got = voc.phraseAnalyzeTolerant({ phrase });
  var exp = { phrase : 'prefix.a.b', words : [ 'prefix', 'a', 'b' ] };
  test.identical( got, exp );

}

//

function phraseAnalyzeTolerantFieldDelimeter( test )
{
  let voc = new _.Vocabulary({ delimeter : [ '_', '|' ] }).preform();

  var phrase = '';
  var got = voc.phraseAnalyzeTolerant({ phrase });
  var exp = { phrase : '', words : [] };
  test.identical( got, exp );

  var phrase = 'prefix';
  var got = voc.phraseAnalyzeTolerant({ phrase });
  var exp = { phrase : 'prefix', words : [ 'prefix' ] };
  test.identical( got, exp );

  var phrase = '  prefix  ';
  var got = voc.phraseAnalyzeTolerant({ phrase });
  var exp = { phrase : 'prefix', words : [ 'prefix' ] };
  test.identical( got, exp );

  var phrase = '  prefix  a  ';
  var got = voc.phraseAnalyzeTolerant({ phrase });
  var exp = { phrase : 'prefix  a', words : [ 'prefix  a' ] };
  test.identical( got, exp );

  var phrase = 'prefix_a';
  var got = voc.phraseAnalyzeTolerant({ phrase });
  var exp = { phrase : 'prefix_a', words : [ 'prefix', 'a' ] };
  test.identical( got, exp );

  var phrase = '|prefix_a|';
  var got = voc.phraseAnalyzeTolerant({ phrase });
  var exp = { phrase : 'prefix_a', words : [ 'prefix', 'a' ] };
  test.identical( got, exp );

  var phrase = '|.|prefix|.|a|.|b|.|';
  var got = voc.phraseAnalyzeTolerant({ phrase });
  var exp = { phrase : '._prefix_._a_._b_.', words : [ '.', 'prefix', '.', 'a', '.', 'b', '.' ] };
  test.identical( got, exp );

  var phrase = '|__|prefix|__|a|__|b||__|';
  var got = voc.phraseAnalyzeTolerant({ phrase });
  var exp = { phrase : 'prefix_a_b', words : [ 'prefix', 'a', 'b' ] };
  test.identical( got, exp );

  var phrase = ' prefix|a|';
  var got = voc.phraseAnalyzeTolerant({ phrase });
  var exp = { phrase : 'prefix_a', words : [ 'prefix', 'a' ] };
  test.identical( got, exp );

  var phrase = '|_|prefix|||a|||b|_|';
  var got = voc.phraseAnalyzeTolerant({ phrase });
  var exp = { phrase : 'prefix_a_b', words : [ 'prefix', 'a', 'b' ] };
  test.identical( got, exp );

  var phrase = '|prefix|||a||b||||';
  var got = voc.phraseAnalyzeTolerant({ phrase });
  var exp = { phrase : 'prefix_a_b', words : [ 'prefix', 'a', 'b' ] };
  test.identical( got, exp );

  var phrase = '|prefix||___|a||b||||';
  var got = voc.phraseAnalyzeTolerant({ phrase });
  var exp = { phrase : 'prefix_a_b', words : [ 'prefix', 'a', 'b' ] };
  test.identical( got, exp );

}

//

function phraseAnalyzeTolerantOptionDelimeter( test )
{
  let voc = new _.Vocabulary().preform();

  var phrase = '';
  var got = voc.phraseAnalyzeTolerant({ phrase, delimeter : [ '_', '|' ] });
  var exp = { phrase : '', words : [] };
  test.identical( got, exp );

  var phrase = 'prefix';
  var got = voc.phraseAnalyzeTolerant({ phrase, delimeter : [ '_', '|' ] });
  var exp = { phrase : 'prefix', words : [ 'prefix' ] };
  test.identical( got, exp );

  var phrase = '  prefix  ';
  var got = voc.phraseAnalyzeTolerant({ phrase, delimeter : [ '_', '|' ] });
  var exp = { phrase : 'prefix', words : [ 'prefix' ] };
  test.identical( got, exp );

  var phrase = '  prefix  a  ';
  var got = voc.phraseAnalyzeTolerant({ phrase, delimeter : [ '_', '|' ] });
  var exp = { phrase : 'prefix  a', words : [ 'prefix  a' ] };
  test.identical( got, exp );

  var phrase = 'prefix_a';
  var got = voc.phraseAnalyzeTolerant({ phrase, delimeter : [ '_', '|' ] });
  var exp = { phrase : 'prefix.a', words : [ 'prefix', 'a' ] };
  test.identical( got, exp );

  var phrase = '|prefix_a|';
  var got = voc.phraseAnalyzeTolerant({ phrase, delimeter : [ '_', '|' ] });
  var exp = { phrase : 'prefix.a', words : [ 'prefix', 'a' ] };
  test.identical( got, exp );

  var phrase = '|.|prefix|.|a|.|b|.|';
  var got = voc.phraseAnalyzeTolerant({ phrase, delimeter : [ '_', '|' ] });
  var exp = { phrase : '..prefix...a...b..', words : [ '.', 'prefix', '.', 'a', '.', 'b', '.' ] };
  test.identical( got, exp );

  var phrase = '|__|prefix|__|a|__|b||__|';
  var got = voc.phraseAnalyzeTolerant({ phrase, delimeter : [ '_', '|' ] });
  var exp = { phrase : 'prefix.a.b', words : [ 'prefix', 'a', 'b' ] };
  test.identical( got, exp );

  var phrase = ' prefix|a|';
  var got = voc.phraseAnalyzeTolerant({ phrase, delimeter : [ '_', '|' ] });
  var exp = { phrase : 'prefix.a', words : [ 'prefix', 'a' ] };
  test.identical( got, exp );

  var phrase = '|_|prefix|||a|||b|_|';
  var got = voc.phraseAnalyzeTolerant({ phrase, delimeter : [ '_', '|' ] });
  var exp = { phrase : 'prefix.a.b', words : [ 'prefix', 'a', 'b' ] };
  test.identical( got, exp );

  var phrase = '|prefix|||a||b||||';
  var got = voc.phraseAnalyzeTolerant({ phrase, delimeter : [ '_', '|' ] });
  var exp = { phrase : 'prefix.a.b', words : [ 'prefix', 'a', 'b' ] };
  test.identical( got, exp );

  var phrase = '|prefix||___|a||b||||';
  var got = voc.phraseAnalyzeTolerant({ phrase, delimeter : [ '_', '|' ] });
  var exp = { phrase : 'prefix.a.b', words : [ 'prefix', 'a', 'b' ] };
  test.identical( got, exp );

}

//

function subphraseRest( test )
{
  test.case = 'remove part of a phrase';
  var voc = new _.Vocabulary().preform();

  /* strings */

  var got = voc.subphraseRest( '', '' );
  var exp = '';
  test.identical( got, exp );

  var got = voc.subphraseRest( 'prefix', '' );
  var exp = 'prefix';
  test.identical( got, exp );

  var got = voc.subphraseRest( 'prefix', 'y' );
  var exp = 'prefix';
  test.identical( got, exp );

  var got = voc.subphraseRest( 'prefix act2', 'act2' );
  var exp = 'prefix';
  test.identical( got, exp );

  var got = voc.subphraseRest( 'prefix act2 abc', 'abc' );
  var exp = 'prefix act2';
  test.identical( got, exp );

  var got = voc.subphraseRest( '.prefix.act2.abc.', 'abc' );
  var exp = 'prefix.act2';
  test.identical( got, exp );

  var got = voc.subphraseRest( '.prefix.act2.abc.', 'act2' );
  var exp = 'prefix.abc';
  test.identical( got, exp );

  var got = voc.subphraseRest( '  prefix   act2   ', 'act2' );
  var exp = 'prefix';
  test.identical( got, exp );

  /* arrays */

  var got = voc.subphraseRest( [ 'prefix', 'act2' ], 'act2' );
  var exp = 'prefix';
  test.identical( got, exp );

  var got = voc.subphraseRest( [ 'prefix', 'act2', 'abc' ], [ 'act2', 'abc' ] );
  var exp = 'prefix';
  test.identical( got, exp );

  var got = voc.subphraseRest( [ 'prefix', 'act2', 'abc' ], [ 'act2', 'x' ] );
  var exp = 'prefix.act2.abc';
  test.identical( got, exp );

  var got = voc.subphraseRest( 'prefix.act2.abc', [ 'act2', 'abc' ] );
  var exp = 'prefix';
  test.identical( got, exp );

  var got = voc.subphraseRest( [ 'prefix', 'act2   ' ], [ 'act2' ] );
  var exp = 'prefix';
  test.identical( got, exp );

  /* */

  if( !Config.debug )
  return

  test.shouldThrowErrorOfAnyKind( () => voc.subphraseRest() );
  test.shouldThrowErrorOfAnyKind( () => voc.subphraseRest( 1, '' ) );
  test.shouldThrowErrorOfAnyKind( () => voc.subphraseRest( '', 1 ) );

}

//

function withSubphrase( test )
{

  /* */

  test.case = 'basic';

  var voc = new _.Vocabulary();
  voc.phrasesAdd([ 'do.this', 'do.that', 'that.is' ]);

  var got = voc.withSubphrase( 'do' );
  var exp = new Set
  ([
    {
      'phrase' : 'do.this',
      'selectedSubphrase' : 'do',
      'restSubphrase' : 'this',
      'words' : [ 'do' ],
      'phraseDescriptor' :
      {
        'phrase' : 'do.this',
        'words' : [ 'do', 'this' ],
      },
    },
    {
      'phrase' : 'do.that',
      'selectedSubphrase' : 'do',
      'restSubphrase' : 'that',
      'words' : [ 'do' ],
      'phraseDescriptor' :
      {
        'phrase' : 'do.that',
        'words' : [ 'do', 'that' ],
      },
    }
  ])
  test.identical( got, exp );

  var got = voc.withSubphrase( 'that' );
  var exp = new Set
  ([
    {
      'phrase' : 'do.that',
      'selectedSubphrase' : 'that',
      'restSubphrase' : 'do',
      'words' : [ 'that' ],
      'phraseDescriptor' :
      {
        'phrase' : 'do.that',
        'words' : [ 'do', 'that' ],
      },
    },
    {
      'phrase' : 'that.is',
      'selectedSubphrase' : 'that',
      'restSubphrase' : 'is',
      'words' : [ 'that' ],
      'phraseDescriptor' :
      {
        'phrase' : 'that.is',
        'words' : [ 'that', 'is' ],
      },
    },
  ])
  test.identical( got, exp );

  var got = voc.withSubphrase( '' );
  var exp = new Set
  ([
    {
      'phrase' : 'do.this',
      'selectedSubphrase' : '',
      'restSubphrase' : 'do.this',
      'words' : [],
      'phraseDescriptor' :
      {
        'phrase' : 'do.this',
        'words' : [ 'do', 'this' ],
      },
    },
    {
      'phrase' : 'do.that',
      'selectedSubphrase' : '',
      'restSubphrase' : 'do.that',
      'words' : [],
      'phraseDescriptor' :
      {
        'phrase' : 'do.that',
        'words' : [ 'do', 'that' ],
      },
    },
    {
      'phrase' : 'that.is',
      'selectedSubphrase' : '',
      'restSubphrase' : 'that.is',
      'words' : [],
      'phraseDescriptor' :
      {
        'phrase' : 'that.is',
        'words' : [ 'that', 'is' ],
      },
    }
  ])
  test.identical( got, exp );

  var got = voc.withSubphrase( 'do.this' );
  var exp = new Set
  ([
    {
      'phrase' : 'do.this',
      'selectedSubphrase' : 'do.this',
      'restSubphrase' : '',
      'words' : [ 'do', 'this' ],
      'phraseDescriptor' :
      {
        'phrase' : 'do.this',
        'words' : [ 'do', 'this' ],
      },
    },
  ])
  test.identical( got, exp );

  /* */

  test.case = 'assumption';
  var voc = new _.Vocabulary().preform();
  var phrase2 = 'prefix postfix';
  voc.phrasesAdd([ phrase2 ]);
  var got = voc.withSubphrase( '' );
  var exp = new Set
  ([
    {
      'phrase' : 'prefix.postfix',
      'selectedSubphrase' : '',
      'restSubphrase' : 'prefix.postfix',
      'words' : [],
      'phraseDescriptor' :
      {
        'phrase' : 'prefix.postfix',
        'words' : [ 'prefix', 'postfix' ],
      },
    }
  ])
  test.identical( got, exp );

  /* */

  test.case = 'empty';
  var voc = new _.Vocabulary().preform();
  var phrase = 'prefix act2'
  voc.phrasesAdd( phrase );
  var got = voc.withSubphrase( '' );
  var exp = new Set
  ([
    {
      words : [],
      selectedSubphrase : '',
      phrase : 'prefix.act2',
      restSubphrase : 'prefix.act2',
      'phraseDescriptor' :
      {
        'phrase' : 'prefix.act2',
        'words' : [ 'prefix', 'act2' ],
      },
    }
  ])
  test.identical( got, exp );

  /* */

  test.case = 'nothing found';
  var voc = new _.Vocabulary().preform();
  var phrase = 'prefix act2'
  voc.phrasesAdd( phrase );
  var got = voc.withSubphrase( 'x' );
  var exp = new Set([]);
  test.identical( got, exp );

  /* */

  test.case = 'act2';
  var voc = new _.Vocabulary().preform();
  var phrase = 'prefix act2'
  voc.phrasesAdd( phrase );
  var subject = 'act2';
  var got = voc.withSubphrase( subject );
  var exp = new Set
  ([
    {
      words : [ 'act2' ],
      selectedSubphrase : 'act2',
      phrase : 'prefix.act2',
      restSubphrase : 'prefix',
      'phraseDescriptor' :
      {
        'phrase' : 'prefix.act2',
        'words' : [ 'prefix', 'act2' ],
      },
    }
  ])
  test.identical( got, exp );

  /* */

  test.case = 'subject as array';
  var voc = new _.Vocabulary().preform();
  var phrase = 'prefix act2'
  voc.phrasesAdd( phrase );
  var subject = [ 'prefix', 'act2' ];
  var got = voc.withSubphrase( subject );
  var exp = new Set
  ([
    {
      words : [ 'prefix', 'act2' ],
      selectedSubphrase : 'prefix.act2',
      phrase : 'prefix.act2',
      restSubphrase : '',
      'phraseDescriptor' :
      {
        'phrase' : 'prefix.act2',
        'words' : [ 'prefix', 'act2' ],
      },
    }
  ])
  test.identical( got, exp );

  /* */

  test.case = '.command.one';
  var voc = new _.Vocabulary().preform();
  voc.phraseAdd( '.command.one' );
  voc.phraseAdd( '.command.two' );
  var exp = new Set
  ([
    {
      'words' : [ 'command', 'one' ],
      'selectedSubphrase' : 'command.one',
      'phrase' : 'command.one',
      'restSubphrase' : '',
      'phraseDescriptor' :
      {
        'phrase' : 'command.one',
        'words' : [ 'command', 'one' ],
      },
    }
  ])
  var got = voc.withSubphrase( '.command.one' );
  test.identical( got, exp );

  /* */

  test.case = 'command one';
  var voc = new _.Vocabulary().preform();
  voc.phraseAdd( '.command.one' );
  voc.phraseAdd( '.command.two' );
  var exp = new Set
  ([
    {
      'words' : [ 'command', 'one' ],
      'selectedSubphrase' : 'command.one',
      'phrase' : 'command.one',
      'restSubphrase' : '',
      'phraseDescriptor' :
      {
        'phrase' : 'command.one',
        'words' : [ 'command', 'one' ],
      },
    }
  ])
  var got = voc.withSubphrase( 'command one' );
  test.identical( got, exp );

  /* */

  test.case = '.command';
  var voc = new _.Vocabulary().preform();
  voc.phraseAdd( '.command.one' );
  voc.phraseAdd( '.command.two' );
  var exp = new Set
  ([
    {
      'words' : [ 'command' ],
      'selectedSubphrase' : 'command',
      'phrase' : 'command.one',
      'restSubphrase' : 'one',
      'phraseDescriptor' :
      {
        'phrase' : 'command.one',
        'words' : [ 'command', 'one' ],
      },
    },
    {
      'words' : [ 'command' ],
      'selectedSubphrase' : 'command',
      'phrase' : 'command.two',
      'restSubphrase' : 'two',
      'phraseDescriptor' :
      {
        'phrase' : 'command.two',
        'words' : [ 'command', 'two' ],
      },
    }
  ])
  var got = voc.withSubphrase( '.command' );
  test.identical( got, exp );

  /* */

  if( !Config.debug )
  return;

  test.shouldThrowErrorOfAnyKind( () => voc.withSubphrase() );
  test.shouldThrowErrorOfAnyKind( () => voc.withSubphrase( 1 ) );
}

//

function withSubphraseOptionMinimal( test )
{

  /* */

  test.case = 'assumption';
  var voc = new _.Vocabulary().preform();
  var phrase1 = 'prefix';
  var phrase2 = 'prefix postfix';
  var phrase3 = 'postfix';
  voc.phrasesAdd([ phrase1, phrase2, phrase3 ]);
  var got = voc.withSubphrase( '' );
  var exp = new Set
  ([
    {
      'phrase' : 'prefix',
      'selectedSubphrase' : '',
      'restSubphrase' : 'prefix',
      'words' : [],
      'phraseDescriptor' :
      {
        'phrase' : 'prefix',
        'words' : [ 'prefix' ],
      },
    },
    {
      'phrase' : 'prefix.postfix',
      'selectedSubphrase' : '',
      'restSubphrase' : 'prefix.postfix',
      'words' : [],
      'phraseDescriptor' :
      {
        'phrase' : 'prefix.postfix',
        'words' : [ 'prefix', 'postfix' ],
      },
    },
    {
      'phrase' : 'postfix',
      'selectedSubphrase' : '',
      'restSubphrase' : 'postfix',
      'words' : [],
      'phraseDescriptor' :
      {
        'phrase' : 'postfix',
        'words' : [ 'postfix' ],
      },
    }
  ])
  test.identical( got, exp );

  /* */

  test.case = 'prefix';
  var voc = new _.Vocabulary().preform();
  var phrase1 = 'prefix';
  var phrase2 = 'prefix postfix';
  var phrase3 = 'postfix';
  voc.phrasesAdd([ phrase1, phrase2, phrase3 ]);

  var phrase = 'prefix';
  test.description = `${phrase} minimal:0`;
  var got = voc.withSubphrase({ phrase, minimal : 0 });
  debugger;
  test.identical( _.select( got, '*/phrase' ), [ 'prefix', 'prefix.postfix' ] );
  debugger;

  var phrase = 'prefix';
  test.description = `${phrase} minimal:1`;
  var got = voc.withSubphrase({ phrase, minimal : 1 });
  test.identical( _.select( got, '*/phrase' ), [ 'prefix' ] );

  var phrase = 'prefix.postfix';
  test.description = `${phrase} minimal:0`;
  var got = voc.withSubphrase({ phrase, minimal : 0 });
  test.identical( _.select( got, '*/phrase' ), [ 'prefix.postfix' ] );

  var phrase = 'prefix.postfix';
  test.description = `${phrase} minimal:1`;
  var got = voc.withSubphrase({ phrase, minimal : 1 });
  test.identical( _.select( got, '*/phrase' ), [ 'prefix.postfix' ] );

  var phrase = 'postfix';
  test.description = `${phrase} minimal:0`;
  var got = voc.withSubphrase({ phrase, minimal : 0 });
  test.identical( _.select( got, '*/phrase' ), [ 'prefix.postfix', 'postfix' ] );

  var phrase = 'postfix';
  test.description = `${phrase} minimal:1`;
  var got = voc.withSubphrase({ phrase, minimal : 1 });
  test.identical( _.select( got, '*/phrase' ), [ 'postfix' ] );

  /* */

}

//

// function subphraseDescriptorArrayFilter( test )
// {
//   let voc = new _.Vocabulary().preform();
//   let phrases =
//   [ 'prefix act1' ]
//   voc.phrasesAdd( phrases );
//
//   let subphrases =
//   [
//     {
//       words : [],
//       selectedSubphrase : '',
//       phrase : 'prefix.act1',
//       restSubphrase : 'prefix.act1',
//
//     },
//     {
//       words : [ 'prefix' ],
//       selectedSubphrase : 'prefix',
//       phrase : 'prefix.act1',
//       restSubphrase : 'act1',
//
//     },
//     {
//       words : [ 'act1' ],
//       selectedSubphrase : 'act1',
//       phrase : 'prefix.act1',
//       restSubphrase : 'prefix',
//
//     },
//     {
//       words : [ 'prefix', 'act1' ],
//       selectedSubphrase : 'prefix.act1',
//       phrase : 'prefix.act1',
//       restSubphrase : '',
//
//     }
//   ];
//
//   voc.subphrasesForm();
//   test.identical( _.arrayFlatten( null, _.props.vals( voc.subphraseMap ) ), subphrases );
//
//   test.case = 'selectedSubphrase';
//
//   var src = 'prefix';
//   var selector = { selectedSubphrase : src }
//   var got = voc.subphraseDescriptorArrayFilter( subphrases, selector )
//   var exp = subphrases[ 1 ];
//   test.identical( got, _.arrayAs( exp ) );
//
//   var src = 'act1';
//   var selector = { selectedSubphrase : src }
//   var got = voc.subphraseDescriptorArrayFilter( subphrases, selector )
//   var exp = subphrases[ 2 ];
//   test.identical( got, _.arrayAs( exp ) );
//
//   var src = 'proj';
//   var selector = { selectedSubphrase : src }
//   var got = voc.subphraseDescriptorArrayFilter( subphrases, selector )
//   var exp = [];
//   test.identical( got, exp );
//
//   /* - */
//
//   test.case = 'phrase';
//
//   var src = 'prefix';
//   var selector = { phrase : src }
//   var got = voc.subphraseDescriptorArrayFilter( subphrases, selector )
//   var exp = [];
//   test.identical( got, _.arrayAs( exp ) );
//
//   var src = 'act1';
//   var selector = { phrase : src }
//   var got = voc.subphraseDescriptorArrayFilter( subphrases, selector )
//   var exp = [];
//   test.identical( got, _.arrayAs( exp ) );
//
//   var src = 'prefix.act1';
//   var selector = { phrase : src }
//   var got = voc.subphraseDescriptorArrayFilter( subphrases, selector )
//   var exp = subphrases;
//   test.identical( got, exp );
//
//   test.case = 'restSubphrase';
//
//   var src = 'sub';
//   var selector = { restSubphrase : src }
//   var got = voc.subphraseDescriptorArrayFilter( subphrases, selector )
//   var exp = [];
//   test.identical( got, _.arrayAs( exp ) );
//
//   var src = '';
//   var selector = { restSubphrase : src }
//   var got = voc.subphraseDescriptorArrayFilter( subphrases, selector )
//   var exp = subphrases[ 3 ];
//   test.identical( got, _.arrayAs( exp ) );
//
//   var src = 'prefix';
//   var selector = { restSubphrase : src }
//   var got = voc.subphraseDescriptorArrayFilter( subphrases, selector )
//   var exp = subphrases[ 2 ];
//   test.identical( got, _.arrayAs( exp ) );
//
//   var src = 'act1';
//   var selector = { restSubphrase : src }
//   var got = voc.subphraseDescriptorArrayFilter( subphrases, selector )
//   var exp = subphrases[ 1 ];
//   test.identical( got, _.arrayAs( exp ) );
// }

//

// function withSubphraseExportToStructure( test )
// {
//   var voc = new _.Vocabulary().preform();
//   var phrases =
//   [
//     'prefix act1',
//     'prefix act2',
//     'prefix act3',
//   ]
//   voc.phrasesAdd( phrases );
//
//   /* */
//
//   var got = voc.withSubphraseExportToStructure( '' );
//   var exp =
//   [
//     '.prefix.act1 - Project act1.',
//     '.prefix.act2 - Project act2.',
//     '.prefix.act3 - Project act3.'
//   ]
//   test.identical( _.ct.strip( got ), exp );
//
//   /* */
//
//   var got = voc.withSubphraseExportToStructure( 'some subject' );
//   var exp = '';
//   test.identical( _.ct.strip( got ), exp );
//
//   /* */
//
//   var got = voc.withSubphraseExportToStructure( 'prefix' );
//   var exp =
//   [
//     '.prefix.act1 - Project act1.',
//     '.prefix.act2 - Project act2.',
//     '.prefix.act3 - Project act3.'
//   ]
//   test.identical( _.ct.strip( got ), exp );
//
//   /* */
//
//   var got = voc.withSubphraseExportToStructure( 'act1' );
//   var exp =
//   [ '.prefix.act1 - Project act1.' ]
//   test.identical( _.ct.strip( got ), exp );
//
//   /* */
//
//   var got = voc.withSubphraseExportToStructure( 'act3' );
//   var exp =
//   [ '.prefix.act3 - Project act3.' ]
//   test.identical( _.ct.strip( got ), exp );
//
//   /* */
//
//   var got = voc.withSubphraseExportToStructure( [ 'prefix', 'act1' ] );
//   var exp =
//   [ '.prefix.act1 - Project act1.' ]
//   test.identical( _.ct.strip( got ), exp );
//
//   /* */
//
//   var got = voc.withSubphraseExportToStructure( [ 'prefix', 'act3' ] );
//   var exp =
//   [ '.prefix.act3 - Project act3.' ]
//   test.identical( _.ct.strip( got ), exp );
//
// }

//
//
// function withSubphraseExportToString( test )
// {
//   var voc = new _.Vocabulary().preform();
//   var phrases =
//   [
//     'prefix act1',
//     'prefix act2',
//     'prefix act3',
//   ];
//   voc.phrasesAdd( phrases );
//
//   /* */
//
//   test.open( 'without filter' );
//
//   test.case = 'subject - empty string';
//   var got = voc.withSubphraseExportToString( '' );
//   var exp =
// `  .prefix.act1 - Project act1.
//   .prefix.act2 - Project act2.
//   .prefix.act3 - Project act3.`;
//   test.equivalent( _.ct.strip( got ), exp );
//
//   /* */
//
//   test.case = 'unknown subject';
//   var got = voc.withSubphraseExportToString( 'some subject' );
//   var exp = '';
//   test.equivalent( _.ct.strip( got ), exp );
//
//   /* */
//
//   test.case = 'subject - common part of each phrase';
//   var got = voc.withSubphraseExportToString( 'prefix' );
//   var exp =
// `  .prefix.act1 - Project act1.
//   .prefix.act2 - Project act2.
//   .prefix.act3 - Project act3.`;
//   test.equivalent( _.ct.strip( got ), exp );
//
//   /* */
//
//   test.case = 'subject - part of single phrase';
//   var got = voc.withSubphraseExportToString( 'act1' );
//   var exp = '  .prefix.act1 - Project act1.';
//   test.equivalent( _.ct.strip( got ), exp );
//
//   /* */
//
//   test.case = 'subject - array with words';
//   var got = voc.withSubphraseExportToString( [ 'prefix', 'act3' ] );
//   var exp = '  .prefix.act3 - Project act3.';
//   test.identical( _.ct.strip( got ), exp );
//
//   test.close( 'without filter' );
//
//   /* */
//
//   test.open( 'with onDescriptorExportString' );
//
//   test.case = 'subject - empty string';
//   var onDescriptorExportString = ( e ) => _.strQuote( e.words.join( '.' ) );
//   var got = voc.withSubphraseExportToString({ phrase : '', onDescriptorExportString });
//   var exp =
// `  .prefix.act1 - ""
//   .prefix.act2 - ""
//   .prefix.act3 - ""`;
//   test.equivalent( _.ct.strip( got ), exp );
//
//   /* */
//
//   test.case = 'unknown subject';
//   var onDescriptorExportString = ( e ) => _.strQuote( e.words.join( '.' ) );
//   var got = voc.withSubphraseExportToString({ phrase : 'some subject', onDescriptorExportString });
//   var exp = '';
//   test.equivalent( _.ct.strip( got ), exp );
//
//   /* */
//
//   test.case = 'subject - common part of each phrase';
//   var onDescriptorExportString = ( e ) => _.strQuote( e.words.join( '.' ) );
//   var got = voc.withSubphraseExportToString({ phrase : 'prefix', onDescriptorExportString });
//   var exp =
// `  .prefix.act1 - "prefix"
//   .prefix.act2 - "prefix"
//   .prefix.act3 - "prefix"`;
//   test.equivalent( _.ct.strip( got ), exp );
//
//   /* */
//
//   test.case = 'subject - part of single phrase';
//   var onDescriptorExportString = ( e ) => _.strQuote( e.words.join( '.' ) );
//   var got = voc.withSubphraseExportToString({ phrase : 'act1', onDescriptorExportString });
//   var exp = '  .prefix.act1 - "act1"';
//   test.equivalent( _.ct.strip( got ), exp );
//
//   /* */
//
//   test.case = 'subject - array with words';
//   var onDescriptorExportString = ( e ) => _.strQuote( e.words.join( '.' ) );
//   var got = voc.withSubphraseExportToString({ phrase : [ 'prefix', 'act3' ], onDescriptorExportString });
//   var exp = '  .prefix.act3 - "prefix.act3"';
//   test.identical( _.ct.strip( got ), exp );
//
//   test.close( 'with onDescriptorExportString' );
// }

// //
//
// function SubphraseInsidePhrase( test )
// {
//   var voc = new _.Vocabulary().preform();
//   var SubphraseInsidePhrase = voc.SubphraseInsidePhrase;
//
//   /* */
//
//   test.true( !SubphraseInsidePhrase( [ 'a' ], [] ) );
//   test.true( SubphraseInsidePhrase( [], [ 'a' ] ) );
//   test.true( SubphraseInsidePhrase( [], [] ) );
//   test.true( SubphraseInsidePhrase( [], [] ) );
//   test.true( SubphraseInsidePhrase( [ 'a', 'b' ], [ 'a', 'b' ] ) );
//   test.true( SubphraseInsidePhrase( [], [ 'a', 'b' ] ) );
//   test.true( SubphraseInsidePhrase( [ '' ], [ 'a', 'b' ] ) );
//   test.true( SubphraseInsidePhrase( [ 'a', 'b' ], [ 'b', 'c' ] ) );
//   test.true( !SubphraseInsidePhrase( [ 'b', 'c' ], [ 'a', 'b' ] ) );
//   test.true( SubphraseInsidePhrase( [ 'b', 'c' ], [ 'a', 'b', 'c' ] ) );
//   test.true( SubphraseInsidePhrase( [ 'b' ], [ 'a', 'b', 'c' ] ) );
//   test.true( SubphraseInsidePhrase( [ 'b', 'c' ], [ 'a', 'b', 'c', 'x' ] ) );
//   test.true( !SubphraseInsidePhrase( [ 'b', 'c', 'x' ], [ 'a', 'b', 'c' ] ) );
//   test.true( !SubphraseInsidePhrase( [ 'b', 'c', 'x', 'y' ], [ 'a', 'b', 'c' ] ) );
//
//   /* */
//
//   if( !Config.debug )
//   return
//
//   test.shouldThrowErrorOfAnyKind( () => SubphraseInsidePhrase() );
//   test.shouldThrowErrorOfAnyKind( () => SubphraseInsidePhrase( '', [] ) );
//   test.shouldThrowErrorOfAnyKind( () => SubphraseInsidePhrase( [], '' ) );
// }

//

function withSubphrasePerformance( test ) /* xxx : write similar test for other lookers */
{
  Config.debug = false;

  /* */

  // test.case = 'inner';
  //
  // var counter = 0;
  // var nruns = 10;
  // var data = dataGenerate( 1 << 7 );
  // var time = _.time.now();
  //
  // debugger; /* eslint-disable-line no-debugger */
  // for( let i = 0 ; i < nruns ; i++ )
  // run( data );
  // console.log( `Inner : ${_.time.spent( time )}` );
  // debugger; /* eslint-disable-line no-debugger */

  /*
  = before
  nruns:10 size:1<<7 debug:1 time:130.035s
  nruns:10 size:1<<7 debug:0 time:113.933
  = after
  nruns:10 size:1<<7 debug:1 time:?
  nruns:10 size:1<<7 debug:0 time:?
 */

  test.case = 'outer';

  var counter = 0;
  var nruns = 1000;
  var data = dataGenerate( 1 << 3 );
  var time = _.time.now();

  debugger; /* eslint-disable-line no-debugger */
  for( let i = 0 ; i < nruns ; i++ )
  run( data );
  console.log( `Outer : ${_.time.spent( time )}` );
  debugger; /* eslint-disable-line no-debugger */

  /*
  = before
  nruns:1000 size:1<<3 debug:1 time:7.752s
  nruns:1000 size:1<<3 debug:0 time:5.967s
  = after
  nruns:1000 size:1<<3 debug:1 time:?
  nruns:1000 size:1<<3 debug:0 time:?
  */

  /* */

  function run( data )
  {
    var voc = new _.Vocabulary({});
    debugger;
    voc.phrasesAdd( data.phrases );
    let descriptor = voc.withPhrase( data.phrase );
    let subphrases = voc.withSubphrase( data.subphrase );
  }

  /* */

  function dataGenerate( n )
  {
    let result = Object.create( null );
    result.phrases = phrasesGenerate( n );
    result.phrase = result.phrases[ Math.floor( result.phrases.length / 2 ) ];
    result.subphrase = _.Vocabulary.PhraseParseTolerant( result.phrase );
    result.subphrase = result.subphrase.slice( _.intRandom( result.subphrase.length - 1 ), _.intRandom( result.subphrase.length - 1 ) );
    result.subphrase = result.subphrase.join( '.' );
    return result;
  }

  /* */

  function phrasesGenerate( n )
  {
    let result = [];
    let nsqrt = Math.max( 1, Math.ceil( Math.sqrt( n ) ) );
    let names = [];

    while( names.length < nsqrt )
    _.arrayAppendOnce( names, nameGenerate() );

    while( result.length < n )
    {
      let lengthOfPhrase = Math.max( 1, _.intRandom( Math.ceil( n / 2 ) ) );
      let phrase = [];
      while( phrase.length < lengthOfPhrase )
      phrase.push( names[ _.intRandom( nsqrt ) ] );
      _.arrayAppendOnce( result, phrase.join( '.' ) );
    }

    return result;
  }

  /* */

  function nameGenerate()
  {
    let idWithGuid = _.idWithGuid();
    let name = idWithGuid.split( '-' ).join( '' ).slice( 0, 5 + _.intRandom( idWithGuid.length-5 ) );
    return name;
  }

  /* */

}

withSubphrasePerformance.experimental = 1;
withSubphrasePerformance.rapidity = -3;
withSubphrasePerformance.timeOut = 1e6;

// --
// declare
// --

const Proto =
{

  name : 'Tools.mid.Vocabulary',
  silencing : 1,

  context :
  {
  },

  tests :
  {

    phraseAdd,
    phraseAddCustomFrom,
    phraseAddWithCustomDescriptorMaker,
    // phrasesAdd, /* xxx : fix */
    // phrasesAddWithCustomDescirptorMaker, /* xxx : fix */

    phraseAnalyzeNormal,
    phraseAnalyzeTolerant,
    phraseAnalyzeTolerantFieldDelimeter,
    phraseAnalyzeTolerantOptionDelimeter,

    subphraseRest,
    withSubphrase,
    withSubphraseOptionMinimal,
    // subphraseDescriptorArrayFilter,
    // withSubphraseExportToStructure,
    // withSubphraseExportToString,
    // SubphraseInsidePhrase,

    withSubphrasePerformance,

  }

}

//

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
