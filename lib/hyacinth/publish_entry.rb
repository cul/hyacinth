module Hyacinth
  module PublishEntry
    attr_accessor :published_at, :published_by

    def initialize(attributes = {})
      attributes.each do |attribute_name, attribute_value|
        self.send("#{attribute_name}=", attribute_value)
      end
    end
  end
end
