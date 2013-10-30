define [ "jquery", "lib/loader", "lib/localstore", "lib/eventemitter", "tmpl" ], ( $, loader, localStore, EventEmitter, Tmpls )->
	class Crypted extends EventEmitter
		constructor: ->
			super
			loader.on "loaded", @checkStorage
			loader.on "wrongpw", @wrongPassword
			loader.on "data", @start
			$("body").on "submit", ".form-decrypt", ( evnt )=>
				evnt.stopPropagation()
				evnt.preventDefault()
				pw = evnt.target.password.value
				if evnt.target.store.checked
					localStore.set( "pw", pw )
				@checkPassword( pw )
				return
			return

		checkStorage: =>
			_pw = localStore.get( "pw" )
			if _pw?
				@checkPassword( _pw )
			else
				@ask4Password()
			return

		ask4Password: ( data )=>
			$( "body" ).html( Tmpls.login( data ) )
			#_pw = prompt( "Passwort:" )
			return

		checkPassword: ( pw )=>
			if pw?.length
				@decrypt( pw )
			else
				@ask4Password( error: "invalid" )
			return

		wrongPassword: =>
			@ask4Password( error: "invalid" )
			return

		decrypt: ( pw )=>
			loader.decrypt( pw )
			return

		# _processData: ( data )=>
		# 	fileIdx = {}
		# 	for file in data.files
		# 		fileIdx[ file.id ] = file
		# 	for post in data.posts
		# 		for file in post.files
		# 			post
		# 	return

		start: ( data )=>
			@emit "decrypt", data
			return