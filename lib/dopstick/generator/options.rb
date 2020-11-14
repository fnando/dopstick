# frozen_string_literal: true

module Dopstick
  module Generator
    class Options
      using Refinements

      def initialize(options)
        @options = options
      end

      def [](key)
        @options[key]
      end

      def merge(other)
        @options.merge(other)
      end

      def respond_to_missing?(name, _include_all)
        options.key?(name) || super
      end

      def method_missing(name, *args)
        @options.key?(name) ? @options[name] : super
      end

      def skip_install?
        @options[:skip_install]
      end

      def bin?
        !@options[:bin].empty?
      end

      def user_name
        @user_name ||= @options[:author_name].presence ||
                       `git config user.name`.chomp.presence ||
                       "Your Name"
      end

      def user_email
        @user_email ||= @options[:author_email].presence ||
                        `git config user.email`.chomp.presence ||
                        "your@email.com"
      end

      def github_user
        @github_user ||= @options[:author_github].presence ||
                         `git config user.github`.chomp.presence ||
                         "[USER]"
      end

      def paypal_user
        @paypal_user ||= @options[:author_paypal].presence ||
                         `git config user.paypal`.chomp.presence ||
                         "[USER]"
      end

      def github_url
        "https://github.com/#{github_user}/#{package_name}"
      end
    end
  end
end
