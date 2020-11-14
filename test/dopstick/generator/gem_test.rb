# frozen_string_literal: true

require "test_helper"

class GemTest < Minitest::Test
  def pkg_root
    @pkg_root ||= tmp_dir.join("newgem")
  end

  def tmp_dir
    @tmp_dir ||= Pathname.new(File.expand_path("#{Dir.pwd}/tmp"))
  end

  def run_command(args)
    Dopstick::CLI.start([
      "new",
      "--type", "gem",
      "--skip-install",
      *args.map(&:to_s)
    ].compact)
  end

  setup do
    Dir[tmp_dir.join("*")].each do |entry|
      FileUtils.rm_rf(entry)
    end
  end

  test "creates gems with defaults" do
    capture_io do
      run_command [pkg_root]
    end

    assert pkg_root.join(".gitignore").file?
    assert pkg_root.join(".rubocop.yml").file?
    assert pkg_root.join("CHANGELOG.md").file?
    assert pkg_root.join("CODE_OF_CONDUCT.md").file?
    assert pkg_root.join("CONTRIBUTING.md").file?
    assert pkg_root.join("Gemfile").file?
    assert pkg_root.join("LICENSE.md").file?
    assert pkg_root.join("newgem.gemspec").file?
    assert pkg_root.join("Rakefile").file?
    assert pkg_root.join("README.md").file?
    assert pkg_root.join(".github/dependabot.yml").file?
    assert pkg_root.join(".github/FUNDING.yml").file?
    assert pkg_root.join(".github/PULL_REQUEST_TEMPLATE.md").file?
    assert pkg_root.join(".github/workflows/ruby-tests.yml").file?
    assert pkg_root.join(".github/ISSUE_TEMPLATE/bug_report.md").file?
    assert pkg_root.join(".github/ISSUE_TEMPLATE/feature_request.md").file?
    assert pkg_root.join(".github/CODEOWNERS").file?
    assert pkg_root.join("bin/console").executable?
    assert pkg_root.join("bin/setup").executable?
    assert pkg_root.join("lib/newgem.rb").file?
    assert pkg_root.join("lib/newgem/version.rb").file?
    assert pkg_root.join("test/test_helper.rb").file?
    assert pkg_root.join("test/newgem_test.rb").file?
    assert_includes pkg_root.join("lib/newgem.rb").read, "module Newgem"

    workflow_yml = YAML.load_file(
      pkg_root.join(".github/workflows/ruby-tests.yml")
    )

    assert_equal %w[2.6.x 2.7.x],
                 workflow_yml.dig("jobs", "build", "strategy", "matrix", "ruby")
  end

  test "creates gems using custom name" do
    capture_io do
      run_command %W[#{pkg_root} --name nicegem]
    end

    assert pkg_root.join("lib/nicegem.rb").file?
    assert pkg_root.join("lib/nicegem/version.rb").file?
    assert pkg_root.join("test/test_helper.rb").file?
    assert pkg_root.join("test/nicegem_test.rb").file?
    assert_includes pkg_root.join("lib/nicegem.rb").read, "module Nicegem"
  end

  test "creates gems using custom namespace (NiceGem)" do
    capture_io do
      run_command %W[#{pkg_root} --namespace NiceGem]
    end

    assert pkg_root.join("lib/nice_gem.rb").file?
    assert pkg_root.join("lib/nice_gem/version.rb").file?
    assert pkg_root.join("test/nice_gem_test.rb").file?
    assert_includes pkg_root.join("lib/nice_gem.rb").read, "module NiceGem"
  end

  test "creates gems using custom namespace (HEYHO::LetsGo)" do
    capture_io do
      run_command %W[#{pkg_root} --namespace HEYHO::LetsGo]
    end

    assert pkg_root.join("lib/heyho-lets_go.rb").file?
    assert pkg_root.join("lib/heyho/lets_go/version.rb").file?
    assert pkg_root.join("test/heyho/lets_go_test.rb").file?
    assert_includes pkg_root.join("lib/heyho-lets_go.rb").read,
                    %[require "heyho/lets_go"]

    rubocop = YAML.load_file(pkg_root.join(".rubocop.yml"))
    assert_includes rubocop.dig("Naming/FileName", "Exclude"),
                    "lib/heyho-lets_go.rb"
  end

  test "creates gems using custom namespace and name (ramones/HEYHO::LetsGo)" do
    capture_io do
      run_command %W[
        #{pkg_root} --name ramones --namespace HEYHO::LetsGo
      ]
    end

    assert pkg_root.join("lib/ramones.rb").file?
    assert pkg_root.join("lib/heyho/lets_go.rb").file?
    assert pkg_root.join("lib/heyho/lets_go/version.rb").file?
    assert pkg_root.join("test/heyho/lets_go_test.rb").file?

    assert_includes pkg_root.join("lib/ramones.rb").read,
                    %[require "heyho/lets_go"]

    source = pkg_root.join("lib/heyho/lets_go.rb").read

    assert_includes source, %[module HEYHO]
    assert_includes source, %[module LetsGo]
  end

  test "creates gems with binary" do
    capture_io do
      run_command %W[#{pkg_root} --bin mygem]
    end

    assert pkg_root.join("exe/mygem").executable?
    assert pkg_root.join("lib/newgem/cli.rb").file?
    assert pkg_root.join("lib/newgem/generator.rb").file?
    assert_includes pkg_root.join("newgem.gemspec").read,
                    %[spec.add_dependency "thor"]
  end

  test "creates gems with custom rubies" do
    capture_io do
      run_command %W[#{pkg_root} --ruby-versions 2.6.3 2.7]
    end

    workflow_yml = YAML.load_file(
      pkg_root.join(".github/workflows/ruby-tests.yml")
    )

    assert_equal %w[2.6.3 2.7.x],
                 workflow_yml.dig("jobs", "build", "strategy", "matrix", "ruby")
    assert_includes pkg_root.join("newgem.gemspec").read,
                    %[Gem::Requirement.new(">= 2.6.3")]

    rubocop = YAML.load_file(pkg_root.join(".rubocop.yml"))
    assert_equal 2.6, rubocop.dig("AllCops", "TargetRubyVersion")
  end

  test "creates gems with activerecord config" do
    capture_io do
      run_command %W[#{pkg_root} --active-record]
    end

    gemspec = pkg_root.join("newgem.gemspec").read

    assert_includes gemspec, %[spec.add_dependency "activerecord"]
    assert_includes gemspec, %[spec.add_development_dependency "pg"]

    assert pkg_root.join("test/support/active_record.rb").file?
  end
end
