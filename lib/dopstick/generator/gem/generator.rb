# frozen_string_literal: true

module Dopstick
  module Generator
    module Gem
      Generator.registered["gem"] = self

      class Generator < Thor::Group
        using Dopstick::Refinements
        include Thor::Actions

        attr_accessor :options

        desc "Generate a new gem folder structure"

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

        def copy_ruby_templates
          template "gemspec.erb", "#{options.package_name}.gemspec"
          template "rakefile.erb", "Rakefile"
          template "rubocop.erb", ".rubocop.yml"
          template "gemfile.erb", "Gemfile"
          template "tests_workflow.erb", ".github/workflows/ruby-tests.yml"
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

        def copy_bins
          template "console.erb", "bin/console"
          template "setup.erb", "bin/setup"
          in_root { run "chmod +x bin/*" }
        end

        def create_entry_file
          if options.entry_path.include?("/")
            template "gem_entry_file.erb", "lib/#{options.package_name}.rb"
          end

          template "entry_file.erb", "lib/#{options.entry_path}.rb"
        end

        def create_version_file
          template "version.erb", "lib/#{options.entry_path}/version.rb"
        end

        def copy_test_files
          template "test_helper.erb", "test/test_helper.rb"
          template "test_file.erb", "test/#{options.entry_path}_test.rb"
        end

        def copy_binary_files
          return unless options.bin?

          template "cli.erb", "lib/#{options.entry_path}/cli.rb"
          template "generator.erb", "lib/#{options.entry_path}/generator.rb"
          template "bin.erb", "exe/#{options.bin}"
          create_file "lib/#{options.entry_path}/templates/.keep"
          in_root { run "chmod +x exe/*" }
        end

        def copy_active_record_files
          return unless options[:active_record]

          template "active_record.erb", "test/support/active_record.rb"
        end

        def bundle_install
          return if options.skip_install?

          in_root do
            run "bundle install"
          end
        end

        def initialize_repo
          in_root do
            run "git init --initial-branch=main", capture: true
            run "git add bin --force", capture: true
            run "git add .", capture: true
          end
        end

        no_commands do
          def render_tree(skip_content_spaces = false)
            content = []

            options.namespace_names.each_with_index do |name, count|
              content << (("  " * count) + "module #{name}")
            end

            spacer = skip_content_spaces ? "" : "  "

            content << ((spacer * options.namespace_size) + yield)

            (options.namespace_size - 1).downto(0) do |count|
              content << "#{'  ' * count}end"
            end

            content.join("\n")
          end

          def render_cli
            cli_class = erb("cli_class.erb")
                        .chomp
                        .gsub(/^(.)/m, "#{'  ' * options.namespace_size}\\1")

            render_tree(true) { cli_class }
          end

          def render_generator
            generator_class = erb("generator_class.erb")
                              .chomp
                              .gsub(
                                /^(.)/m,
                                "#{'  ' * options.namespace_size}\\1"
                              )

            render_tree(true) { generator_class }
          end

          def erb(file)
            ERB.new(
              File.read("#{self.class.source_root}/#{file}")
            ).result(binding)
          end

          def dependabot_package_ecosystem
            "bundler"
          end

          def ruby_versions_for_workflow
            options.ruby_versions.map do |v|
              canonical_segments = ::Gem::Version.new(v).canonical_segments
              canonical_segments << 0 if canonical_segments.size < 2

              canonical_segments.join(".").inspect
            end.join(", ")
          end
        end
      end
    end
  end
end
