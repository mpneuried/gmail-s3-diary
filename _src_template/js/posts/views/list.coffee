define [ "marionette", "tmpl", "collections" ], ( marionette, tmpl, collections )->

	console.log "LIST"
	class Post extends marionette.ItemView
		className: "ticket"
		tagName: "LI"
		model: collections.posts.model
		template: tmpl.post
		tagName: "DIV"

		serializeData: =>
			_data = @model.toJSON()
			_data._files = []
			for file in @model.get( "files" )
				_file = collections.files.get( file )
				if _file?
					_data._files.push _file.toJSON()

			console.log _data
			return _data

	return class Posts extends marionette.CollectionView
		itemView: Post
		tagName: "DIV"
