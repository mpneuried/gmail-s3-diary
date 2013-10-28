fs = require( "fs" )
path = require( "path" )

mime = require('mime')
async = require('async')
_ = require('lodash')._
knox = require( "knox" )
exifparser = require('exif-parser')
StringDecoder = require('string_decoder').StringDecoder;

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

			decoder = new StringDecoder('utf8')
			_str = ""

			res.on "data", ( chunk )->
				_str = decoder.write( chunk )
				return
			res.on "end", =>
				if _str.length and res.statusCode is 200
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

		_crypred = JSONAes.stringify( @config.password, _db )
		dataBuffer = new Buffer( _crypred )

		headers =
			'Content-Type': 'text/plain'
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

	newMail: ( mail )=>
		@openMails++
		process.nextTick =>
			console.log "Process Mail \"#{ mail.subject }\" with #{ mail.attachments?.length or 0 } attachments."

			_fileIds = []
			aFns = []

			for attmnt in mail.attachments
				do ( attmnt )=>

					fName = "/files/" + attmnt.checksum + "." + mime.extension( attmnt.contentType )
					_data = 
						id: attmnt.checksum
						filename: fName
						mime: attmnt.contentType
						created: mail.attributes.date.getTime()

					if attmnt.contentType in [ "image/jpeg" ]
						_parser = exifparser.create( attmnt.content )
						_exif = _parser.parse()
						if _exif?.tags?.DateTimeOriginal?
							_data.created = _exif.tags.DateTimeOriginal * 1000
							_data.gps_lat = _exif.tags.GPSLatitude
							_data.gps_lon = _exif.tags.GPSLongitude

					@db.files.add _data

					_fileIds.push attmnt.checksum
					aFns.push ( cba )=>
						headers = 
							"Content-Type": attmnt.contentType
						
						@knox.putBuffer( attmnt.content, fName, headers, cba )
					return

			async.parallel aFns, ( err, results )=>
				if err
					throw err
					return
				#console.log results
				@db.posts.add
					id: mail.msgid
					date: mail.attributes.date.getTime()
					text: mail.text
					html: mail.html
					subject: mail.subject
					sender: mail.from
					files: _fileIds
				console.log "Mail \"#{ mail.subject }\" saved"
				@emit( "mail:done" )
				return
			return
		return

	checkDone: =>
		@openMails--
		if @openMails <= 0
			console.log "All Mails saved to S3."
			@emit "upload:done"
		return