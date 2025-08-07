.PHONY: pub-get b

FVM = fvm

ifeq (, $(shell which ${FVM}))
	FLUTTER = flutter
	DART = dart
else
	FLUTTER = $(FVM) flutter
	DART = $(FVM) dart
endif

# команда чтобы добавить в текущий коммит форматирование
git-format-push:
	git add .
	git commit --amend --no-edit
	git push -f

# flutter clean
clean:
	$(FLUTTER) clean

# dart format
fmt:
	$(DART) format .

# dart fix
fix:
	$(DART) fix --apply

ff: fix fmt

build:
	$(DART) run build_runner build  --delete-conflicting-outputs

b: build ff

cdeps: clean deps

pub-get:
	$(FLUTTER) pub get

deps: pub-get

deps-log:
	$(FLUTTER) pub deps > deps.txt

main: pub-get b

force-clean-codegen:
	@echo "* Cleaning build runner *"
	find . -type f -name "*.gr.dart" -delete
	find . -type f -name "*.g.dart" -delete
	find . -type f -name "*.freezed.dart" -delete
	find . -type f -name "*.gen.dart" -delete
	find . -type f -name "*.stories.book.dart" -delete
