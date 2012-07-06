scaleApp  = require "../../src/scaleApp"
plugin    = require "../../src/plugins/scaleApp.i18n"

scaleApp.registerPlugin plugin

describe "i18n plugin", ->

  testIt = ->
  run = -> scaleApp.start "myId"

  mod = (@sb) ->
    init: =>
      testIt @sb
    destroy: ->

  beforeEach ->
    scaleApp.register "myId", mod, {i18n: myLangObj }

  afterEach ->
    scaleApp.stopAll()
    scaleApp.unregisterAll()

  myLangObj =
    en:
      helloWorld: "Hello world"
    de:
      helloWorld: "Hallo Welt"
      hello: "Hallo"
    "de-CH":
      hello: "Grüezi!"
    es:
      something: "??"

  globalObj =
    en:
      yes: "yes"
    de:
      yes: "ja"

  it "provides the method getBrowserLanguage", ->
    (expect typeof scaleApp.i18n.getBrowserLanguage ).toEqual "function"

  it "has a method for setting a language code", ->
    lang = "en-US"
    scaleApp.i18n.setLanguage lang
    (expect lang).toEqual scaleApp.i18n.getLanguage()

  it "has a method for setting a global object", ->
    (expect typeof scaleApp.i18n.setGlobal).toEqual "function"
    (expect scaleApp.i18n.setGlobal globalObj).toEqual true

  it "fires an event if the languages has changed", ->

    scb = jasmine.createSpy "sandbox callback"
    cb = jasmine.createSpy "i18n callback"

    testIt = (sb) ->
      sb.i18n.subscribe scb
      scaleApp.i18n.setLanguage "de-CH"

    scaleApp.i18n.subscribe cb
    run()

    (expect cb).toHaveBeenCalled()
    (expect scb).toHaveBeenCalled()

  describe "get text function", ->

    it "returns the global text if nothing was defined locally", ->

      scaleApp.i18n.setGlobal globalObj
      (expect scaleApp.i18n.get "yes").toEqual "ja"
      (expect scaleApp.i18n.get "foo").toEqual "foo"
      cb = jasmine.createSpy "a callback"
      testIt = (sb) ->
        scaleApp.i18n.setLanguage "de"
        scaleApp.i18n.setGlobal globalObj
        # yes is only defined globally
        (expect sb._ "yes" ).toEqual "ja"
        # helloWorld is only defined locally
        (expect sb._ "helloWorld" ).toEqual "Hallo Welt"
        cb()
      run()
      (expect cb).toHaveBeenCalled()

    it "returns english string if current language is not supported", ->
      cb = jasmine.createSpy "a callback"
      testIt = (sb) ->
        scaleApp.i18n.setLanguage( "es" )
        (expect sb._ "helloWorld" ).toEqual "Hello world"
        (expect sb.getLanguage()).toEqual "es"
        cb()
      run()
      (expect cb).toHaveBeenCalled()

    it "returns base language string if current language is not supported", ->
      cb = jasmine.createSpy "a callback"
      testIt = (sb) ->
        scaleApp.i18n.setLanguage( "de-CH" )
        (expect sb._ "helloWorld" ).toEqual "Hallo Welt"
        cb()
      run()
      (expect cb).toHaveBeenCalled()

    it "returns not the base language string if current language is supported", ->
      cb = jasmine.createSpy "a callback"
      testIt = (sb) ->
        scaleApp.i18n.setLanguage( "de-CH" )
        (expect sb._ "hello" ).toEqual "Grüezi!"
        cb()
      run()
      (expect cb).toHaveBeenCalled()

    it "returns the key itself if nothing was found", ->
      cb = jasmine.createSpy "a callback"
      m = (@sb) ->
        init: =>
          (expect sb._ "nothing").toEqual "nothing"
          cb()
        destroy: ->
      scaleApp.register "mod", m
      scaleApp.start "mod"
      (expect cb).toHaveBeenCalled()
