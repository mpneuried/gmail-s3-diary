define [ "jquery", "eventemitter", "utils", "jsonaes" ], ( $, EventEmitter, utils, JSONAes )->

	return class Loader extends EventEmitter
		constructor: ->
			super
			$.get "/data.txt?r#{ utils.randomString( 10 ) }", @raw
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