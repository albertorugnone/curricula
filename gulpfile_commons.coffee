commons =
  gulp : require 'gulp'
  rimraf : require 'gulp-rimraf'
  
  paths :
    appJs: ['./app/**/*.coffee','./app/**/*.js']
    appCss: ['./app/**/*.less', './app/**/*.css']
    img:['./app/**/*.png','./app/**/*.gif','./app/**/*.jpg']
    fonts:['./bower_components/bootstrap/fonts/*'] 
    templates: [
      '!./app/index.jade',
      '!./app/index.html',
      './app/**/*.html',
      './app/**/*.jade'
    ]
    index: ['./app/index.jade']

  ngClassifyDefinitions : (file, options) ->
      ##for windows
      return appName: 'survey.sidebar' if file.path.indexOf('components\\sidebar') isnt -1
      return appName: 'survey.translator' if file.path.indexOf('components\\translator') isnt -1
      return appName: 'survey.service' if file.path.indexOf('components\\service') isnt -1
      return appName: 'survey.building' if file.path.indexOf('components\\building') isnt -1
      return appName: 'survey.company' if file.path.indexOf('components\\company') isnt -1
      return appName: 'survey.employees' if file.path.indexOf('components\\employees') isnt -1
      ##for unix
      return appName: 'survey.sidebar' if file.path.indexOf('components/sidebar') isnt -1
      return appName: 'survey.translator' if file.path.indexOf('components/translator') isnt -1
      return appName: 'survey.service' if file.path.indexOf('components/service') isnt -1
      return appName: 'survey.building' if file.path.indexOf('components/building') isnt -1
      return appName: 'survey.company' if file.path.indexOf('components/company') isnt -1
      return appName: 'survey.employees' if file.path.indexOf('components/employees') isnt -1
      return appName: 'survey'

commons.gulp.task 'clean', ->
  commons.gulp.src 'dist/'
    .pipe commons.rimraf
      read: false
      force: true

module.exports = commons
