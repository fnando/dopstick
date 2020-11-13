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

      def package_name
        @options[:package_name]
      end

      def package_description
        @options[:package_description]
      end

      def user_name
        @user_name ||= @options[:author_name].presence ||
                       `git config --global user.name`.chomp
      end

      def user_email
        @user_email ||= @options[:author_email].presence ||
                        `git config --global user.email`.chomp
      end

      def github_user
        @github_user ||= @options[:author_github].presence || begin
          user = `git config --global user.github`.chomp
          user.empty? ? "[USER]" : user
        end
      end

      def paypal_user
        @paypal_user ||= @options[:author_paypal].presence || begin
          user = `git config --global user.paypal`.chomp
          user.empty? ? "[USER]" : user
        end
      end

      def github_url
        "https://github.com/#{github_user}/#{package_name}"
      end
    end
  end
end
