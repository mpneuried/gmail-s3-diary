inspect = require('util').inspect

Imap = require('imap')
_ = require('lodash')._
StringDecoder = require('string_decoder').StringDecoder

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

		_seq = @client.seq.fetch( "#{ from }:#{ to }", { bodies: [ THEADER, TTEXT, "MIME" ] } )
		@debug "fetch:fetch", _seq
		_seq.on "message", ( msg, seqno )=>
			@debug "fetch:message", msg, seqno
			_retMsg = 
				body: null
				attrs: {}

			msg.on "body", ( stream, info )=>
				_str = new StringDecoder( "utf8" )
				@debug "msg:body", stream, info
				_body = ""
				stream.on "data", ( chunk )=>
					_body = _str.write( chunk )
					return
				stream.once "end", =>
					if info.which is THEADER
						_bodyP = Imap.parseHeader( _body )
						for _k, _v of _bodyP
							_retMsg[ _k ] = if _.isArray( _v ) and _v.length is 1 then _v[ 0 ] else _v
					else
						#_bodyP = Imap.Parser.parseBodyStructure( _body )
						@info "msg:parsed", _body.split(/--.*\r\n/ig)
					
					return
				return
			msg.once "attributes", ( attrs )=>
				_retMsg.attrs = attrs
				return

			msg.once "end", =>
				_ret.push _retMsg
				return

		_err = false
		_seq.once "error", ( err )=>
			@error "fetch:errorx", err
			_err = true
			cb( err )
			return

		_seq.once "end", =>
			cb( null, _ret ) if not _err
			@client.end()
			return
		return

