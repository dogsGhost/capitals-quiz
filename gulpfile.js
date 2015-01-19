var gulp = require('gulp');
var coffee = require('gulp-coffee');
var concat = require('gulp-concat');
var sass = require('gulp-sass');
var uglify = require('gulp-uglify');

gulp.task('coffee', function() {
    return gulp.src('./coffee/quiz.coffee')
        .pipe(coffee())
        .pipe(uglify())
        .pipe(gulp.dest('./js'));
});

gulp.task('concat', function() {
    return gulp.src([
            './js/jquery.js',
            './js/handlebars.js'
        ])
        .pipe(concat('libraries.min.js'))
        .pipe(uglify())
        .pipe(gulp.dest('./js'));
});

gulp.task('sass', function() {
    return gulp.src('./sass/style.scss')
        .pipe(sass({
            outputStyle: 'compressed',
            precision: 3,
            errLogToConsole: true
        }))
        .pipe(gulp.dest('./css'));
});

gulp.task('default', ['concat', 'coffee', 'sass']);