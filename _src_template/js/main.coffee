require.config
	paths:
		jquery: "vendor/jquery-2.0.3"
		underscore: "vendor/underscore"
		moment: "vendor/moment"
		moment_de: "vendor/moment_langs/de"
		jade: "vendor/jaderuntime"
		masonry: "vendor/masonry.pkgd"
		cryptojs: "vendor/aes"
		tmpl: "tmpl"
	urlArgs: "v1"
	shim:
		underscore:
			exports: "_"
		moment:
			exports: "moment"
		jquery:
			deps: [ "underscore" ]
		jade:
			exports: "jade"
		tmpl:
			deps: [ "jade" ]
		cryptojs:
			exports: "CryptoJS"

require [ "crypted", "app" ], ( Crypted, App )->
	#window.photopath = "https://piapeter13.s3.amazonaws.com"
	window.photopath = ""
	$ ->
		_crypted = new Crypted()
		_crypted.on "decrypt", ( data )->
			App.data( data )
			return
	return