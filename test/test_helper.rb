# frozen_string_literal: true

require "simplecov"
SimpleCov.start

require "bundler/setup"
require_relative "../lib/dopstick"

require "minitest/utils"
require "minitest/autorun"
require "fileutils"
require "yaml"
