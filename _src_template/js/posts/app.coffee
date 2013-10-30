define [ "marionette", "app", "posts/controller" ], ( marionette, App, Controller )->

	module = App.module( "Posts", { startWithParent: false } )

	new Controller( module )

	module.start()

	return module