# frozen_string_literal: true

require "test_helper"

class CLITest < Minitest::Test
  def tmp_dir
    @tmp_dir ||= Pathname.new(File.expand_path("#{Dir.pwd}/tmp"))
  end

  setup do
    Dir[tmp_dir.join("*")].each do |entry|
      FileUtils.rm_rf(entry)
    end
  end

  [
    %w[new ./tmp/newgem --help],
    %w[new --help],
    %w[new -h],
    %w[new]
  ].each do |args|
    test "shows help for 'new' command with #{args.inspect} args" do
      stdout = capture_io do
        assert_raises(SystemExit) { Dopstick::CLI.start(args) }
      end

      stdout = stdout.join

      refute Dir.exist?("./tmp/newgem")
      assert_match(/Usage:\n\s+.*?new PATH/, stdout)
      assert_includes stdout, "Create a new package"
    end
  end

  test "shows error for missing type" do
    stdout = capture_io do
      assert_raises(SystemExit) { Dopstick::CLI.start(%w[new ./tmp/pkg]) }
    end

    stdout = stdout.join

    refute Dir.exist?("./tmp/newgem")
    assert_includes stdout, "ERROR: --type must be one of"
  end
end
