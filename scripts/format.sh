#!/bin/bash

set -ex

flutter format .

swiftformat --swiftversion 5.2 .

ktlint -F