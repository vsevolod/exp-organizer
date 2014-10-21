# gulpfile.js
# put into ~/.bash_profile >> alias gulp="gulp --require coffee-script/register"
gulp       = require 'gulp'
coffee     = require 'gulp-coffee'
server     = require 'gulp-develop-server'
livereload = require 'gulp-livereload'

options = {
  path: 'public/app.js'
}

gulp.task 'server:restart', ->
  gulp.src './app/**/*.coffee'
    .pipe do coffee
    .pipe gulp.dest('./public')
    .pipe server(options)
    .pipe do livereload

gulp.task 'default', ['server:restart'], ->
  gulp.watch './app/**/*.coffee', ['server:restart']
