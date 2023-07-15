#!/bin/bash

set -ex

dart format .

swiftformat --swiftversion 5.2 .

ktlint -F
