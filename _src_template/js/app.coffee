define [ "jquery", "lib/eventemitter", "tmpl", "jhammer", "moment", "moment_de" ], ( $, EventEmitter, Tmpls, Hammer, moment )->

	class App extends EventEmitter
		constructor: ->
			super
			@on "start", @start

			@currentFull = null
			_body = $( "body" )

			_body.on "keydown", @hitKey
			#_body.delegate( ".file", "mousedown", @toggleFullView )


			_hammer = _body.hammer()
			_hammer.on( "tap", ".file", @toggleFullView )
			_hammer.on( "swipeleft", ".file", @nextImg )
			_hammer.on( "swipeup", ".file", @nextImg )
			_hammer.on( "swiperight", ".file", @prevImg )
			_hammer.on( "swipedown", ".file", @prevImg )
			return

		data: ( data )=>
			@posts = data.posts

			@idxPosts = {}
			for post in @posts
				@idxPosts[ post.id ] = post

			@files = data.files.sort( @_sort )
			@meta = data.meta

			@idxFiles = {}
			@sortedIds = []
			for file, idx in @files
				file = @serializeData( file )
				@idxFiles[ file.id ] = file
				@files[ idx ] = file
				@sortedIds.push file.id
			@emit "start"
			return

		start: =>
			@render()
			return

		render: =>
			@el = $( "#main" ).html( Tmpls.main( @meta ) )
			_html = []
			for file in @files
				_html.push Tmpls.post( file )
			@el.find( "#files" ).html( _html.join("") )
			return

		getPost: ( id )=>
			return @idxPosts[ id ]

		serializeData: ( file )=>
			file.post = null
			switch file.mime
				when "image/jpeg"
					file.filename = window.photopath + file.filename + ( window.photopostfix or "" )
				else
					file.filename = window.datapath + file.filename
			post = @getPost( file.postid )
			 
			if post?
				file.post = post
				file.sender = post.sender
			else
				file.post = 
					subject: "-"
					text: "-"
 
			_start = moment( [2013,3,23,2] )
 
			file._date = moment( file.created ).format( "DD.MM.YYYY HH:mm [Uhr]" )
			if _start.valueOf() < file.created
				file._old = _start.from( moment( file.created ), true ) + " alt"
			else
				file._old = null
				file._date = null
			 
			return file

		toggleFullView: ( event )=>
			if @currentFull? and event.target.tagName is "VIDEO"
				return
			_files = $( ".files" )
			_el = $( event.currentTarget )
			if not _el.hasClass( "fullview" )
				@scrollTop = $( document ).scrollTop()
				@currentFull = _el.attr( "id" )
				_el.addClass( "fullview" )
				_files.addClass( "openfullview" )
			else
				@currentFull = null
				_el.removeClass( "fullview" )
				_files.removeClass( "openfullview" )
				$( document ).scrollTop( @scrollTop ) if @scrollTop?
				@scrollTop = null
			return

		hitKey: ( event )=>
			if event.keyCode is 39 or  event.keyCode is 40
				@nextImg()
			else if event.keyCode is 37 or  event.keyCode is 38
				@prevImg()
			else if event.keyCode is 27
				@closeImg()
			return

		nextImg: ( event )=>
			event?.gesture?.preventDefault()
			@changeImg( 1 )
			return

		prevImg: ( event )=>
			event?.gesture?.preventDefault()
			@changeImg( -1 )
			return

		changeImg: ( change )=>
			if @currentFull?
				_idx = @sortedIds.indexOf( @currentFull )
				if _idx >= 0
					_newCurrent = @sortedIds[ _idx + change ]
					if _newCurrent?
						$( "##{ @currentFull }" ).removeClass( "fullview" )
						$( "##{ _newCurrent }" ).addClass( "fullview" )
						@currentFull = _newCurrent
			return

		closeImg: =>
			if @currentFull?
				$( "##{ @currentFull }" ).removeClass( "fullview" )
				@currentFull = null
			return



		_sort: ( a, b )->
			_a = a.created
			_b = b.created
			if _a > _b
				return -1
			else if _a < _b
				return 1
			else
				return 0


	return new App()