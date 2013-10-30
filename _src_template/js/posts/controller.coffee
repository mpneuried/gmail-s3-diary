define [ "marionette", "lib/modulecontroller", "app", "collections", "posts/views/list" ], ( marionette, ModuleController, App, collections, viewPostsList )->

	return class Controller extends ModuleController

		config: 
			list: 
				event: "posts:list"
				route: ""

		list: =>
			console.log App
			if collections.posts.length
				_lView = new viewPostsList( collection: collections.posts )
				App.content.show( _lView )
				@navigate( "list" )
			else
				collections.posts.on "reset", =>
					_lView = new viewPostsList( collection: collections.posts )
					App.content.show( _lView )
					@navigate( "list" )
					return
			return