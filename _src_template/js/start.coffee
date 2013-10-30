define [ "jquery", "lib/eventemitter", "tmpl" ], ( $, EventEmitter, Tmpls )->

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
			data.meta = 
				title: "Max Mustermann"
				subtitle: "* 12.03.2004"
				startdate: 1079064360000
				copyright: "Heinz Müller"

			$( "body" ).html( Tmpls.main( data ) )
			return
