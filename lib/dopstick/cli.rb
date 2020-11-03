# frozen_string_literal: true

module Dopstick
  class CLI < Thor
    using Dopstick::Refinements
    check_unknown_options!

    def self.exit_on_failure?
      true
    end

    desc "new PATH", "Create a new gem"
    option :name,
           default: "",
           desc: "Set the gem name. Defaults to path's basename."
    option :active_record,
           default: false,
           type: :boolean,
           desc: "Set up ActiveRecord for testing."
    option :author_name,
           default: "",
           desc: "Set author name. Defaults to `git config user.name`."
    option :author_email,
           default: "",
           desc: "Set author email. Defaults to `git config user.email`."
    option :author_github,
           default: "",
           desc: "Set Github username. Defaults to `git config user.github`."
    option :author_paypal,
           default: "",
           desc: "Set Paypal account for donations. Defaults to " \
                 "`git config user.paypal`."
    option :repository,
           default: "",
           desc: "Set Github repository name. Defaults to gem name."
    option :description,
           default: "",
           desc: "Set gem description."
    option :version,
           default: "0.0.0",
           desc: "Set package initial version."
    option :bin,
           default: "",
           desc: "Set binary name. Also sets up Thor CLI and generator."
    option :namespace,
           default: "",
           desc: "Set the codebase namespace. By default, it's inferred from " \
                 "the gem name."
    option :ruby_versions,
           default: %w[2.6 2.7],
           type: :array,
           desc: "Set Ruby versions that are officially supported. Multiple " \
                 "versions must separated by space."
    def new(path)
      options = dup_options
      gem_name, namespace = expand_gem_name_and_namespace(path)

      generator = Generator.new
      generator.destination_root = File.expand_path(path)
      generator.options = options.merge(
        gem_name: gem_name,
        namespace: namespace,
        entry_path: namespace.underscore("/")
      )

      generator.invoke_all
    end

    no_commands do
      private def dup_options
        options.each_with_object({}) do |(key, value), buffer|
          buffer[key.to_sym] = value
        end
      end

      private def expand_gem_name_and_namespace(path) # rubocop:disable Metrics/AbcSize
        if options[:name].presence && options[:namespace].presence
          [options[:name], options[:namespace]]
        elsif options[:name].presence
          [options[:name], options[:name].camelize]
        elsif options[:namespace].presence
          [options[:namespace].underscore("-"), options[:namespace]]
        else
          [File.basename(path), File.basename(path).camelize]
        end
      end
    end
  end
end
