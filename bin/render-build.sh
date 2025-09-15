#!/usr/bin/env bash

# Exit on error
set -o errexit

bundle install
bin/rails assets:precompile
bin/rails assets:clean
