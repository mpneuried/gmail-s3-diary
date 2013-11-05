define [ "backbone", "lib/loader" ], ( Backbone, loader )->

	{ Model, Collection } = Backbone
	
	class Post extends Model
		default: 
			id: null
			date: 0
			text: ""
			html: ""
			subject: ""
			sender: ""
			files: []

	class File extends Model
		default: 
			id: null
			filename: null
			mime: ""
			created: 0
			gps_lat: 0
			gps_lon: 0

	class Posts extends Collection
		model: Post
		comparator: ( a, b )->
			_a = a.get( "created" )
			_b = b.get( "created" )
			if _a > _b
				return -1
			else if _a < _b
				return 1
			else
				return 0

	class Files extends Collection
		model: File
		comparator: ( a, b )->
			_a = a.get( "created" )
			_b = b.get( "created" )
			if _a > _b
				return -1
			else if _a < _b
				return 1
			else
				return 0

	collections = 
		posts: new Posts()
		files: new Files()
		meta: new Model()

	loader.on "data", ( data )=>
		collections.meta.set( data.meta )
		collections.posts.reset( data.posts )
		collections.files.reset( data.files )
		return

	return collections