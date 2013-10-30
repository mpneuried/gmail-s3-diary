define [ "jquery", "eventemitter", "utils", "jsonaes" ], ( $, EventEmitter, utils, JSONAes )->

	return new ( class Loader extends EventEmitter
		constructor: ->
			super
			$.get "/data.txt", @raw
			return

		raw: ( @raw )=>
			@emit "loaded"
			return

		decrypt: ( password )=>
			try
				@data = JSONAes.parse( password, @raw )
				@emit "data", @data
			catch _err
				console.log _err
				if _err.message is "Malformed UTF-8 data"
					@emit "wrongpw"
				else
					throw _err
		)()