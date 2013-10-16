fs = require( "fs" )
path = require( "path" )

Gmail = require( "../lib/gmail" )

# get test config
scnf = fs.readFileSync( path.resolve( __dirname + "/config.json" ) )
CNF = JSON.parse( scnf.toString( "utf8" ) )

describe "GMAIL connection", ->

	mailObj = null

	it "create object", ( done )->
		mailObj = new Gmail( CNF )
		done()
		return

	it "fetch inbox", ( done )=>
		mailObj.fetch 1, 10, ( err, res )=>
			throw err if err
			console.log res
			done()
			return
		return

	return