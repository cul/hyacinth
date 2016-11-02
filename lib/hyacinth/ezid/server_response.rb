module Hyacinth::Ezid
  class ServerResponse
    attr_reader :response, :parsed_body_hash

    def initialize(response)
      @response = response
      @parsed_body_hash = parse_body
    end

    def success?
      @response.body[0..6] == 'success'
    end

    def error?
      @response.body[0..5] == 'error'
    end

    def doi
      match = @response.body.match(/doi\S+/)
      match[0]
    end

    def ark
      match = @response.body.match(/ark\S+/)
      match[0]
    end

    def http_status_code
      @response.code
    end

    def http_server_message
      @response.msg
    end

    def body
      @response.body
    end

    def parse_body
      parsed_body_hash = {}
      # First, split by '\n' to get individual lines
      parsed_body = @response.body.split("\n")
      # Then split each line in 2 along ':'. NOTE: using #map!
      # parsed_body.map! {|line| line.split(':', 2)}
      parsed_body.each do |line|
        key_value_pair = line.split(':', 2)
        parsed_body_hash[key_value_pair.first] = key_value_pair.second
      end
      # clean up datacite xml
      parsed_body_hash['datacite'].gsub!('%0A', '') if parsed_body_hash.key? 'datacite'
      parsed_body_hash
    end

    def to_str
      @response.to_s
    end
  end
end
