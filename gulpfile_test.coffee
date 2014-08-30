gulp = require 'gulp'
protractor = require('gulp-protractor').protractor

gulp.task 'default', ->
	gulp.src ['tests/e2e/**/*.spec.coffee']
	.pipe protractor
		configFile: 'tests/protractor.conf.coffee'

#gulp.watch ['tests/**/*.spec.coffee'], ['default']
