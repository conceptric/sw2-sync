require 'nori'
require 'nokogiri'         
require 'remote_xml_reader'

class RemoteJobsList 
  include RemoteXmlReader
  
  def initialize(remote_url)
    @xml = RemoteXmlReader.open(remote_url)
  end
  
  private 
  def config_nori
    Nori.configure do |config|
      config.convert_tags_to { |tag| tag.to_sym }
    end        
  end      
end
