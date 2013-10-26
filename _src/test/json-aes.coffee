_ = require('lodash')._
JSONaes = require( "../lib/json-aes" )()
should = require( "should" )

_pw = "test"
_object = 
	a: 1
	b: [ 1,3,4 ]
	c: "qwer"
	d: true
	e: 
		f: "abc"
		g: 12432
		h: false
		i: [ 2342 ]
	j: [
		{ j: 2133, k: 454363 }
		,{ j: 234325, l:"sdsgsdg" }
	]

describe "JSON-AES", ->

	_encrypted = null
	_decrypted = null

	it "encrypt json", ( done )->
		_encrypted = JSONaes.stringify( _pw, _object )
		_encrypted.should.have.type( "string" )
		console.log _encrypted
		done()
		return

	# it "encrypt json", ( done )->
	# 	_decrypted = JSONaes.parse( _pw, _encrypted )
	# 	_decrypted.should.have.type( "object" )
	# 	console.log _decrypted
	# 	done()
	# 	return


	return