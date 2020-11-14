# frozen_string_literal: true

require "test_helper"

class NPMTest < Minitest::Test
  def pkg_root
    @pkg_root ||= tmp_dir.join("newpkg")
  end

  def tmp_dir
    @tmp_dir ||= Pathname.new(File.expand_path("#{Dir.pwd}/tmp"))
  end

  def run_command(args)
    Dopstick::CLI.start([
      "new",
      "--type", "npm",
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

    assert pkg_root.join("src/index.ts").file?
    assert pkg_root.join("src/index.test.ts").file?
    assert pkg_root.join(".gitignore").file?
    assert pkg_root.join(".eslintrc.js").file?
    assert pkg_root.join("babel.config.json").file?
    assert pkg_root.join("tsconfig.json").file?
    assert pkg_root.join("jest.config.js").file?
    assert pkg_root.join("prettier.config.js").file?
    assert pkg_root.join("webpack.config.js").file?
    assert pkg_root.join("CHANGELOG.md").file?
    assert pkg_root.join("CODE_OF_CONDUCT.md").file?
    assert pkg_root.join("CONTRIBUTING.md").file?
    assert pkg_root.join("LICENSE.md").file?
    assert pkg_root.join("package.json").file?
    assert pkg_root.join("README.md").file?
    assert pkg_root.join(".github/dependabot.yml").file?
    assert pkg_root.join(".github/FUNDING.yml").file?
    assert pkg_root.join(".github/PULL_REQUEST_TEMPLATE.md").file?
    assert pkg_root.join(".github/workflows/js-tests.yml").file?
    assert pkg_root.join(".github/ISSUE_TEMPLATE/bug_report.md").file?
    assert pkg_root.join(".github/ISSUE_TEMPLATE/feature_request.md").file?
    assert pkg_root.join(".github/CODEOWNERS").file?

    workflow_yml = YAML.load_file(
      pkg_root.join(".github/workflows/js-tests.yml")
    )

    assert_equal %w[14 12],
                 workflow_yml.dig("jobs", "build", "strategy", "matrix", "node")
  end
end
