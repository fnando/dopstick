# frozen_string_literal: true

module Dopstick
  module Generator
    module NPM
      class Options < Generator::Options
        using Refinements

        def user_name
          `npm get init.author.name`.chomp.presence ||
            super
        end

        def user_email
          `npm get init.author.email`.chomp.presence ||
            super
        end

        def user_url
          `npm get init.author.url`.chomp.presence ||
            "https://github.com/#{github_user}"
        end
      end
    end
  end
end
