.PHONY: version doctor

FVM = fvm

ifeq (, $(shell which ${FVM}))
	FLUTTER = flutter
	DART = dart
else
	FLUTTER = $(FVM) flutter
	DART = $(FVM) dart
endif

init: init-fvm init-global

swiftpm-on:
	$(FLUTTER) config --enable-swift-package-manager

swiftpm-off:
	$(FLUTTER) config --no-enable-swift-package-manager

flutter-precaches:
	$(FLUTTER) precache --android
	$(FLUTTER) precache --ios

init-fvm:
	$(FVM) install; $(FVM) use --force;

version:
	$(FLUTTER) --version; $(DART) --version;

doctor:
	$(FLUTTER) doctor;

# команда чтобы добавить в текущий коммит форматирование
git-format-push:
	git add .
	git commit --amend --no-edit
	git push -f

# flutter clean
clean:
	$(FLUTTER) clean;

# dart format
fmt:
	$(DART) format .

# dart fix
fix:
	$(DART) fix --apply

ff: fix fmt

lint:
	$(FLUTTER) analyze

# Task: Bootstrap Project
bootstrap:
	bash ./scripts/bootstrap.bash

# build_runner (b)
build_runner:
	$(DART) run build_runner build  --delete-conflicting-outputs

l10n:
	$(FLUTTER) gen-l10n

clear-core-gen:
	rm -rf lib/core/gen & 2>/dev/null

b:
	make clear-core-gen
	make build_runner
	make l10n
	make ff

bff: build_runner l10n ff

# clean & pub get & buld_runner & format
clean-build-format:
	./scripts/build_runner.sh

# gen l10n
gen-l10n:
	$(FLUTTER) gen-l10n

test:
	$(FLUTTER) test

# clean tests reports
clean-tests:
	rm -rf reports

avd:
	./scripts/run_avd.sh

cdeps: clean deps

deps:
	$(FLUTTER) pub get
	make fmt

deps-log:
	$(FLUTTER) pub deps > deps.txt

splashgen:
	$(DART) run flutter_native_splash:create

codegen-re: vec swagger-gen b

widgetbook-gen:
	$(DART) run build_runner build --build-filter="./lib/presentation/**/*.dart|./lib/main_widgetbook.dart"

app-bloc-gen:
	$(DART) run build_runner build --build-filter="./lib/bloc/**/*.dart"

swagger-gen:
	$(DART) run swagger_parser

swagger-regen:
	make swagger-gen-clear
	make swagger-gen

force-clean-codegen:
	@echo "* Cleaning build runner *"
	find . -type f -name "*.gr.dart" -delete
	find . -type f -name "*.g.dart" -delete
	find . -type f -name "*.freezed.dart" -delete
	find . -type f -name "*.gen.dart" -delete
	find . -type f -name "*.stories.book.dart" -delete

prepare-build:
	rm -rf build
	$(FLUTTER) clean
	make codegen

ruby-install:
	./scripts/ruby_install.sh

pod-install:
	./scripts/pod_install.sh

pod-uninstall:
	$(FLUTTER) clean
	cd ios && pod deintegrate
	cd ios && pod cache clean --all
	rm -Rf ios/Pods
	rm -Rf ios/.symlinks
	rm -Rf ios/Flutter/Flutter.framework
	rm -Rf ios/Flutter/Flutter.podspec
	rm -rf ios/Podfile.lock

pod-reinstall:
	make pod-uninstall
	make deps
	make pod-install

# В случае trunk URL couldn't be downloaded
pod:
	cd ios
	pod repo remove trunk
	pod install

make-gherkin-report:
	node ./integration_test/make_report.js

gherkin-test-suite:
	$(FLUTTER) test ./integration_test/gherkin_test_suite.dart \
		--flavor staging \
		--exclude-tags "skip||manual" \
		--dart-define=FLUTTER_TEST_OUTPUTS_DIR=integration_test/gherkin/reports

gherkin-test-suite-only-tags:
	$(FLUTTER) test ./integration_test/gherkin_test_suite.dart \
		--flavor staging \
		--tags "only" \
		--dart-define=FLUTTER_TEST_OUTPUTS_DIR=integration_test/gherkin/reports

# Команду следует запускать после удаления, переименований, удалений в assets/svg
vec-build:
	rm -rf assets/vec & 2>/dev/null
	make vec

vec:
	mkdir -p assets/vec/
	mkdir -p assets/vec/markers
	$(DART) run vector_graphics_compiler --input-dir assets/svg/markers --out-dir assets/vec/markers --no-optimize-overdraw
	git add ./assets/vec

run-stg:
	$(FLUTTER) run --flavor staging -t lib/main.dart --dart-define-from-file=.env.stg

run-prod:
	$(FLUTTER) run --flavor production -t lib/main.dart --dart-define-from-file=.env.prod

run-test-tool:
	$(FLUTTER) run --flavor staging -t lib/main_factory_test_tool.dart --dart-define-from-file=.env.stg

# Настроить version_assist
# Шаг 0. Скачать с pubdev
version-assist-init:
	cd ../
	mkdir "pubdev"
	cd pubdev
	git clone https://github.com/kuyazee/version_assist.git
	cd version_assist
	$(DART) pub get
# Шаг 1 сделать команду глобальной
version-assist-global:
	cd ../pubdev/version_assist
	# From the version_assist directory
	$(DART) pub global activate --source path .
	# Now you can run it like a global command: version_assist bump

release-start:
	./scripts/release_start.sh
	version_assist commit

release-commit-dry-run:
	version_assist commit --dry-run

release-bump:
	version_assist bump --date-based-build-number --add-build-number --auto-commit

# Clears out all your local
# All remote tags give you a complete list of remote tags locally
git-fetch-tags:
	git tag -d $(git tag -l)
	git fetch -p

git-push-release:
	git push
	git push --tags

git-last-diff:
	$(DART) run scripts/git_last_diff.dart
