all: watch

watch:
	coffee -w -b -c Gulpfile.coffee app &
	pug -w app/views &
	gulp &
	sleep infinity
