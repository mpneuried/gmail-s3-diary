fs = require( "fs" )
path = require( "path" )

mime = require('mime')
async = require('async')
_ = require('lodash')._
knox = require( "knox" )
moment = require( "moment" )
exif = require('./exif')

JsonDB = require( "./jsondb" )
Gmail = require "./gmail"
JSONAes = require( "./json-aes" )()


module.exports = class Runner extends require( "./basic" )

	defaults: =>
		return @extend true, super,
			dbPath: "/data.txt"
			password: "abc"
			allowedSenders: []
			gmail:
				user: null
				password: null
				markAsSeenOnFetch: false
			aws:
				key: null
				secret: null
				bucket: null
			meta: {}

	initialize: =>
		@openMails = 0
		@on( "configured", @loadDB )
		@on( "loaded", @start )
		@on( "mail:new", @newMail )
		@on( "mail:done", @checkDone )
		@on( "upload:done", @saveDB )
		@on "all:done", =>
			console.log "END"
			process.exit()
			return
		@loadConfig()
		clearInterval( ( ->return ), 10000 )
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

	loadDB: =>
		console.log "Load DB ... "
		@knox.getFile @config.dbPath, ( err, res )=>
			if err
				@error( null, "could not load db", @config.dbPath, err )
				return

			_str = ""

			res.on "data", ( chunk )->
				_str += chunk
				return

			res.on "end", =>
				if _str.length and res.statusCode is 200
					console.log "decrypt with `#{@config.password}`"
					_data = JSONAes.parse( @config.password, _str )
				
				_default = 
					files: []
					posts: []
				_data = @extend( true, _default, _data )
				@db = 
					files: new JsonDB( _data.files )
					posts: new JsonDB( _data.posts )

				console.log "loaded db with #{ @db.posts.length } posts and #{ @db.files.length } files."
				@emit( "loaded" )
				return
			return
		return

	saveDB: =>
		_db = {}
		for _n, coll of @db
			_db[ _n ] = coll.toJSON()
		_db.meta = @config.meta

		console.log "encrypt with `#{@config.password}`"
		_crypred = JSONAes.stringify( @config.password, _db )
		dataBuffer = new Buffer( _crypred )

		headers =
			'Content-Type': 'text/plain'
			"x-amz-acl": "public-read"
			"Access-Control-Allow-Origin": "*"
			"Access-Control-Allow-Methods": "POST, GET, OPTIONS"
			"Access-Control-Allow-Headers": "X-SOMETHING"
			"Access-Control-Max-Age": 1728000
		@knox.putBuffer dataBuffer, @config.dbPath, headers, ( err, res )=>
			throw err if err
			console.log "DB Saved"
			@emit "all:done"
			return
		return

	start: =>
		console.log "Get unread mails ... "
		@mail = new Gmail( @config.gmail )

		@mail.unread ( err, mails )=>
			@error( "get unread messages", err ) if err
			console.log "Found #{ mails.length } mails."
			if mails.length
				@emit( "mail:new", mail ) for mail in mails when @filterMail( mail )
			else
				@emit( "mail:done" )
			return
		return

	filterMail: ( mail )=>
		_senderMails = _.pluck( mail.from, "address" )
		if _.intersection( _senderMails, @config.allowedSenders ).length
			return true
		else 
			return false


	processFile: ( data, buffer, cb )=>
		console.log "Process File: \"#{ data.id }\" of mime \"#{ data.mime }\"."
		exif buffer, ( err, exif )=>
			if err
				cb( err )
				return
			
			
			data.height = exif.ImageHeight
			data.width = exif.ImageWidth
			data.rotation = exif.Rotation


			switch exif.FileType
				when "MOV"
					data.compressor = exif.CompressorName
					data.duration = exif.Duration
					data.created = moment( exif[ "CreateDate-deu" ], "YYYY:MM:DD HH:mm:ssZ" ).valueOf()
				when "JPEG"
					data.created = moment( exif.CreateDate + " +0200", "YYYY:MM:DD HH:mm:ss Z" ).valueOf()
					
			console.log "Exif Data: \"#{ data.id }\":#{ exif.FileType } created \"#{ new Date( data.created ) }\" ( #{exif.CreateDate} )."

			cb( null, data, buffer )
			return
		return

	uploadFile: ( fName, data, attmnt )=>

		return ( cb )=>
			@processFile data, attmnt.content, ( err, data, file )=>
				if err
					cb( err )
					return

				@db.files.add data

				headers = 
					"Content-Type": attmnt.contentType
					"x-amz-acl": "public-read"
					"Cache-control": "max-age=2592000"
				
				#cb( null )
				#return
				console.log "Upload File: id: \"#{ data.id }\" with mime \"#{ data.mime }\"."
				@knox.putBuffer( file, fName, headers, cb )
				return
			return

	newMail: ( mail )=>
		@openMails++
		process.nextTick =>
			console.log "Process Mail: \"#{ mail.subject }\" with #{ mail.attachments?.length or 0 } attachments."

			_fileIds = []
			aFns = []

			for attmnt in mail.attachments
				do ( attmnt )=>
					fName = "/files/" + attmnt.checksum + "." + _.last( attmnt.fileName.split( "." ) ).toLowerCase()
					_data = 
						id: attmnt.checksum
						filename: fName
						mime: attmnt.contentType
						created: mail.attributes.date.getTime()
						postid: mail.msgid

					_fileIds.push attmnt.checksum
					aFns.push @uploadFile( fName, _data, attmnt )
					return

			async.series aFns, ( err, results )=>
				if err
					throw err
					return
				#console.log results
				_txt = mail.text.replace( "Von meinem iPhone gesendet", "" )
				@db.posts.add
					id: mail.msgid
					date: mail.attributes.date.getTime()
					text: @trim( _txt )
					html: mail.html
					subject: mail.subject
					sender: mail.from
					files: _fileIds
				console.log "Mail \"#{ mail.subject }\" saved"
				@emit( "mail:done" )
				return
			return
		return
	
	trim: ( str )->
		return str.replace(/^\s+|\s+$/g, '')

	checkDone: =>
		@openMails--
		if @openMails <= 0
			console.log "All Mails saved to S3."
			@emit "upload:done"
		return