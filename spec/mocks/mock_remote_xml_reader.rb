class MockRemoteXmlReader  
  def child_nodes_to_hash(node_name)
    {'1'=>{ title: 'job title 1' }}
  end  
end

class MockEmptyRemoteXmlReader  
  def child_nodes_to_hash(node_name)
    {}
  end  
end
