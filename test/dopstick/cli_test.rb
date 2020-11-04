# frozen_string_literal: true

require "test_helper"

class CLITest < Minitest::Test
  def gem_root
    @gem_root ||= tmp_dir.join("newgem")
  end

  def tmp_dir
    @tmp_dir ||= Pathname.new(File.expand_path("#{__dir__}/../../tmp"))
  end

  def run_command(args)
    Dopstick::CLI.start([
      "new",
      *args
    ].compact)
  end

  setup do
    Dir[tmp_dir.join("*")].each do |entry|
      FileUtils.rm_rf(entry)
    end
  end

  test "creates gems with defaults" do
    capture_io do
      run_command [gem_root]
    end

    assert gem_root.join(".gitignore").file?
    assert gem_root.join(".rubocop.yml").file?
    assert gem_root.join("CHANGELOG.md").file?
    assert gem_root.join("CODE_OF_CONDUCT.md").file?
    assert gem_root.join("CONTRIBUTING.md").file?
    assert gem_root.join("Gemfile").file?
    assert gem_root.join("LICENSE.md").file?
    assert gem_root.join("newgem.gemspec").file?
    assert gem_root.join("Rakefile").file?
    assert gem_root.join("README.md").file?
    assert gem_root.join(".github/FUNDING.yml").file?
    assert gem_root.join(".github/PULL_REQUEST_TEMPLATE.md").file?
    assert gem_root.join(".github/workflows/tests.yml").file?
    assert gem_root.join(".github/ISSUE_TEMPLATE/bug_report.md").file?
    assert gem_root.join(".github/ISSUE_TEMPLATE/feature_request.md").file?
    assert gem_root.join("bin/console").executable?
    assert gem_root.join("bin/setup").executable?
    assert gem_root.join("lib/newgem.rb").file?
    assert gem_root.join("lib/newgem/version.rb").file?
    assert gem_root.join("test/test_helper.rb").file?
    assert gem_root.join("test/newgem_test.rb").file?
    assert_includes gem_root.join("lib/newgem.rb").read, "module Newgem"

    workflow_yml = YAML.load_file(gem_root.join(".github/workflows/tests.yml"))

    assert_equal %w[2.6.x 2.7.x],
                 workflow_yml.dig("jobs", "build", "strategy", "matrix", "ruby")
  end

  test "creates gems using custom name" do
    capture_io do
      run_command %W[#{gem_root} --name nicegem]
    end

    assert gem_root.join("lib/nicegem.rb").file?
    assert gem_root.join("lib/nicegem/version.rb").file?
    assert gem_root.join("test/test_helper.rb").file?
    assert gem_root.join("test/nicegem_test.rb").file?
    assert_includes gem_root.join("lib/nicegem.rb").read, "module Nicegem"
  end

  test "creates gems using custom namespace (NiceGem)" do
    capture_io do
      run_command %W[#{gem_root} --namespace NiceGem]
    end

    assert gem_root.join("lib/nice_gem.rb").file?
    assert gem_root.join("lib/nice_gem/version.rb").file?
    assert gem_root.join("test/nice_gem_test.rb").file?
    assert_includes gem_root.join("lib/nice_gem.rb").read, "module NiceGem"
  end

  test "creates gems using custom namespace (HEYHO::LetsGo)" do
    capture_io do
      run_command %W[#{gem_root} --namespace HEYHO::LetsGo]
    end

    assert gem_root.join("lib/heyho-lets_go.rb").file?
    assert gem_root.join("lib/heyho/lets_go/version.rb").file?
    assert gem_root.join("test/heyho/lets_go_test.rb").file?
    assert_includes gem_root.join("lib/heyho-lets_go.rb").read,
                    %[require "heyho/lets_go"]

    rubocop = YAML.load_file(gem_root.join(".rubocop.yml"))
    assert_includes rubocop.dig("Naming/FileName", "Exclude"),
                    "lib/heyho-lets_go.rb"
  end

  test "creates gems using custom namespace and name (ramones/HEYHO::LetsGo)" do
    capture_io do
      run_command %W[#{gem_root} --name ramones --namespace HEYHO::LetsGo]
    end

    assert gem_root.join("lib/ramones.rb").file?
    assert gem_root.join("lib/heyho/lets_go.rb").file?
    assert gem_root.join("lib/heyho/lets_go/version.rb").file?
    assert gem_root.join("test/heyho/lets_go_test.rb").file?

    assert_includes gem_root.join("lib/ramones.rb").read,
                    %[require "heyho/lets_go"]

    source = gem_root.join("lib/heyho/lets_go.rb").read

    assert_includes source, %[module HEYHO]
    assert_includes source, %[module LetsGo]
  end

  test "creates gems with binary" do
    capture_io do
      run_command %W[#{gem_root} --bin mygem]
    end

    assert gem_root.join("exe/mygem").executable?
    assert gem_root.join("lib/newgem/cli.rb").file?
    assert gem_root.join("lib/newgem/generator.rb").file?
    assert_includes gem_root.join("newgem.gemspec").read,
                    %[spec.add_dependency "thor"]
  end

  test "creates gems with custom rubies" do
    capture_io do
      run_command %W[#{gem_root} --ruby-versions 2.6.3 2.7]
    end

    workflow_yml = YAML.load_file(gem_root.join(".github/workflows/tests.yml"))

    assert_equal %w[2.6.3 2.7.x],
                 workflow_yml.dig("jobs", "build", "strategy", "matrix", "ruby")
    assert_includes gem_root.join("newgem.gemspec").read,
                    %[Gem::Requirement.new(">= 2.6.3")]

    rubocop = YAML.load_file(gem_root.join(".rubocop.yml"))
    assert_equal 2.6, rubocop.dig("AllCops", "TargetRubyVersion")
  end

  test "creates gems with activerecord config" do
    capture_io do
      run_command %W[#{gem_root} --active-record]
    end

    gemspec = gem_root.join("newgem.gemspec").read

    assert_includes gemspec, %[spec.add_dependency "activerecord"]
    assert_includes gemspec, %[spec.add_development_dependency "pg"]

    assert gem_root.join("test/support/active_record.rb").file?
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
      assert_includes stdout, "Create a new gem"
    end
  end
end
