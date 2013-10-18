fs = require( "fs" )
path = require( "path" )

Gmail = require "./gmail"

module.exports = class Runner extends require( "./basic" )
	initialize: =>
		@on( "loaded", @start )
		@on( "mail:new", @newMail )
		@loadConfig()
		return

	loadConfig: =>
		fs.readFile path.resolve( __dirname + "/../../config.json" ), ( err, _cnf )=>
			throw err if err
			try 
				@extend( true, @config, JSON.parse( _cnf ) )
				@emit "loaded"
			catch
				throw err if err
			return

	start: =>
		@mail = new Gmail( @config )

		@mail.unread ( err, mails )=>
			@error( "get unread messages", err ) if err
			@emit( "mail:new", mail ) for mail in mails
			return
		return
