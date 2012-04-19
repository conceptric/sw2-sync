require 'nokogiri'         
                                             
class RemoteXmlReader                                    
  def self.open(remote_url)
    raise ArgumentError, "A URI is required" unless remote_url
    begin
      open(remote_url)      
    rescue NoMethodError, SystemStackError
      raise ArgumentError, "This URI is invalid", caller
    end
  end

  def initialize(remote_url)
    @remote_xml = RemoteXmlReader.open(remote_url).read
  end                               
  
  def read
    @remote_xml
  end

  def child_nodes_to_hash(node_name)      
    out = []
    children_of_named_node(node_name).each do |named_node|
      attribute_hash = children_to_hash(named_node)
      out << attribute_hash unless attribute_hash.empty?
    end
    out
  end

  def children_of_named_node(node_name)
    Nokogiri::XML(read).xpath("//#{node_name}/*").to_a
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

