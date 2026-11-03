# Everyday commands. Android needs a flavor: dev, staging or prod.
#   make run          dev build on the connected device/emulator
#   make check        everything CI runs: analyze + tests
#   make release      signed Play Store bundle (needs .env.json + android/key.properties)

.PHONY: run run-staging run-prod check analyze test l10n release apk-dev clean

run:
	flutter run --flavor dev

run-staging:
	flutter run --flavor staging --dart-define-from-file=.env.json

run-prod:
	flutter run --flavor prod --release --dart-define-from-file=.env.json

check: analyze test

analyze:
	flutter analyze --no-fatal-infos

test:
	flutter test

# Regenerate Dart code after editing lib/l10n/*.arb (also runs on pub get)
l10n:
	flutter gen-l10n

apk-dev:
	flutter build apk --debug --flavor dev

release:
	@test -f .env.json || { echo "Missing .env.json (copy .env.example.json and fill in real IDs)"; exit 1; }
	@test -f android/key.properties || { echo "Missing android/key.properties (release signing)"; exit 1; }
	flutter build appbundle --release --flavor prod --dart-define-from-file=.env.json
	@echo "Upload build/app/outputs/bundle/prodRelease/app-prod-release.aab to Play Console"

clean:
	flutter clean
