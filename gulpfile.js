'use strict';

var gulp   = require('gulp');
var plugins = require('gulp-load-plugins')();

var paths = {
  jslint: ['./gulpfile.js', './lib/**/*.js'],
  coffeelint: ['./lib/**/*.coffee'],
  watch: ['./gulpfile.js', './lib/**', './test/**/*.js', '!test/{temp,temp/**}'],
  tests: ['./out/test/**/*.js', '!out/test/{temp,temp/**}'],
  source: ['./out/lib/*.js'],
  coffee: ['./lib/**/*.coffee', './test/**/*.coffee'],
};

var plumberConf = {};

if (process.env.CI) {
  plumberConf.errorHandler = function(err) {
    throw err;
  };
}

gulp.task('coffee', function () {
  return gulp.src(paths.coffee, {base: '.'})
    .pipe(plugins.coffee({bare: true})).on('error', plugins.util.log)
    .pipe(gulp.dest('./out'));
});

gulp.task('jslint', function () {
  return gulp.src(paths.jslint)
    .pipe(plugins.jshint('.jshintrc'))
    .pipe(plugins.plumber(plumberConf))
    .pipe(plugins.jscs())
    .pipe(plugins.jshint.reporter('jshint-stylish'));
});

gulp.task('coffeelint', function () {
  return gulp.src(paths.coffeelint)
    .pipe(plugins.coffeelint())
    .pipe(plugins.coffeelint.reporter());
});

gulp.task('istanbul', ['coffee'], function (cb) {
  gulp.src(paths.source)
    .pipe(plugins.istanbul()) // Covering files
    .pipe(plugins.istanbul.hookRequire()) // Force `require` to return covered files
    .on('finish', function () {
      gulp.src(paths.tests)
        .pipe(plugins.plumber(plumberConf))
        .pipe(plugins.mocha())
        .pipe(plugins.istanbul.writeReports()) // Creating the reports after tests runned
        .on('finish', function() {
          process.chdir(__dirname);
          cb();
        });
    });
});

gulp.task('bump', ['test'], function () {
  var bumpType = plugins.util.env.type || 'patch'; // major.minor.patch

  return gulp.src(['./package.json'])
    .pipe(plugins.bump({ type: bumpType }))
    .pipe(gulp.dest('./'));
});

gulp.task('watch', ['test'], function () {
  gulp.watch(paths.watch, ['test']);
});

gulp.task('lint', ['jslint', 'coffeelint']);
gulp.task('test', ['lint', 'coffee', 'istanbul']);

gulp.task('release', ['bump']);

gulp.task('default', ['test']);
