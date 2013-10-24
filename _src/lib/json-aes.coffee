module.exports = class JSONAes extends require( "./basic" )

	parseJSON: ( password, str )=>
		return JSON.parse( @decrypt( password, str ) )

	stringify: ( password, data )=>
		return @encrypt( password, JSON.stringify( data ) )

	decrypt: ( password, str )=>
		_decrypted = str
		return _decrypted

	encrypt: ( password, str )=>
		_encrypted = str
		return _encrypted		
