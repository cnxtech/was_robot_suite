require 'spec_helper'
require 'was_seed_preassembly/content_metadata_generator_service'
require 'equivalent-xml'

describe Dor::WASSeed::ContentMetadataGenerator do
  before(:all) do
    @staging_path = Pathname(File.dirname(__FILE__)).join('../fixtures/')
    @expected_thumbnal_xml_element = '<image><md5>cecab42610cefd7f8ba80c8505a0f95f</md5><sha1>c78e5e8e8ca02c6fffa9169b0e9e4df908675fdc</sha1><size>228709</size><width>1000</width><height>1215</height></image>'
    @expected_full_xml_element  = Nokogiri::XML("<item><druid>druid:aa111aa1111</druid>#{@expected_thumbnal_xml_element}</item>")
    @expected_empty_xml_element = Nokogiri::XML('<item><druid>druid:aa111aa1111</druid></item>')
    @contnet_metadata_full = '<contentMetadata type="webarchive-seed" id="druid:aa111aa1111">
  <resource type="image" sequence="1">
    <file preserve="no" publish="yes" shelve="yes" mimetype="image/jp2" id="thumbnail.jp2" size="228709">
      <checksum type="md5">cecab42610cefd7f8ba80c8505a0f95f</checksum>
      <checksum type="sha1">c78e5e8e8ca02c6fffa9169b0e9e4df908675fdc</checksum>
      <imageData width="1000" height="1215"/>
    </file>
  </resource>
</contentMetadata>'
  end

  describe '.generate_metadata_output' do
    it 'should generate contentMetadata file for a valid druid and valid thumbnail'
  end

  describe '.generate_xml_doc' do
    it 'should return a complete xml element for valid druid and an image xml element' do
      actual_xml_element = cm_generator_instance_with_druid.generate_xml_doc @expected_thumbnal_xml_element
      expect(actual_xml_element.to_xml).to eq(@expected_full_xml_element.to_xml)
      # expect(actual_xml_element).to be_equivalent_to(@expected_full_xml_element)
    end

    it 'should return a basic xml element for a valid druid and empty xml element' do
      actual_xml_element =  cm_generator_instance_with_druid.generate_xml_doc ''
      expect(actual_xml_element.to_xml).to eq(@expected_empty_xml_element.to_xml)
    end

    it 'should return a basic xml element for a valid druid and empty xml element' do
      actual_xml_element =  cm_generator_instance_with_druid.generate_xml_doc
      expect(actual_xml_element.to_xml).to eq(@expected_empty_xml_element.to_xml)
    end
  end

  describe '.create_thumbnail_xml_element' do
    it 'should return valid xml element for a regular image', :image_prerequisite do
      thumbnail_file_location = "#{@staging_path}/thumbnail_files/thumbnail.jp2"
      actual_xml_element = cm_generator_instance.create_thumbnail_xml_element thumbnail_file_location
      expect(actual_xml_element).to eq(@expected_thumbnal_xml_element)
      # expected_xml_objet = Nokogiri::XML(@expected_thumbnal_xml_element)
      # actual_xml_object  = Nokogiri::XML(actual_xml_element)
      # expect(actual_xml_object).to be_equivalent_to(expected_xml_objet)
    end

    it 'should return empty string for non-existing images' do
      thumbnail_file_location = "#{@staging_path}/thumbnail_files/nonthing.jpeg"
      actual_xml_element = cm_generator_instance.create_thumbnail_xml_element thumbnail_file_location
      expect(actual_xml_element).to eq('')
    end

    it 'should return empty string for null location string' do
      actual_xml_element = cm_generator_instance.create_thumbnail_xml_element nil
      expect(actual_xml_element).to eq('')
    end

    it 'should raise an excetion for reading an empty image' do
      # TODO: ? This test case should be fixed with adding an empty image
      thumbnail_file_location = "#{@staging_path}/thumbnail_files/thumbnail_empty.jpeg"
      expect{ create_thumbnail_xml_element thumbnail_file_location }.to raise_error StandardError
    end

    it 'should raise an error for reading an invalid image' do
      thumbnail_file_location = "#{@staging_path}/thumbnail_files/thumbnail_text.jpeg"
      expect{ create_thumbnail_xml_element thumbnail_file_location }.to raise_error StandardError
    end
  end

  describe '.transform_xml_using_xslt' do
    it 'transforms the xml to content metadata data format using XSLT' do
      xslt_template = File.read(Pathname(File.dirname(__FILE__)).join('../../../template/wasSeedPreassembly/contentMetadata.xslt'))
      actual_contnet_metadata = cm_generator_instance.transform_xml_using_xslt @expected_full_xml_element, xslt_template
      expect(Nokogiri::XML(actual_contnet_metadata).to_xml).to eq(Nokogiri::XML(@contnet_metadata_full).to_xml)
    end
  end

  def cm_generator_instance
    Dor::WASSeed::ContentMetadataGenerator.new('', '')
  end

  def cm_generator_instance_with_druid(druid = 'druid:aa111aa1111')
    Dor::WASSeed::ContentMetadataGenerator.new('', druid)
  end
end
