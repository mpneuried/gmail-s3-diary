define [ "marionette" ], ( marionette )->
	
	return class AppRouter extends marionette.AppRouter
		appRoutes: {}

		initialize:=>
			super
			return