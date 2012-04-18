require 'nokogiri'         
                                             
class RemoteXmlReader                                    
  def self.open(remote_url)
    open(remote_url)
  end

  def initialize(remote_url)
    @remote_xml = RemoteXmlReader.open(remote_url).read
  end                               
  
  def read
    @remote_xml
  end

  def extract_named_nodes(node_name)
    Nokogiri::XML(read).search(node_name).to_a
  end                       
  
  def named_nodes_to_hash(node_name)      
    out = []
    extract_named_nodes(node_name).each do |named_node|
      out << children_to_hash(named_node)
    end
    out
  end

  private  
  def children_to_hash(node)
    attributes = {}
    node.element_children.each do |element|
      if element.element_children.empty? then
        attributes[element.node_name.to_sym] = element.text
      end
    end
    attributes    
  end

end  

