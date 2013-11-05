define [ "jquery", "eventemitter", "cryptojs", "lib/utils" ], ( $, EventEmitter, CryptoJS, utils )->

	JSONAes = 
		parse: ( password, str )=>
			_str = JSONAes.decrypt( password, str )
			return JSON.parse( _str )

		stringify: ( password, data )=>
			return JSONAes.encrypt( password, JSON.stringify( data ) )

		decrypt: ( password, str )=>
			_decrypt = CryptoJS.AES.decrypt(str.replace( /\n|\r/g, "" ), password)
			_decrypted = CryptoJS.enc.Utf8.stringify( _decrypt )
			#_decrypted = str
			return _decrypted

		encrypt: ( password, str )=>
			_encrypted = CryptoJS.AES.encrypt(str, password)
			return _encrypted.toString()


	class Loader extends EventEmitter
		load: =>
			$.get window.photopath + "/data.txt?#{ utils.randomString( 10 ) }", @raw
			return

		raw: ( @raw )=>
			@emit "loaded"
			return

		decrypt: ( _pw )->
			try
				@data = JSONAes.parse( _pw, @raw )
				@emit "data", @data
			catch _err
				if _err.message is "Malformed UTF-8 data"
					@emit "wrongpw"
				else
					throw _err
			return
	loader = new Loader()
	return loader