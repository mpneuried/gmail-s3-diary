fs = require( "fs" )
path = require( "path" )

knox = require( "knox" )
JsonDB = require( "./jsondb" )

Gmail = require "./gmail"
JSONAes = require "./json-aes"

module.exports = class Runner extends require( "./basic" )

	defaults: =>
		return @extend true, super,
			dbPath: "/data.txt"
			password: "abc"
			gmail:
				user: null
				password: null
				markAsSeenOnFetch: false
			aws:
				key: null
				secret: null
				bucket: null

	initialize: =>
		@on( "configured", @loadJsonDB )
		@on( "loaded", @start )
		@on( "mail:new", @newMail )
		@loadConfig()
		setTimeout( ( ->return ), 10000 )
		return

	loadConfig: =>
		fs.readFile path.resolve( __dirname + "/../config.json" ), ( err, _cnf )=>
			throw err if err
			try 
				@extend( true, @config, JSON.parse( _cnf ) )

				@knox = knox.createClient( @config.aws )
				@emit "configured"
				
				return
			catch
				throw err if err
			return
		return

	loadJsonDB: =>
		@knox.getFile @config.dbPath, ( err, res )=>
			if err
				@error( null, "could not load db", @config.dbPath, err )
				return
			console.log arguments
			if res.length?
				_data = JSONAes.parseJSON( @config.password, res.toString() )
			else
				_data = 
					files: []
					posts: []

			@db = 
				files: new JsonDB( _data.files )
				posts: new JsonDB( _data.posts )
			@emit( "loaded" )
			return
		return

	start: =>
		@mail = new Gmail( @config.gmail )

		@mail.unread ( err, mails )=>
			@error( "get unread messages", err ) if err
			@emit( "mail:new", mail ) for mail in mails
			return
		return

	newMail: ( mail )=>
		for attmnt in mail.attachments
			switch attmnt.mime
				when "image/jpeg"
					@knox.putBuffer attmnt.buffer, 
				when "movie/mov"
					@knox.putBuffer attmnt.buffer, 