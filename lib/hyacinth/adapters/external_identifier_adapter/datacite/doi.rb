# frozen_string_literal: true

# DESGIN NOTE: Currently, the only required EZID indentifiers are DOIs. ARKs are not currently used
# Therefore, only the current class is implemented. However, if ARKs or URNs are implemented
# at a later date, the common functionality can be moved to parent class, and this class and
# the sibling class (ARK and/or URN) will inherit from this new parent class
class Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::Doi
  attr_reader :identifier, :metadata
  def initialize(doi_identifier, status = Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::IDENTIFIER_STATUS[:reserved], datacite_metadata = {})
    @identifier = doi_identifier
    @datacite_metadata = datacite_metadata

    # following instance variables represent the Internal Metadata as
    # specified by the EZID API, Version 2 (http://ezid.cdlib.org/doc/apidoc.html)
    # In the API, the name is prefixed with an underscore. Underscore it not used
    # in instance variable name due to special meaning attributed in ruby to names
    # beginning with underscores
    # BEGIN
    @status = status
    # END
    # above instance variables represent the Internal Metadata as
    # specified by the EZID API, Version 2 (http://ezid.cdlib.org/doc/apidoc.html)
  end
end
