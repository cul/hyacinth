# frozen_string_literal: true
require 'json'
class Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::RestApi::V2::Api
  MINIMUM_REQUIRED_ATTRIBUTES_FOR_FINDABLE_DOI = [:title,
                                                  :creators,
                                                  :doi_url,
                                                  :publisher,
                                                  :publication_year,
                                                  :resource_type,
                                                  :doi_prefix].freeze
  # Events used when minting a DOI, depends on desired state of minted DOI
  # see https://support.datacite.org/docs/how-do-i-make-a-findable-doi-with-the-rest-api
  DOI_STATES = [:draft, :findable, :registered].freeze
  DOI_MINT_EVENT = { draft: '',
                     findable: 'publish',
                     registered: 'hide' }.freeze

  attr_accessor :most_recent_request_body

  def initialize(datacite_rest_api, basic_auth_user, basic_auth_password)
    @datacite_rest_api = datacite_rest_api
    @basic_auth_user = basic_auth_user
    @basic_auth_password = basic_auth_password
    @most_recent_request_body = nil
  end

  # see https://support.datacite.org/reference/dois-2#post_dois
  # 'Add a new doi.'
  # In other words, used to mint DOIs
  def post_dois(data, data_raw_json = nil)
    Rails.logger.error 'post_dois called, START'
    uri = URI("#{@datacite_rest_api}/dois")
    request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/vnd.api+json')
    request.basic_auth(@basic_auth_user, @basic_auth_password)
    request.body = @most_recent_request_body = data_raw_json || data.generate_json_payload
    Rails.logger.error "request.body: #{request.body}"
    Rails.logger.error "uri.host: #{uri.host}"
    Rails.logger.error "uri.port: #{uri.port}"
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      # Rails.logger.error request.inspect
      http.request(request)
    end
    # response.body
  end

  # see https://support.datacite.org/reference/dois-2#put_dois-id
  # 'Update a doi.'
  def put_dois(doi, data, data_raw_json = nil)
    uri = URI("#{@datacite_rest_api}/dois/#{doi}")
    request = Net::HTTP::Put.new(uri.request_uri, 'Content-Type' => 'application/vnd.api+json')
    request.basic_auth(@basic_auth_user, @basic_auth_password)
    request.body = @most_recent_request_body = data_raw_json || data.generate_json_payload
    # Rails.logger.error "request.body: #{request.body}"
    # Rails.logger.error "uri.host: #{uri.host}"
    # Rails.logger.error "uri.port: #{uri.port}"
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      # Rails.logger.error request.inspect
      http.request(request)
    end
    response.body
  end

  def doi(created_http_response_body)
    JSON.parse(created_http_response_body)['data']['id']
  end
end
