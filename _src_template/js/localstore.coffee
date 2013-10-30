define [ "underscore" ], ( _ )->
	return new ( class LocalStore
			defaults:
				prefix: "diary."
				arrayDelimiter: ","
				defaultLimit: 5

			constructor: ( options )->
				@_initialized = @test()

				@options = _.extend( @defaults, options )
				return

			initialized: =>
				@_initialized

			test: =>
				try
					localStorage.setItem('__test__', '__test__')
					localStorage.removeItem('__test__')
					true
				catch e
					false

			set: ( name, value )=>
				localStorage.setItem( @options.prefix + name, value )
				value

			get: ( name )=>
				localStorage.getItem( @options.prefix + name )

			del: ( name )=>
				localStorage.removeItem( @options.prefix + name )

			has: ( name )=>
				@get( name )?

			arrayGet: ( name )=>
				_.compact( ( @get( name ) or "" ).split( @options.arrayDelimiter ) )

			arrayAdd: ( name, value, limit = @options.defaultLimit, fnFindIndex = @_findIndex )=>
				_val = @arrayGet( name )
				if fnFindIndex( _val, value ) < 0
					_val.push( value )
					if limit
						_val = _val.slice( limit * -1 )
				else
					_val = @arrayRemove( name, value, fnFindIndex )
					_val.push( value )

				@set( name, _val )
				_val

			arrayRemove: ( name, value, fnFindIndex = @_findIndex )=>
				_val = @arrayGet( name )
				_idx = fnFindIndex( _val, value )
				_val.splice(_idx, 1)
				_val

			_findIndex: ( list, value )=>
				list.indexOf( value )
	)()