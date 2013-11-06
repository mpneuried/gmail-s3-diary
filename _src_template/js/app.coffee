define [ "jquery", "lib/eventemitter", "tmpl", "moment" ], ( $, EventEmitter, Tmpls, moment )->

	class App extends EventEmitter
		constructor: ->
			super
			@on "start", @start

			$( "body" ).delegate( ".file", "click", @toggleFullView )
			return

		data: ( data )=>
			@posts = data.posts

			@idxPosts = {}
			for post in @posts
				@idxPosts[ post.id ] = post

			@files = data.files.sort( @_sort )
			@meta = data.meta

			@idxFiles = {}
			for file, idx in @files
				file = @serializeData( file )
				@idxFiles[ file.id ] = file
				@files[ idx ] = file

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
			file.filename = window.photopath + file.filename
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
			console.log event
			_el = $( event.currentTarget )
			if not _el.hasClass( "fullview" )
				_img = _el.find( "img" )
				_img.hide()
				_src = window.photopath + _img.attr( "src" )
				_el.css( "background-image", "url(#{_src})" )
				_el.addClass( "fullview" )
			else
				_el.find( "img" ).show()
				_el.css( "background-image", "" )
				_el.removeClass( "fullview" )
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