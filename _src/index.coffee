exports.version = '@@version'

exports.Gmail = require './lib/gmail'

module.exports = new ( require( './lib/run' ) )()