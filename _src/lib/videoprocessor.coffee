stream = require( "stream" )
spawn = require('child_process').spawn
StringDecoder = require('string_decoder').StringDecoder

module.exports = ( buffer, cb )->
	exiftool = spawn( "exiftool", [ "-a", "-m", "-json", "-" ] )

	decoder = new StringDecoder( "utf8" )
	decoderError = new StringDecoder( "utf8" )
	exifData = ""
	err = ""

	exiftool.stdout.on "data", ( chunk )=>
		exifData = decoder.write( chunk )
		return

	exiftool.stdout.on "end", ( chunk )=>
		if err.length
			cb( new Error( err ) )
			return

		_data = JSON.parse( exifData )
		if _data.length
			cb( null, _data[ 0 ] )
		else
			cb( new Error( "no-data" ) )
		return

	exiftool.stderr.on "data", ( chunk )=>
		err = decoderError.write( chunk )
		return

	exiftool.stdin.write( buffer )

	exiftool.stdin.end()
	return