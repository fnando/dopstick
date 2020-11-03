# frozen_string_literal: true

require "test_helper"

class RefinementsTest < Minitest::Test
  using Dopstick::Refinements

  test "camelizes string" do
    {
      "some-gem_name" => "Some::GemName",
      "some_gem-gem_name" => "SomeGem::GemName",
      "some_gem_name" => "SomeGemName",
      "some-gem-name" => "Some::Gem::Name"
    }.each do |gem_name, namespace|
      assert_equal namespace, gem_name.camelize
    end
  end

  test "transforms to underscore" do
    assert_equal "api", "API".underscore
    assert_equal "some/api", "Some::API".underscore
    assert_equal "ar/check", "AR::Check".underscore
  end
end
