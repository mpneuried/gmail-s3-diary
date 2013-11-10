module.exports = (grunt) ->
	_config = grunt.file.readJSON('config.json')
	# Project configuration.
	grunt.initConfig
		pkg: grunt.file.readJSON('package.json')
		aws: _config.aws
		regarde:
			coffee:
				files: ["_src/**/*.coffee"]
				tasks: [ "coffee:changed", "includereplace" ]
			templatecoffee:
				files: ["_src_template/**/*.coffee"]
				tasks: [ "coffee:changedtemplate", "includereplace" ]
			jade:
				files: ["_src_template/**/*.jade"]
				tasks: [ "jade" ]
			stylus:
				files: ["_src_template/**/*.styl"]
				tasks: [ "stylus" ]
			static:
				files: ["_src_template/static/**/*.*"]
				tasks: [ "copy:static" ]
		coffee:
			changed:
				expand: true
				cwd: '_src'
				src:	[ '<% print( _.first( ((typeof grunt !== "undefined" && grunt !== null ? (_ref = grunt.regarde) != null ? _ref.changed : void 0 : void 0) || ["_src/nothing"]) ).slice( "_src/".length ) ) %>' ]
				# template to cut off `_src/` and throw on error on non-regrade call
				# CF: `_.first( grunt?.regarde?.changed or [ "_src/nothing" ] ).slice( "_src/".length )
				dest: ''
				ext: '.js'

			changedtemplate:
				expand: true
				cwd: '_src_template'
				src:	[ '<% print( _.first( ((typeof grunt !== "undefined" && grunt !== null ? (_ref = grunt.regarde) != null ? _ref.changed : void 0 : void 0) || ["_src_template/nothing"]) ).slice( "_src_template/".length ) ) %>' ]
				# template to cut off `_src_template/` and throw on error on non-regrade call
				# CF: `_.first( grunt?.regarde?.changed or [ "_src_template/nothing" ] ).slice( "_src_template/".length )
				dest: '_template'
				ext: '.js'

			base:
				expand: true
				cwd: '_src',
				src: ["lib/**/*.coffee", "test/**/*.coffee", "*.coffee"]
				dest: ''
				ext: '.js'

			gui:
				expand: true
				cwd: '_src_template',
				src: ["js/**/*.coffee"]
				dest: '_template/'
				ext: '.js'

		jade: 
			templates:
				options:
					debug: false
					pretty: true

				files: 
					"_template/index.html": "_src_template/index.jade"

			frontend:
				options:
					debug: false
					client: true
					namespace: "Tmpls"
					compileDebug: false
					pretty: true
					amd: true
					processName: ( filename )->
						_l = "_src_template/templates/".length
						return filename[ _l.. ].replace( ".jade", "" )

				files: 
					"_template/js/tmpl.js": "_src_template/templates/*.jade"

		stylus:
			options:
				"include css": true
			styles:
				files:
					"_template/css/styles.css": ["_src_template/css/_main.styl"]
		
		includereplace:
			pckg:
				options:
					globals:
						version: "<%= pkg.version %>"

					prefix: "@@"
					suffix: ''

				files:
					"": ["index.js", "_template/js/main.js", "_template/js/tmpl.js", "_template/index.html"]

		copy:
			static:
				expand: true
				cwd: '_src_template/static/',
				src: [ "**" ]
				dest: "_template"

		aws_s3:
			options:
				accessKeyId: '<%= aws.key %>'
				secretAccessKey: '<%= aws.secret %>'
				bucket: '<%= aws.bucket %>'
				region: 'eu-west-1'
				access: 'public-read'
				params:
					"CacheControl": "max-age=630720000, public",
			template: 
				files: [
					 { expand: true, cwd: '_template/', src: ['**'], dest: ''}
				]

	# Load npm modules
	grunt.loadNpmTasks "grunt-regarde"
	grunt.loadNpmTasks "grunt-contrib-coffee"
	grunt.loadNpmTasks "grunt-include-replace"
	grunt.loadNpmTasks "grunt-contrib-jade"
	grunt.loadNpmTasks "grunt-contrib-stylus"
	grunt.loadNpmTasks "grunt-contrib-copy"
	grunt.loadNpmTasks('grunt-aws-s3')


	# just a hack until this issue has been fixed: https://github.com/yeoman/grunt-regarde/issues/3
	grunt.option('force', not grunt.option('force'))
	
	# ALIAS TASKS
	grunt.registerTask "watch", "regarde"
	grunt.registerTask "default", "build"
	grunt.registerTask "deploytemplate", ["build", "aws_s3:template"]

	# build the project
	grunt.registerTask "build", [ "coffee", "stylus", "jade", "copy", "includereplace" ]	