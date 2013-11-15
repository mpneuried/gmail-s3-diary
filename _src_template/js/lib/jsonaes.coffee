define [ "cryptojs" ], ( CryptoJS )->

	JSONAes = 
		parse: ( password, str )=>
			_str = @decrypt( password, str )
			return JSON.parse( _str )

		stringify: ( password, data )=>
			return @encrypt( password, JSON.stringify( data ) )

		decrypt: ( password, str )=>
			console.log str
			_decrypt = CryptoJS.AES.decrypt(str, password)
			_decrypted = CryptoJS.enc.Utf8.stringify( _decrypt )
			#_decrypted = str
			return _decrypted

		encrypt: ( password, str )=>
			_encrypted = CryptoJS.AES.encrypt(str, password)
			return _encrypted.toString( "base64" )

	return JSONAes