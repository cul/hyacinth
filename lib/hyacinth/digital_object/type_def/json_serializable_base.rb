# TODO: Delete if not used
module Hyacinth
  module DigitalObject
    module TypeDef
      class JsonSerializableBase < Hyacinth::DigitalObject::TypeDef::Base
        def initialize
          super
          raise NotImplementedError,
            "Cannot instantiate #{self.class}. Instantiate a subclass instead." if self.class == JsonSerializableBase
        end

        def to_json_var(value)
          value # no conversion necessary for JsonSerializableBase objects.  JSON#generate will handle them properly.
        end

        def from_json_var(value)
          value # no conversion necessary for JsonSerializableBase objects.  JSON#parse will generate correct form.
        end
      end
    end
  end
end
