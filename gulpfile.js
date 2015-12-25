var gulp = require('gulp');
var del = require('del');
var install = require('gulp-install');
var coffee = require('gulp-coffee');
var jade = require('gulp-jade');
var runSequence = require('run-sequence');
var data = require('gulp-data')
var s3 = require('gulp-s3-upload')({useIAM: true});

// distディレクトリのクリーンアップと作成済みのdist.zipの削除
gulp.task('clean', function(cb) {
    del(['./dest/**'], cb);
});

gulp.task('compile-coffee', function() {
    gulp.src('./src/**/*.coffee')
        .pipe(coffee({bare: true}))
        .pipe(gulp.dest('./dest'))
});

gulp.task('compile-jade', function() {
    gulp.src('./src/**/*.jade')
        .pipe(data(function(file) {
            return require('./json/_common.json')
        }))
        .pipe(jade({pretty: true}))
        .pipe(gulp.dest('./dest'))
});

gulp.task("upload", function() {
    gulp.src("./dest/**")
        .pipe(s3({
            Bucket: 'sanix-data-analysis', //  Required
            ACL:    'public-read'       //  Needs to be user-defined
        }, {
            // S3 Construcor Options, ie:
            maxRetries: 5
        }));
});

gulp.task('build', function(callback) {
    return runSequence(
        ['compile-coffee', 'compile-jade'],
        callback
    );
});

gulp.task('default', function(callback) {
    return runSequence(
        ['build', 'upload'],
        callback
    );
});
