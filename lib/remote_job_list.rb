require 'nori'
require 'nokogiri'         
require 'remote_xml_reader'

class RemoteJobsList 
  include RemoteXmlReader
  
  def initialize(remote_url)
    @xml = RemoteXmlReader.fetch(remote_url)
    config_nori
  end
  
  def to_hash
    attributes = [] 
    Nokogiri::XML(@xml).search('jobs').children.each do |job|
      Nori.parse(job.to_xml).each {|key, value| attributes << value }
    end
    attributes
  end    

  private 
  def config_nori
    Nori.configure do |config|
      config.convert_tags_to { |tag| tag.to_sym }
    end        
  end      
end
