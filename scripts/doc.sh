#!/bin/bash

# Generate documentation using dartdoc
# Usage: ./scripts/doc.sh

set -e

cd "$(dirname "$0")/.."

rm -rf doc/
flutter pub global run dartdoc:dartdoc
