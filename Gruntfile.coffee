module.exports = (grunt) ->

	# Project configuration.
	grunt.initConfig
		pkg: grunt.file.readJSON('package.json')
		regarde:
			coffee:
				files: ["_src/**/*.coffee"]
				tasks: [ "coffee:changed", "includereplace" ]
			jade:
				files: ["_src/**/*.jade"]
				tasks: [ "jade" ]
			stylus:
				files: ["_src/**/*.styl"]
				tasks: [ "stylus" ]
			static:
				files: ["_src/_template/static/**/*.*"]
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

			base:
				expand: true
				cwd: '_src',
				src: ["**/*.coffee"]
				dest: ''
				ext: '.js'

		jade: 
			templates:
				options:
					debug: false
					pretty: true

				files: 
					"_template/index.html": "_src/_template/index.jade"

		stylus:
			options:
				"include css": true
			styles:
				files:
					"_template/css/styles.css": ["_src/_template/css/_main.styl"]
		
		includereplace:
			pckg:
				options:
					globals:
						version: "<%= pkg.version %>"

					prefix: "@@"
					suffix: ''

				files:
					"": ["index.js"]

		copy:
			static:
				expand: true
				cwd: '_src/_template/static/',
				src: [ "**" ]
				dest: "_template"

	# Load npm modules
	grunt.loadNpmTasks "grunt-regarde"
	grunt.loadNpmTasks "grunt-contrib-coffee"
	grunt.loadNpmTasks "grunt-include-replace"
	grunt.loadNpmTasks "grunt-contrib-jade"
	grunt.loadNpmTasks "grunt-contrib-stylus"
	grunt.loadNpmTasks "grunt-contrib-copy"


	# just a hack until this issue has been fixed: https://github.com/yeoman/grunt-regarde/issues/3
	grunt.option('force', not grunt.option('force'))
	
	# ALIAS TASKS
	grunt.registerTask "watch", "regarde"
	grunt.registerTask "default", "build"

	# build the project
	grunt.registerTask "build", [ "coffee", "stylus", "jade", "copy", "includereplace" ]	