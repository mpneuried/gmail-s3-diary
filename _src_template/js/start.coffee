class EventEmitter
	constructor: ->
		@events = {}

	emit: (event, args...) ->
		return false unless @events[event]
		listener args... for listener in @events[event]
		return true

	addListener: (event, listener) ->
		@emit 'newListener', event, listener
		(@events[event]?=[]).push listener
		return @

	on: @::addListener

	once: (event, listener) ->
		fn = =>
			@removeListener event, fn
			listener arguments...
		@on event, fn
		return @

	removeListener: (event, listener) ->
		return @ unless @events[event]
		@events[event] = (l for l in @events[event] when l isnt listener)
		return @

	removeAllListeners: (event) ->
		delete @events[event]
		return @

JSONAes = 
	parse: ( password, str )=>
		_str = JSONAes.decrypt( password, str )
		return JSON.parse( _str )

	stringify: ( password, data )=>
		return JSONAes.encrypt( password, JSON.stringify( data ) )

	decrypt: ( password, str )=>
		_decrypt = CryptoJS.AES.decrypt(str.replace( /\r|\n/ ), password)
		_decrypted = CryptoJS.enc.Utf8.stringify( _decrypt )
		#_decrypted = str
		return _decrypted

	encrypt: ( password, str )=>
		_encrypted = CryptoJS.AES.encrypt(str, password)

		return _encrypted.toString()

class Loader extends EventEmitter
	constructor: ->
		super
		$.get "/data.txt", @raw
		return

	raw: ( @raw )=>
		@emit "loaded"
		return

	decrypt: ( password )=>
		try
			@emit "data", JSONAes.parse( password, @raw )
		catch _err
			if _err.message is "Malformed UTF-8 data"
				@emit "wrongpw"
			else
				throw _err
class App extends EventEmitter
	constructor: ->
		super
		@loader = new Loader()
		@loader.on "loaded", @ask4Password
		@loader.on "wrongpw", @ask4Password
		@loader.on "data", @start
		return

	ask4Password: =>
		@loader.decrypt( prompt( "Passwort:" ) )
		return

	start: ( data )=>
		console.log data
		return

$ ->
	new App()
	return