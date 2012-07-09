module RemoteInterfaceMacros

  def sw2_xml_reader_setup(filename)
    xml_file = open(SW2_FIXTURES + '/' + filename)
    Remote::Xml::Reader.stub(:open).and_return(xml_file)
  end

end
