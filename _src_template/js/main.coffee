require.config
	paths:
		jquery: "vendor/jquery-2.0.3"
		backbone: "vendor/backbone"
		underscore: "vendor/underscore"
		moment: "vendor/moment"
		moment_de: "vendor/moment_langs/de"
		jade: "vendor/jaderuntime"
		marionette: "vendor/backbone.marionette"
		masonry: "vendor/masonry.pkgd"
		cryptojs: "vendor/aes"
		tmpl: "tmpl"
	urlArgs: "v1"
	shim:
		underscore:
			exports: "_"
		moment:
			exports: "moment"
		backbone:
			deps: [ "underscore", "masonry" ]
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
		masonry: 
			deps: [ "jquery" ]

require [ "crypted", "app", "posts/app" ], ( Crypted, App )->
	window.photopath = "https://piapeter13.s3.amazonaws.com"
	#window.photopath = ""
	$ ->
		_crypted = new Crypted()
		App.start()
	return