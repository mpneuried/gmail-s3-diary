require.config
	paths:
		jquery: "vendor/jquery-2.0.3"
		backbone: "vendor/backbone"
		underscore: "vendor/underscore"
		moment: "vendor/moment"
		moment_de: "vendor/moment_langs/de"
		marionette: "vendor/backbone.marionette.min"
		jade: "vendor/jaderuntime"
		cryptojs: "vendor/aes"
		tmpl: "tmpl"
	urlArgs: "v1"
	shim:
		underscore:
			exports: "_"
		moment:
			exports: "moment"
		backbone:
			deps: [ "underscore" ]
			exports: "Backbone"
		marionette: 
			deps: [ "underscore", "backbone" ]
			exports: "Marionette"
		jade:
			exports: "jade"
		tmpl:
			deps: [ "jade" ]
		cryptojs:
			exports: "CryptoJS"

require [ "crypted", "start" ], ( Crypted, Start )->

	$ ->
		_crypted = new Crypted()
		_crypted.on "decrypt", ( data )=>
			new Start( data )
			return
		return
	return