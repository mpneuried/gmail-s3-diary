require.config
	paths:
		jquery: "vendor/jquery-2.0.3"
		backbone: "vendor/backbone"
		underscore: "vendor/underscore"
		moment: "vendor/moment"
		moment_de: "vendor/moment_langs/de"
		marionette: "vendor/backbone.marionette"
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
			deps: [ "underscore", "jquery" ]
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

require [ "crypted", "app", "posts/app" ], ( Crypted, App )->

	$ ->
		_crypted = new Crypted()
		App.start()
	return