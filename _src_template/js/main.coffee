require.config
	paths:
		jquery: "vendor/jquery-2.0.3"
		underscore: "vendor/underscore"
		moment: "vendor/moment"
		moment_de: "vendor/moment_langs/de"
		jade: "vendor/jaderuntime"
		cryptojs: "vendor/aes"
		hammer: "vendor/hammer"
		jhammer: "vendor/jquery.hammer"
		tmpl: "tmpl"
	urlArgs: "v@@version"
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
	window.datapath = "https://piapeter13.s3.amazonaws.com"
	window.photopath = "http://cdn.milon.com/image/piapeter13.s3.amazonaws.com"
	window.photopostfix = "=s800"
	#window.photopath = ""
	$ ->
		_crypted = new Crypted()
		_crypted.on "decrypt", ( data )->
			App.data( data )
			return
	return