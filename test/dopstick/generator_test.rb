# frozen_string_literal: true

require "test_helper"

class GeneratorTest < Minitest::Test
  test "registers generators" do
    assert_equal Dopstick::Generator::Gem, Dopstick::Generator.registered["gem"]
  end
end
