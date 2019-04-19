require 'rails_helper'

describe Hyacinth::DigitalObject::ResourceAttributes do
  let(:resource_name) { :example }
  let(:klass) do
    Class.new do
      include Hyacinth::DigitalObject::ResourceAttributes
      resource_attribute :example
    end
  end

  let(:instance) do
    klass.new
  end

  context "module inclusion" do
    it "adds the expected methods to the class" do
      expect(klass.resource_attributes).to be_a(Set)
    end

    it "adds the expected methods to an instance" do
      expect(instance.resource_attributes).to be_a(Set)
    end
  end

  context ".resource_attribute" do
    it "adds a public getter method and private setter method" do
      expect(instance).to respond_to(resource_name)
    end
  end
end