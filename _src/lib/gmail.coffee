inspect = require('util').inspect

Imap = require('imap')
_ = require('lodash')._
StringDecoder = require('string_decoder').StringDecoder
MailParser = require("mailparser").MailParser


THEADER = 'HEADER.FIELDS (FROM TO SUBJECT DATE)'
TTEXT = "TEXT"


module.exports = class Gmail extends require( "./basic" )
	
	defaults: =>
		return @extend true, super,
			user: null
			password: null
			host: "imap.gmail.com"
			port: 993
			tls: true
			tlsOptions: { rejectUnauthorized: false }
			markAsSeenOnFetch: false
			stdBox: "INBOX"

	initialize: =>
		@_openBoxObj = null
		@client = new Imap( @config )
		return

	connect: =>
		@ready = false
		@client.once( "ready", @onReady )
		@client.once( "end", @onEnd )
		@client.connect()
		@debug "start"
		return

	onEnd:=>
		@ready = false
		return

	onReady: =>
		@ready = true
		@emit "ready"
		#@debug "ready"
		#@openBox()
		return

	openBox: ( name = @config.stdBox )=>
		@debug "open Box", name
		if @ready
			@_openBox( name )
			return
		@once "ready", =>
			@_openBox( name )
			return
		@connect()
		return

	_openBox: ( name = @config.stdBox )=>
		@debug "_openBox", name
		@client.openBox name, ( err, box )=>
			if err
				@error "open box", name, err
				return
			@_openBoxObj = box
			@_openBoxName = name
			@debug "open box", name, box
			@emit "open", name, box
			return
		return

	listBoxes: ( cb )=>
		if @ready
			@_listBoxes( cb )
			return
		@once "ready", =>
			@_listBoxes( cb )
			return
		@connect()
		return

	_listBoxes: ( cb )=>
		@client.getBoxes cb
		return

	fetch: ( from, to, box, cb )=>
		[ args..., cb ] = arguments
		[ from, to, box ] = args

		@debug "fetch", @_openBox, @ready
		if @_openBoxObj is null or @_openBoxName isnt box
			@openBox( box )

			@once "open", =>
				@_fetch( "#{ from }:#{ to }", cb )
				return
		else
			@_fetch( "#{ from }:#{ to }", cb )
		return

	_fetch: ( crit, cb )=>
		@debug "open Box", @_openBoxName
		_ret = []
		_err = false
		_toParse = 0
		_end = false

		fnCheckEnd = ->
			if _toParse is 0 and _end and not _err
				_mails = []
				_mails.push mail for mail in _ret when mail?
				cb( null, _mails )
			return

		_seq = @client.fetch( crit, { markSeen: @config.markAsSeenOnFetch, bodies: '' } )
		_seq.on( "parsed", fnCheckEnd )


		@debug "fetch:fetch", _seq
		_seq.on "message", ( msg, idx )=>
			@debug "fetch:message", msg, idx
			_ret[ idx ] = {}

			msg.on "body", ( stream, info )=>
				
				_toParse++

				_mailParser = new MailParser()
				_mailParser.on "end", ( mail )=>
					_toParse--
					@debug "msg:parsed", mail

					_ret[ idx ] = @extend _ret[ idx ], 
						text: mail.text
						html: mail.html
						subject: mail.subject
						from: mail.from
						to: mail.to
						attachments: mail.attachments 

					_seq.emit "parsed"
					return
				stream.pipe( _mailParser )
				return

			msg.once "attributes", ( attrs )=>
				_ret[ idx ].msgid = attrs[ "x-gm-msgid" ] if attrs?[ "x-gm-msgid" ]?
				_ret[ idx ].attributes = attrs
				return

			msg.once "end", =>
				return
			return

		
		_seq.once "error", ( err )=>
			@error "fetch:error", err
			_err = true
			cb( err )
			return

		_seq.once "end", =>
			_end = true
			fnCheckEnd()
			@client.end()
			return
		return

	unread: =>
		[ args..., cb ] = arguments
		[ box ] = args

		@debug "fetch", @_openBox, @ready
		if @_openBoxObj is null or @_openBoxName isnt box
			@openBox( box )

			@once "open", =>
				@_unread( cb )
				return
		else
			@_unread( cb )
		return

	_unread: ( cb )=>
		@client.search [ "UNSEEN" ], ( err, results )=>
			if err
				cb( err)
				return
			if results?.length is 0
				cb( null, [] )
				return

			@_fetch( results, cb )
			return
		return


