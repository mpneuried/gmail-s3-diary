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

			stdBox: "INBOX"

	initialize: =>
		@_openBox = null
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
		@debug "ready"
		@openBox()
		return

	openBox: ( name = @config.stdBox )=>
		@client.openBox name, ( err, box )=>
			if err
				@error "open box", name, err
				return
			@_openBox = box
			@debug "open box", name, box
			@emit "open", name, box
			return
		return

	fetch: ( from, to, cb )=>
		@debug "fetch", @_openBox, @ready
		if @_openBox is null
			if not @ready
				@connect()

			@once "open", =>
				@_fetch( from, to, cb )
				return
		else
			@_fetch( from, to, cb )
		return

	_fetch: ( from, to, cb )=>
		_ret = []

		_seq = @client.seq.fetch( "#{ from }:#{ to }", { bodies: '' } )
		@debug "fetch:fetch", _seq
		_seq.on "message", ( msg, seqno )=>
			@info "fetch:message", msg, seqno
			idx = seqno - 1
			_ret[ idx ] = {}
			_parsed = false

			msg.on "body", ( stream, info )=>
				_mailParser = new MailParser()
				_mailParser.on "end", ( mail )=>
					@debug "msg:parsed", mail
					_parsed = true

					_ret[ idx ] = @extend _ret[ idx ], 
						text: mail.text
						html: mail.html
						subject: mail.subject
						from: mail.from
						to: mail.to
						attachments: mail.attachments 
					msg.emit "parsed"
					console.log "PARSED"
					return
				stream.pipe( _mailParser )
				return

			msg.once "attributes", ( attrs )=>
				_ret[ idx ].attributes = attrs
				return

			msg.once "end", =>
				console.log "ONEND", _parsed
				if _parsed
					console.log "END"
				else
					msg.once "parsed", =>
						console.log "END"
						return
				return

			return

		_err = false
		_seq.once "error", ( err )=>
			@error "fetch:errorx", err
			_err = true
			cb( err )
			return

		_seq.once "end", =>
			console.log "FINAL"
			cb( null, _ret ) if not _err

			@client.end()
			return
		return

