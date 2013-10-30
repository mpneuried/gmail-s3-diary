define [ "jquery", "eventemitter", "tmpl" ], ( $, EventEmitter, Tmpls )->

	return class Start extends EventEmitter

		constructor: ( data )->
			#@on "ready", @render
			#@processRaw( data )
			@render( data )
			return

		processRaw: ( data )=>
			@emit "ready", data
			return

		render: ( data )=>
			$( "body" ).html( Tmpls.main( data ) )
			return
