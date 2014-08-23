gulp       = require 'gulp'
gutil      = require 'gulp-util'
connect    = require 'gulp-connect'
gulpif     = require 'gulp-if'
coffee     = require 'gulp-coffee'
concat     = require 'gulp-concat'
tplCache   = require 'gulp-angular-templatecache'
jade       = require 'gulp-jade'
less       = require 'gulp-less'
protractor = require('gulp-protractor').protractor
sourcemaps = require 'gulp-sourcemaps'
ngClassify = require 'gulp-ng-classify'
coffeelint = require 'gulp-coffeelint'
rimraf     = require 'gulp-rimraf'

paths =
  appJs: ['./app/**/*.coffee','./app/**/*.js']
  appCss: ['./app/**/*.less', './app/**/*.css']
  img:['./app/**/*.png','./app/**/*.gif','./app/**/*.jpg']
  fonts:['./bower_components/bootstrap/fonts/*']
  libJs: [
    './bower_components/jquery/dist/jquery.js',
    './bower_components/bootstrap/dist/js/bootstrap.js',
    './bower_components/angular/angular.js',
    './bower_components/angular-ui-router/release/angular-ui-router.js'
    './bower_components/angular-animate/angular-animate.js'
    './bower_components/angular-translate/angular-translate.js'
    ]
  libCss: [
    '!./**/*.min.css',
    './bower_components/**/*.css'
  ]
  templates: [
    '!./app/index.jade',
    '!./app/index.html',
    './app/**/*.html',
    './app/**/*.jade'
  ]
  index: ['./app/index.jade']

gulp.task 'clean', ->
  gulp.src 'dist/'
    .pipe rimraf
      read: false
      force: true

gulp.task 'appJs',  ->
  gulp.src paths.appJs #tutte le sottocartelle di app con file .coffee o .js
    .pipe coffeelint().on 'error', gutil.log
    .pipe ngClassify((file, options) ->
      ##for windows
      return appName: 'survey.sidebar' if file.path.indexOf('components\\sidebar') isnt -1
      return appName: 'survey.translator' if file.path.indexOf('components\\translator') isnt -1
      return appName: 'survey.service' if file.path.indexOf('components\\service') isnt -1      
      ##fol unix
      return appName: 'survey.sidebar' if file.path.indexOf('components/sidebar') isnt -1
      return appName: 'survey.translator' if file.path.indexOf('components/translator') isnt -1
      return appName: 'survey.service' if file.path.indexOf('components/service') isnt -1
      return appName: 'survey') .on 'error', gutil.log
    .pipe coffeelint.reporter().on 'error', gutil.log
    .pipe sourcemaps.init().on 'error', gutil.log
    .pipe (gulpif /[.]coffee$/, coffee(bare: true).on 'error', gutil.log).on 'error', gutil.log
    .pipe concat('app.js').on 'error', gutil.log
    .pipe sourcemaps.write('./maps').on 'error', gutil.log
    .pipe gulp.dest('./dist/js').on 'error', gutil.log

gulp.task 'libJs', ->
  gulp.src paths.libJs
    .pipe concat 'lib.js'
    .pipe gulp.dest './dist/js'

gulp.task 'index', ->
  gulp.src paths.index
    .pipe gulpif /[.]jade$/, jade({doctype: 'html'}).on 'error', gutil.log
    .pipe gulp.dest './dist/'

gulp.task 'templates', ->
  gulp.src paths.templates
    .pipe gulpif /[.]jade$/, jade(doctype: 'html').on 'error', gutil.log
    .pipe tplCache 'templates.js', { standalone:true }
    .pipe gulp.dest './dist/js/'

gulp.task 'appCss', ->
  gulp.src paths.appCss
    .pipe gulpif /[.]less$/, less
      paths: [
        './bower_components/bootstrap/less'
      ]
    .on 'error', gutil.log
    .pipe concat 'survey.css'
    .pipe gulp.dest './dist/css'

gulp.task 'libCss', ->
  gulp.src paths.libCss
    .pipe concat 'lib.css'
    .pipe gulp.dest './dist/css'

gulp.task 'img',  ->
  gulp.src paths.img
    .pipe gulp.dest './dist'

gulp.task 'fonts',  ->
  gulp.src paths.fonts
    .pipe gulp.dest './dist/fonts'

gulp.task 'connect', ->
  connect.server
    root: ['dist']
    port: 8000
    livereload: true
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

gulp.task 'watch', ->
  # reload connect server on built file change
  gulp.watch [
    'dist/**/*.html'
    'dist/**/*.js'
    'dist/**/*.css'
  ], (event) ->
    gulp.src event.path
      .pipe connect.reload()
  # watch files to build
  gulp.watch [
    './app/**/*.coffee',
    './app/**/*.js'],
    ['appJs']
  gulp.watch [
    '!./app/index.jade',
    '!./app/index.html',
    './app/**/*.jade',
    './app/**/*.html'],
    ['templates']
  gulp.watch ['./app/**/*.less','./app/**/*.css'], ['appCss']
  gulp.watch ['./app/index.jade', './app/index.html'], ['index']
  return

gulp.task 'libMap', ->
  # copy sourcemaps for each libs
  gulp.src [
    './bower_components/bootstrap/dist/css/bootstrap.css.map'
  ]
  .pipe gulp.dest './dist/css'  

gulp.task 'default', [
  'appJs',
  'libJs',
  'index',
  'templates',
  'appCss',
  'libCss',
  'img',
  'fonts',
  'libMap',
  'connect',
  'watch'
]
