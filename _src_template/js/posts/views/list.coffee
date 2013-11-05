define [ "marionette", "tmpl", "collections", "moment", "moment_de" ], ( marionette, tmpl, collections, moment )->

	class Post extends marionette.ItemView
		className: "file"
		tagName: "LI"
		model: collections.files.model
		template: tmpl.post
		tagName: "DIV"
		events: 
			"click": "toggleFullView"
		attributes: =>
			#console.log "attr", @model.toJSON()
			return

		serializeData: =>
			_data = @model.toJSON()
			_data.post = null
			_data.filename = window.photopath + _data.filename
			post = collections.posts.get( _data.postid )
			
			if post?
				_data.post = post.toJSON()
				_data.sender = post.sender
			else
				_data.post = 
					subject: "-"
					text: "-"

			_start = moment( [2013,3,23,2] )

			_data._date = moment( _data.created ).format( "DD.MM.YYYY HH:mm [Uhr]" )
			if _start.valueOf() < _data.created
				_data._old = _start.from( moment( _data.created ), true ) + " alt"
			else
				_data._old = null
				_data._date = null
			
			return _data

		toggleFullView: =>
			console.log @$el.css( "background-image")
			if not @$el.hasClass( "fullview" )
				@$el.find( "img" ).hide()
				_src = window.photopath + @model.get( "filename" )
				@$el.css( "background-image", "url(#{_src})" )
				@$el.addClass( "fullview" )
			else
				@$el.find( "img" ).show()
				@$el.css( "background-image", "" )
				@$el.removeClass( "fullview" )
			return

	return class Posts extends marionette.CollectionView
		itemView: Post
		tagName: "DIV"
		className: "files"

		_onRender: =>
			$('#content').masonry
				columnWidth: 200
				gutter: 10
				isFitWidth: true
				itemSelector: '.file'

			return
