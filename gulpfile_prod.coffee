paths = require('./gulpfile_commons.coffee').paths
gulp = require('./gulpfile_commons.coffee').gulp
ngClassifyDefinitions = require('./gulpfile_commons.coffee').ngClassifyDefinitions

gutil      = require 'gulp-util'
connect    = require 'gulp-connect'
gulpif     = require 'gulp-if'
coffee     = require 'gulp-coffee'
concat     = require 'gulp-concat'
tplCache   = require 'gulp-angular-templatecache'
jade       = require 'gulp-jade'
less       = require 'gulp-less'
ngClassify = require 'gulp-ng-classify'
coffeelint = require 'gulp-coffeelint'
backend    = require './backend/app'

maven = require 'gulp-maven-deploy'
uglify     = require 'gulp-uglify'
minifyCSS  = require 'gulp-minify-css'

protractor = require('gulp-protractor').protractor

paths.libJs = [
      './bower_components/jquery/dist/jquery.min.js',
      './bower_components/bootstrap/dist/js/bootstrap.min.js',
      './bower_components/angular/angular.min.js',
      './bower_components/angular-ui-router/release/angular-ui-router.min.js'
      './bower_components/angular-animate/angular-animate.min.js'
      './bower_components/angular-translate/angular-translate.min.js'
      ]
paths.libCss = [
      './bower_components/bootstrap/dist/css/bootstrap.min.css'
    ]

gulp.task 'tests', ['connect'], ->
  gulp.src ['tests/e2e/**/*.spec.coffee']
  .pipe protractor
    configFile: 'tests/protractor.conf.coffee'

gulp.task 'deploy-local', ['tests'], ->
  gulp.src('.')
    .pipe maven.install(
      config:
        groupId: 'com.ducati'
        type: 'war'
        buildDir: 'mvn_dist'
    )

gulp.task 'js', ['clean'],  ->
  gulp.src paths.libJs
    .pipe concat 'lib.js'
    .pipe gulp.dest './dist/js'

  gulp.src paths.appJs #tutte le sottocartelle di app con file .coffee o .js
    .pipe coffeelint().on 'error', gutil.log
    .pipe ngClassify(ngClassifyDefinitions) .on 'error', gutil.log
    .pipe coffeelint.reporter().on 'error', gutil.log
    .pipe (gulpif /[.]coffee$/, coffee(bare: true).on 'error', gutil.log).on 'error', gutil.log
    .pipe uglify()
    .pipe concat('app.js').on 'error', gutil.log
    .pipe gulp.dest('./dist/js').on 'error', gutil.log

gulp.task 'html', ['clean'], ->
  gulp.src paths.index
    .pipe gulpif /[.]jade$/, jade({doctype: 'html'}).on 'error', gutil.log
    .pipe gulp.dest './dist/'
  gulp.src paths.templates
    .pipe gulpif /[.]jade$/, jade(doctype: 'html').on 'error', gutil.log
    .pipe tplCache 'templates.js', { standalone:true }
    .pipe gulp.dest './dist/js/'

gulp.task 'static', ['clean'],  ->
  gulp.src paths.img
    .pipe gulp.dest './dist'
  gulp.src paths.fonts
    .pipe gulp.dest './dist/fonts'

gulp.task 'css', ['clean'], ->
  gulp.src paths.appCss
    .pipe gulpif /[.]less$/, less
      paths: [
        './bower_components/bootstrap/less'
      ]
    .on 'error', gutil.log
    .pipe concat 'survey.css'
    .pipe minifyCSS()
    .pipe gulp.dest './dist/css'
  gulp.src paths.libCss
    .pipe concat 'lib.css'
    .pipe minifyCSS()
    .pipe gulp.dest './dist/css'

gulp.task 'connect', ['js', 'html', 'static', 'css'],  ->

  backend.set "port", process.env.PORT or 8001
  server = backend.listen(backend.get("port"), ->
    # debug "Express server listening on port " + server.address().port
    connect.server
      root: ['dist']
      port: 8000
      livereload: false
      middleware: (connect,o) ->
        [
          (->
            url = require 'url'
            proxy = require 'proxy-middleware'
            options = url.parse 'http://localhost:8001/v1'
            options.route = '/v1'
            proxy options
          )()
        ]
    return
  )

gulp.task 'default', ['deploy-local']