module Hyacinth
  module Exceptions
    class HyacinthError < StandardError; end

    class NotDestroyed < HyacinthError; end
    class NotFound < HyacinthError; end
    class NotSaved < HyacinthError; end
    class UnableToObtainLockError < HyacinthError; end

    class Deserialization < HyacinthError; end

    class Rollback < HyacinthError; end
    class UnexpectedErrors < HyacinthError; end
    class MissingErrors < HyacinthError; end

    class AlreadySet < HyacinthError; end

    class MissingRequiredOpt < HyacinthError; end

    class UnsupportedType < HyacinthError; end

    class AdapterNotFoundError < StandardError; end
    class UnhandledLocationError < StandardError; end

    class DuplicateTypeError < StandardError; end
  end
end
