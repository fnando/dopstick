# frozen_string_literal: true

require "json"
require "date"
require "pathname"
require "thor"

module Dopstick
  require_relative "dopstick/version"
  require_relative "dopstick/refinements"
  require_relative "dopstick/generator"
  require_relative "dopstick/generator/options"
  require_relative "dopstick/generator/gem/options"
  require_relative "dopstick/generator/gem/generator"
  require_relative "dopstick/generator/npm/options"
  require_relative "dopstick/generator/npm/generator"
  require_relative "dopstick/cli"
end
