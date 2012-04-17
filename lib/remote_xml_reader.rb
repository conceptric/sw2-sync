module RemoteXmlReader
  def RemoteXmlReader.fetch(remote_url)
    open(remote_url).read
  end

  def RemoteXmlReader.extract_named_nodes(remote_url, node_name)
    nodes = []
    doc = Nokogiri::XML(self.fetch(remote_url))
    doc.search(node_name).each {|item| nodes << item }
    nodes
  end
end  

