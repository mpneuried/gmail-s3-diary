define [ "marionette", "lib/modulecontroller", "app", "collections", "posts/views/list" ], ( marionette, ModuleController, App, collections, viewPostsList )->

	return class Controller extends ModuleController

		config: 
			list: 
				event: "files:list"
				route: ""

		list: =>
			if collections.files.length
				_lView = new viewPostsList( collection: collections.files )
				App.content.show( _lView )
				@navigate( "list" )
			else
				collections.files.on "reset", =>
					_lView = new viewPostsList( collection: collections.files )
					App.content.show( _lView )
					@navigate( "list" )
					return
			return