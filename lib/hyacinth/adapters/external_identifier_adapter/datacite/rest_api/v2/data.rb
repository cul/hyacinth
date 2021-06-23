# frozen_string_literal: true
require 'json'
class Hyacinth::Adapters::ExternalIdentifierAdapter::Datacite::RestApi::V2::Data
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

  attr_accessor :data_hash

  def initialize
    @data_hash = {}
  end

  def reset
    @data_hash = {}
  end

  def generate_json_payload
    JSON.generate(data: @data_hash)
  end

  def build_mint(doi_prefix, doi_state, metadata = nil)
    case doi_state
    when :draft
      if metadata
        # return { doi: nil, error: 'missing metadata' } unless rest_api.required_attributes_present?(metadata)
        raise "Metadata incomplete for #{doi_state} DOI" unless required_attributes_present?(metadata)
        required_metadata(metadata)
      else
        prefix_only(doi_prefix) # only required metadata if minting a draft DOI is the prefix
      end
    when :findable, :registered
      # return { doi: nil, error: 'missing metadata' } unless rest_api.required_attributes_present?(metadata)
      raise "Metadata incomplete for #{doi_state} DOI" unless required_attributes_present?(metadata)
      required_metadata(metadata)
    end
    # add event, which triggers DOI state change on DataCite server
    add_event(doi_state)
  end

  def build_update(metadata, doi_state = nil)
    case doi_state
    when :draft
      if metadata
        # return { doi: nil, error: 'missing metadata' } unless rest_api.required_attributes_present?(metadata)
        raise "Metadata incomplete for #{doi_state} DOI" unless required_attributes_present?(metadata)
        required_metadata(metadata)
      else
        prefix_only(DATACITE[:prefix]) # only required metadata if minting a draft DOI is the prefix
      end
    when :findable, :registered
      # return { doi: nil, error: 'missing metadata' } unless rest_api.required_attributes_present?(metadata)
      raise "Metadata incomplete for #{doi_state} DOI" unless required_attributes_present?(metadata)
      required_metadata(metadata)
    end
    # add event, which triggers DOI state change on DataCite server
    add_event(doi_state)
  end

  # fcd1: possibly remove the default arg value of nil since should  only be using
  # this to set required metadata
  # see if can rename this
  def required_metadata(info_hash)
    # check all required attributes are present
    raise "Incomplete Metadata!" unless required_attributes_present?(info_hash)
    @data_hash[:type] = 'dois'
    @data_hash[:attributes] = required_attributes(info_hash)
    # JSON.generate(data: data)
  end

  # Following payload can be used when minting a draft DOI with no metadata
  # see if can rename this
  def prefix_only(doi_prefix)
    @data_hash[:type] = 'dois'
    @data_hash[:attributes] = { prefix: doi_prefix }
    # JSON.generate(data: data)
  end

  # for now, don't differentiate the event based on the current DOI state
  def add_event(doi_desired_state, _doi_current_state = nil)
    @data_hash[:attributes][:event] = DOI_MINT_EVENT[doi_desired_state] unless doi_desired_state.eql? :draft
  end

  # SPEC DONE
  def required_attributes_present?(info_hash)
    info_hash.present? && MINIMUM_REQUIRED_ATTRIBUTES_FOR_FINDABLE_DOI.all? { |key| info_hash[key].present? }
    # raise info_hash.to_s
  end

  # change this, to return the fields that are missing data
  def required_attributes_missing(info_hash)
    # info_hash.present? && MINIMUM_REQUIRED_ATTRIBUTES_FOR_FINDABLE_DOI.any? { |key| info_hash[key].blank? }
    MINIMUM_REQUIRED_ATTRIBUTES_FOR_FINDABLE_DOI.each do |key|
      raise "Following metadata missing: #{key}" if info_hash[key].blank?
    end
    true
  end

  def required_attributes(info_hash = nil)
    attributes = {}
    attributes[:titles] = [{ title: info_hash[:title] }]
    unless info_hash[:creators].nil?
      attributes[:creators] = []
      info_hash[:creators].each { |creator_name| attributes[:creators].append(name: creator_name) }
    end
    attributes[:url] = info_hash[:doi_url]
    attributes[:publisher] = info_hash[:publisher]
    attributes[:publicationYear] = info_hash[:publication_year]
    attributes[:types] = { resourceTypeGeneral: info_hash[:resource_type] }
    # attributes[:event] = info_hash[:event]
    attributes[:schemaVersion] = 'http://datacite.org/schema/kernel-4'
    attributes[:prefix] = info_hash[:doi_prefix]
    attributes
  end
end
