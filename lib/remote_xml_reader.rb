require 'nokogiri'         

module RemoteXmlReader
  def RemoteXmlReader.open(remote_url)
    open(remote_url).read
  end

  def RemoteXmlReader.extract_named_nodes(remote_url, node_name)
    nodes = []
    doc = Nokogiri::XML(self.open(remote_url))
    doc.search(node_name).each {|item| nodes << item }
    nodes
  end
end  

