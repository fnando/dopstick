# frozen_string_literal: true

module Dopstick
  module Generator
    module Gem
      class Options < Generator::Options
        def bin?
          !@options[:bin].empty?
        end

        def active_record?
          @options[:active_record]
        end

        def namespace_names
          @namespace_names ||= @options[:namespace].split("::")
        end

        def namespace_size
          @namespace_size ||= namespace_names.size
        end

        def oldest_ruby_version
          version = ruby_versions
                    .map {|v| ::Gem::Version.new(v) }
                    .min
                    .canonical_segments

          [*version, 0].take(3).join(".")
        end
      end
    end
  end
end
