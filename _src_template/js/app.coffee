define [ "marionette", "router", "tmpl", "collections" ], ( marionette, Router, Tmpls, collections )->

	app = new ( class App extends marionette.Application )()

	app.addRegions
		main: "#main"
		content: "#content"

	class Layout extends Marionette.Layout
		template: Tmpls.main
		serializeData: =>
			return collections.meta.toJSON()

	layout = new Layout()
	collections.meta.on "change", =>
		app.main.show( layout )
		return

	app.router = new Router()
	
	app.on "start", =>
		Backbone.history.start()
		return

	return app