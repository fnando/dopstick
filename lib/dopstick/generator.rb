# frozen_string_literal: true

module Dopstick
  class Generator < Thor::Group # rubocop:disable Metrics/ClassLength
    using Dopstick::Refinements

    include Thor::Actions

    def self.exit_on_failure?
      true
    end

    attr_accessor :options

    desc "Generate a new gem folder structure"

    def self.source_root
      File.join(__dir__, "templates")
    end

    def copy_generic_templates
      template "gemspec.erb", "#{gem_name}.gemspec"
      template "license.erb", "LICENSE.md"
      template "coc.erb", "CODE_OF_CONDUCT.md"
      template "readme.erb", "README.md"
      template "changelog.erb", "CHANGELOG.md"
      template "contributing.erb", "CONTRIBUTING.md"
      template "rakefile.erb", "Rakefile"
      template "rubocop.erb", ".rubocop.yml"
      template "gitignore.erb", ".gitignore"
      template "gemfile.erb", "Gemfile"
    end

    def copy_github_templates
      template "funding.erb", ".github/FUNDING.yml"
      template "tests_workflow.erb", ".github/workflows/tests.yml"
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
      if entry_path.include?("/")
        template "gem_entry_file.erb", "lib/#{gem_name}.rb"
      end

      template "entry_file.erb", "lib/#{entry_path}.rb"
    end

    def create_version_file
      template "version.erb", "lib/#{entry_path}/version.rb"
    end

    def copy_test_files
      template "test_helper.erb", "test/test_helper.rb"
      template "test_file.erb", "test/#{entry_path}_test.rb"
    end

    def copy_binary_files
      return unless options[:bin].presence

      template "cli.erb", "lib/#{entry_path}/cli.rb"
      template "generator.erb", "lib/#{entry_path}/generator.rb"
      template "bin.erb", "exe/#{options[:bin]}"
      create_file "lib/#{entry_path}/templates/.keep"
      in_root { run "chmod +x exe/*" }
    end

    def copy_active_record_files
      return unless options[:active_record]

      template "active_record.erb", "test/support/active_record.rb"
    end

    def initialize_repo
      in_root do
        run "git init --initial-branch=main", capture: true
        run "git add .", capture: true
        run "git add bin --force", capture: true
      end
    end

    no_commands do # rubocop:disable Metrics/BlockLength
      def gem_name
        options[:gem_name]
      end

      def entry_path
        options[:entry_path]
      end

      def user_name
        @user_name ||= options[:author_name].presence ||
                       `git config --global user.name`.chomp
      end

      def user_email
        @user_email ||= options[:author_email].presence ||
                        `git config --global user.email`.chomp
      end

      def github_user
        @github_user ||= options[:author_github].presence || begin
          user = `git config --global user.github`.chomp
          user.empty? ? "[USER]" : user
        end
      end

      def paypal_user
        @paypal_user ||= options[:author_paypal].presence || begin
          user = `git config --global user.paypal`.chomp
          user.empty? ? "[USER]" : user
        end
      end

      def github_url
        "https://github.com/#{github_user}/#{gem_name}"
      end

      def ruby_versions
        options[:ruby_versions]
      end

      def const_names
        @const_names ||= options[:namespace].split("::")
      end

      def const_names_size
        @const_names_size ||= const_names.size
      end

      def render_tree(skip_content_spaces = false, &block) # rubocop:disable Style/OptionalBooleanParameter
        content = []

        const_names.each_with_index do |name, count|
          content << ("  " * count) + "module #{name}"
        end

        spacer = skip_content_spaces ? "" : "  "

        content << (spacer * const_names_size) + block.call

        (const_names_size - 1).downto(0) do |count|
          content << "#{'  ' * count}end"
        end

        content.join("\n")
      end

      def erb(file)
        ERB.new(File.read("#{__dir__}/templates/#{file}")).result binding
      end

      def render_cli
        cli_class = erb("cli_class.erb")
                    .chomp
                    .gsub(/^(.)/m, "#{'  ' * const_names_size}\\1")

        render_tree(true) { cli_class }
      end

      def render_generator
        generator_class = erb("generator_class.erb")
                          .chomp
                          .gsub(/^(.)/m, "#{'  ' * const_names_size}\\1")

        render_tree(true) { generator_class }
      end

      def oldest_ruby_version
        version = options[:ruby_versions]
                  .map {|v| Gem::Version.new(v) }
                  .min
                  .canonical_segments

        [*version, 0].take(3).join(".")
      end
    end
  end
end
