'use strict';

gulp   = require('gulp');
plugins = require('gulp-load-plugins')();
tap = require('gulp-tap');

donna = require('donna');
tello = require('tello');

CI = process.env.CI is 'true'

paths =
  coffee: ['./lib/**/*.coffee']
  watch: ['./gulpfile.js', './lib/**', './spec/**', '!spec/{temp,temp/**}']
  tests: ['./spec/**/*.coffee', '!spec/{temp,temp/**}']

plumberConf = {}
if process.env.CI
  plumberConf.errorHandler = (err) ->
    throw err;

gulp.task 'lint', ->
  gulp.src(paths.coffee)
    .pipe(plugins.coffeelint())
    .pipe(plugins.coffeelint.reporter())

gulp.task 'istanbul', (cb) ->
  runMocha = ->
    reporter = if CI then 'spec' else 'nyan'
    gulp.src(paths.tests)
      .pipe(plugins.plumber(plumberConf))
      .pipe(plugins.mocha({reporter, timeout: '5s'}))
      .pipe(plugins.coffeeIstanbul.writeReports()) # Creating the reports after tests runned
      .on 'finish', ->
        process.chdir(__dirname)
        cb()

  gulp.src(paths.coffee)
    .pipe(plugins.coffeeIstanbul()) # Covering files
    .pipe(plugins.coffeeIstanbul.hookRequire()) # Force `require` to return covered files
    .on 'finish', -> runMocha()
  null

gulp.task 'bump', ['test'], ->
  bumpType = plugins.util.env.type || 'patch'; # major.minor.patch

  gulp.src(['./package.json'])
    .pipe(plugins.bump({ type: bumpType }))
    .pipe(gulp.dest('./'))

gulp.task 'watch', ['test'], ->
  gulp.watch(paths.watch, ['test'])

gulp.task('test', ['lint', 'istanbul'])

gulp.task('release', ['bump'])

gulp.task 'dist', ->
  gulp.src(paths.coffee, {base: './lib'})
    .pipe(plugins.coffee({bare: true})).on('error', plugins.util.log)
    .pipe(gulp.dest('./dist'))

gulp.task 'doc', ->
  fs = require 'fs'
  metadata = donna.generateMetadata(['./lib'])
  fs.writeFileSync 'temp.json', JSON.stringify(metadata, null, 2)

  # stream = tap (file) ->
  #   metadata = donna.generateMetadata(['./lib/'])
  #   console.log metadata
  #   file.contents = new Buffer(JSON.stringify(metadata, null, 2))

  # gulp.src('./docs/api.json', {read: false})
  #   .pipe(stream)
  #   .pipe(gulp.dest('./docs'));

gulp.task('default', ['test', 'dist']);
