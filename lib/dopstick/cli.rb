# frozen_string_literal: true

module Dopstick
  class CLI < Thor
    using Dopstick::Refinements
    check_unknown_options!

    def self.exit_on_failure?
      true
    end

    desc "new PATH", "Create a new package"
    option :type,
           default: "",
           desc: "Set the package type you want to create. Must be one of " \
                 "#{Generator.registered.keys.inspect}."
    option :name,
           default: "",
           desc: "Set the package name. Defaults to path's basename."
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
    option :description,
           default: "TODO: add a description",
           desc: "Set package description."
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
           default: %w[2.7 3.0],
           type: :array,
           desc: "Set Ruby versions that are officially supported. Multiple " \
                 "versions must separated by space."
    option :node_versions,
           default: %w[16.x 17.x],
           type: :array,
           desc: "Set Node versions that are officially supported. Multiple " \
                 "versions must separated by space."
    option :skip_install,
           default: false,
           type: :boolean,
           desc: "Skip `bundle install` (gem) and `yarn install` (npm)"
    option :help,
           aliases: "-h",
           type: :boolean,
           hide: true
    def new(path = nil)
      interrupt_with_help(:new) if options[:help] || path.to_s.strip.empty?

      unless Generator.registered.include?(options[:type])
        interrupt_with_error(
          "--type must be one of #{Generator.registered.keys.inspect}"
        )
      end

      package_name, namespace = expand_gem_name_and_namespace(path)

      generator_module = Generator.registered[options[:type]]
      generator_class = generator_module.const_get(:Generator)
      options_class = generator_module.const_get(:Options)
      generator = generator_class.new
      generator.destination_root = File.expand_path(path)
      generator.options = options_class.new(
        dup_options.merge(
          package_name: package_name,
          namespace: namespace,
          entry_path: namespace.underscore("/")
        )
      )

      generator.invoke_all
    end

    no_commands do
      private def interrupt_with_help(command)
        help(command)
        exit
      end

      private def interrupt_with_error(message)
        shell.say "ERROR: #{message}", :red
        exit 1
      end

      private def dup_options
        options.each_with_object({}) do |(key, value), buffer|
          buffer[key.to_sym] = value
        end
      end

      private def expand_gem_name_and_namespace(path)
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
