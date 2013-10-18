fs = require( "fs" )
path = require( "path" )
_ = require('lodash')._
Gmail = require( "../lib/gmail" )

# get test config
scnf = fs.readFileSync( path.resolve( __dirname + "/../config.json" ) )
CNF = JSON.parse( scnf.toString( "utf8" ) )

describe "GMAIL connection", ->

	mailObj = null

	it "create object", ( done )->
		mailObj = new Gmail( CNF )
		done()
		return
	###
	it "list mailboxes", ( done )->
		mailObj.listBoxes ( err, boxes )=>
			throw err if err
			console.log boxes[ '[Gmail]' ].children
			done()
			return
		return
	
	it "fetch inbox", ( done )=>
		mailObj.fetch 1, 10, ( err, res )=>
			throw err if err
			console.log res
			done()
			return
		return
	###
	it "fetch unread", ( done )=>
		mailObj.unread "INBOX", ( err, res )=>
			throw err if err
			console.log _.pluck( res, "subject" ), _.pluck( res, "msgid" )
			console.log res[0].attachments
			done()
			return
		return

	return