Basic = require( "./basic" )

exports.Model = class Model extends Basic
	defaults: =>
		return @extend true, super,
			idAttribute: "id"
			collection: null

	constructor: ( @attributes = {}, options = {} )->
		super( options )

		@getter "id", ( ->@attributes[ @config.idAttribute ] )

		return

	set: ( key, value, internal = false )=>
		if _.isString( key ) or _.isNumber( key )
			if @attributes[ key ]  isnt value
				@attributes[ key ] = value
				@emit "change:#{ key }", key, value
				if internal
					_data = {}
					_data[ key ] = value
					@emit "change", _data
				return value
			else
				return null
		else
			_data = {}
			for _k, _v of key
				if @set( _k, _v, true )
					_data[ _k ] = _v
			@emit "change", _data

		return

	get: ( key )=>
		return @attributes[ key ]

	toJSON: =>
		return @attributes

module.exports = class JsonDB extends Basic

	defaults: =>
		return @extend true, super,
			idAttribute: "id"
			sortBy: "id"
			model: Model

	constructor: ( collection = [], options = {} )->
		super( options )

		@getter "length", ( ->@models.length )

		@idx = {}
		@models = []

		for attr in collection
			@add( attr, noTrigger: true )
		return

	toJSON: =>
		ret = []
		for mod in @models
			ret.push mod.toJSON()
		return ret

	add: ( attr, opt = {} )=>
		_id = attr[ @config.idAttribute ]
		if @idx[ _id ]?
			return false
		else
			_id = attr[ @config.idAttribute ]
			_model = new @config.model( attr, @extend( @config, collection: @ ) )
			_model.on "change", ( attrs )=>
				@emit "change", _model, attrs
				return
			@idx[ _id ] = _model
			@models.push( _model )
			@sort()
			if not opt.noTrigger
				@emit "add", _model
		return

	sort: =>
		@models.sort ( v1, v2 )=>
			if v1[ @config.sortBy ] > v2[ @config.sortBy ]
				return 1
			else if v1[ @config.sortBy ] < v2[ @config.sortBy ]
				return -1
			else
				return 0
		return @

	get: ( id )=>
		if @idx[ id ]?
			return @idx[ id ]
		else
			return null

	has: ( id )=>
		return @idx[ id ]?

	remove: ( id )=>
		if @has( id )
			_mod = @idx[ id ]
			idx = @models.indexOf( _model )
			ret = @models.splice( idx )
			ret.splice( 0, 1 )
			@models = @models.concat( ret )
			@emit "remove", _model
			return true
		else
			return false