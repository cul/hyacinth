module Hyacinth
  module Adapters
    module LockAdapter
      class Abstract
        def initialize(adapter_config = {})
        end

        # Establishes a lock on the key and yields to a block that runs within the established lock.
        # TODO: Add second optional param for number of seconds to wait before giving up.
        def with_lock(key)
          raise NotImplementedError
        end
      end
    end
  end
end
