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
			console.log err, JSON.stringify( res )
			throw err if err
			done()
			return
		return

	return