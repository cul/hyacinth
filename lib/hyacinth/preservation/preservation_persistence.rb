module Hyacinth
  module Preservation
    class PreservationPersistence
      attr_reader :preservation_adapters
      def initialize(config)
        raise 'Missing config option: adapters' if config[:adapters].blank?
        @preservation_adapters = config[:adapters].map { |adapter_config| Hyacinth::Adapters::PreservationAdapterManager.create(adapter_config) }
      end

      # Iterates through all @adapters and persists the given digital_object to each one.
      # @return success, errors [boolean, array]
      def persist(digital_object)
        preservation_persistence_errors = []
        digital_object.preservation_target_uris.each do |preservation_target_uri|
          adapter = @preservation_adapters.find { |preservation_adapter| adapter.handles?(preservation_target_uri) }
          if adapter
            success, errors = adapter.persist(uri, digital_object)
            if !success
              preservation_persistence_errors << "Storage adapter encountered the following errors while trying to persist #{uri}: #{errors.join("\n")}"
            end
          else
            preservation_persistence_errors << "Could not find a preservation adapter for: #{preservation_target_uri}"
          end
        end
        [errors.blank?, errors]
      end
    end
  end
end