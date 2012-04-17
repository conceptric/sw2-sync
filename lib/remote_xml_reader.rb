module RemoteXmlReader
  def RemoteXmlReader.fetch(remote_url)
    open(remote_url).read
  end
end  

