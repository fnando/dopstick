# frozen_string_literal: true

module Dopstick
  module Refinements
    refine String do
      def presence
        empty? ? nil : self
      end

      def camelize
        split("-")
          .map {|word| word.split("_").map(&:capitalize).join }
          .join("::")
      end

      def underscore(separator = "/")
        split("::")
          .map {|word| word.gsub(/([A-Z]+)/m, "_\\1")[1..-1] }
          .join(separator)
          .downcase
      end
    end
  end
end
