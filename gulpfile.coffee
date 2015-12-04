gulp      = require 'gulp'
{Server}  = require 'karma'
csswring  = require 'csswring'
remove    = require 'gulp-rimraf'
streams   = require 'streamqueue'
coffee    = require 'gulp-coffee'
concat    = require 'gulp-concat'
uglify    = require 'gulp-uglify'
plumber   = require 'gulp-plumber'
postcss   = require 'gulp-postcss'
connect   = require 'gulp-connect'
srcmaps   = require 'gulp-sourcemaps'
htmlify   = require 'gulp-minify-html'
htmlace   = require 'gulp-html-replace'
prefixer  = require 'gulp-autoprefixer'

buildDir  = 'dist/'
srcDir    = 'src/'
modules   = 'node_modules/'
coffees   = '**/*.coffee'
cssFiles  = '**/*.css'
htmls     = [ "#{srcDir}**/*.html" ]

css = ->
  streams
    objectMode: true,
    gulp.src "#{modules}bootstrap/dist/css/bootstrap.css"
    gulp.src srcDir + cssFiles

js = (scripts) ->
  streams
    objectMode: true,
    gulp.src "#{modules}jquery/dist/jquery.js"
    gulp.src "#{modules}bootstrap/dist/js/bootstrap.js"
    gulp.src "#{modules}angular/angular.js"
    gulp.src scripts
      .pipe plumber()
      .pipe coffee bare: true
      .on 'error', -> console?.log error

gulp.task 'clean', ->
  gulp.src buildDir
    .pipe remove force: true

gulp.task 'css', ->
  css()
    .pipe srcmaps.init()
    .pipe plumber()
    .pipe prefixer()
    .pipe plumber()
    .pipe concat 'index.css'
    .pipe plumber()
    .pipe postcss [ csswring removeAllComments: true ]
    .pipe srcmaps.write('debug')
    .pipe gulp.dest buildDir
    .pipe connect.reload()

gulp.task 'js', ->
  js srcDir + coffees
    .pipe srcmaps.init()
    .pipe plumber()
    .pipe concat 'index.js'
    .pipe plumber()
    .pipe uglify()
    .pipe srcmaps.write('debug')
    .pipe gulp.dest buildDir
    .pipe connect.reload()

gulp.task 'html', ->
  gulp.src htmls
    .pipe plumber()
    .pipe htmlace
      css: '<link rel="stylesheet" href="index.css">'
      js: '<script src="index.js"></script>'
    .pipe plumber()
    .pipe htmlify
      quotes: true
      conditionals: true
      spare: true
    .pipe gulp.dest buildDir
    .pipe connect.reload()

gulp.task 'default', ['css', 'js', 'html']

gulp.task 'connect', ->
  connect.server
    root: buildDir
    livereload: true

gulp.task 'serve', ['default', 'connect']

gulp.task 'css-dev', ->
  css()
    .pipe gulp.dest buildDir
    .pipe connect.reload()

devScripts = [ srcDir + coffees
               "tests/#{coffees}" ]
gulp.task 'js-dev', ->
  streams
      objectMode: true,
      gulp.src "#{modules}angular-mocks/angular-mocks.js"
      js devScripts
    .pipe gulp.dest buildDir
    .pipe connect.reload()

gulp.task 'html-dev', ->
  gulp.src htmls
    .pipe gulp.dest buildDir
    .pipe connect.reload()

config = "#{__dirname}/#{buildDir}karma.conf.js"

gulp.task 'test', (done) ->
  new Server(
        configFile: config
        singleRun: true,
      done)
    .start()

gulp.task 'watch', ['connect'], ->
  gulp.watch "#{buildDir}**/*", ['test']
  gulp.watch srcDir + cssFiles, ['css-dev']
  gulp.watch devScripts, ['js-dev']
  gulp.watch htmls, ['html-dev']

gulp.task 'dev', ['css-dev', 'html-dev', 'js-dev']
