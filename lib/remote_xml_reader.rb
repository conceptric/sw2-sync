require 'nokogiri'         
                                             
class RemoteXmlReader                                    
  def self.open(remote_url)
    open(remote_url)
  end

  def self.extract_named_nodes(remote_url, node_name)
    nodes = []
    doc = Nokogiri::XML(open(remote_url).read)
    doc.search(node_name).each {|item| nodes << item }
    nodes
  end

  def initialize(remote_url)
    @remote_xml = RemoteXmlReader.open(remote_url).read
  end                               
  
  def read
    @remote_xml
  end
  
end  

