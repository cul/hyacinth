# frozen_string_literal: true

module Hyacinth
  module Utils
    module Clean
      # Recursively trims whitespace from strings and removes any non-boolean blank
      # values (aka non-boolean values that return true for .blank?).
      def self.trim_whitespace_and_remove_blank_fields!(data)
        trim_whitespace!(data)
        remove_blank_fields!(data)
      end

      # Recursively removes blank fields from the Arrays and Hashes. Blank values are any values that
      # return true to `#blank?` with the exception of booleans. All booleans are not considered to be blank.
      # This method is destructive and updates directly the object that is given.
      #
      # @param data [Hash|Array] data
      def self.remove_blank_fields!(data)
        return if data.is_a?(Hash) && data.frozen? # We can't modify a frozen hash (e.g. uri-based controlled vocabulary field), so we won't attempt to.

        # Step 1: Recursively handle values on lower levels
        # Step 2: Delete blank values on this object level
        if data.is_a?(Hash)
          data.each { |_, v| remove_blank_fields!(v) }
          data.delete_if { |_key, value| blank_field?(value) }
        elsif data.is_a?(Array)
          data.each { |v| remove_blank_fields!(v) }
          data.delete_if { |v| blank_field?(v) }
        end
      end

      # Recursively trims whitespace from nested String values. This method is destructive and updates
      # directly the object that is given.
      #
      # @param data [Hash|Array] data
      def self.trim_whitespace!(data)
        if data.is_a?(Array)
          data.each_with_index do |value, i|
            if value.is_a?(String)
              data[i] = value.strip
            else
              trim_whitespace!(value)
            end
          end
        elsif data.is_a?(Hash)
          data.each do |key, value|
            if value.is_a?(String)
              data[key] = value.strip
            else
              trim_whitespace!(value)
            end
          end
        end
      end

      # Wrapper around '.blank?' method because any boolean value should not be considered blank.
      def self.blank_field?(value)
        value.is_a?(FalseClass) ? false : value.blank?
      end
    end
  end
end
