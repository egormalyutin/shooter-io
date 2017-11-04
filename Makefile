all: watch

install:
	npm i -g coffeescript pug-cli gulp

watch:
	coffee -w -b -c Gulpfile.coffee app &
	pug -w app/views &
	gulp &
	sleep infinity
