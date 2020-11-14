# frozen_string_literal: true

module Dopstick
  module Generator
    module NPM
      Generator.registered["npm"] = self

      class Generator < Thor::Group
        using Dopstick::Refinements
        include Thor::Actions

        attr_accessor :options

        desc "Generate a new npm folder structure"

        def self.exit_on_failure?
          true
        end

        def self.source_paths
          [
            source_root,
            File.join(__dir__, "../base/templates")
          ]
        end

        def self.source_root
          File.join(__dir__, "templates")
        end

        def copy_npm_templates
          template "package.erb", "package.json"
          template "tests_workflow.erb", ".github/workflows/js-tests.yml"
          template "tsconfig.erb", "tsconfig.json"
          template "prettier.erb", "prettier.config.js"
          template "jest.erb", "jest.config.js"
          template "eslint.erb", ".eslintrc.js"
          template "webpack.erb", "webpack.config.js"
          template "babel.erb", "babel.config.json"
          template "index.erb", "src/index.ts"
          template "index_test.erb", "src/index.test.ts"
        end

        def copy_generic_templates
          template "license.erb", "LICENSE.md"
          template "coc.erb", "CODE_OF_CONDUCT.md"
          template "readme.erb", "README.md"
          template "changelog.erb", "CHANGELOG.md"
          template "contributing.erb", "CONTRIBUTING.md"
          template "gitignore.erb", ".gitignore"
        end

        def copy_github_templates
          template "funding.erb", ".github/FUNDING.yml"
          template "bug_report.erb", ".github/ISSUE_TEMPLATE/bug_report.md"
          template "feature_request.erb",
                   ".github/ISSUE_TEMPLATE/feature_request.md"
          template "pull_request.erb", ".github/PULL_REQUEST_TEMPLATE.md"
          template "dependabot.erb", ".github/dependabot.yml"
          template "codeowners.erb", ".github/CODEOWNERS"
        end

        def install_dependencies
          return if options.skip_install?

          in_root do
            %w[
              @babel/core
              @babel/preset-env
              @fnando/codestyle
              @fnando/eslint-config-codestyle
              @typescript-eslint/eslint-plugin
              @typescript-eslint/parser
              babel-loader
              babel-plugin-module-resolver
              eslint
              jest
              jest-filename-transform
              prettier
              ts-jest
              ts-loader
              typescript
              webpack
              webpack-cli
            ].each do |dep|
              run "yarn add --dev #{dep}", capture: true
            end
          end
        end

        def initialize_repo
          in_root do
            run "git init --initial-branch=main", capture: true
            run "git add .", capture: true
          end
        end
      end
    end
  end
end
