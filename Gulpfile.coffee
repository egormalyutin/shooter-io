gulp   = require 'gulp'
rename = require 'gulp-rename'
watch  = require 'gulp-watch'
sass   = require 'gulp-sass'

gulp.task 'default', () ->
	watch 'app/public/css/**/*.sass', () ->
		gulp.src 'app/public/css/**/*.sass'
			.pipe sass().on 'error', sass.logError
			.pipe gulp.dest 'app/public/css'