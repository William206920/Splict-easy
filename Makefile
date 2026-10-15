.PHONY: test check build-native build-web run-cli

test:
	moon test --target native
	moon test --target js

check:
	moon check --target native
	moon check --target js

build-native:
	moon build --target native

build-web:
	bash web/build.sh

run-cli:
	moon run cli/main --target native
