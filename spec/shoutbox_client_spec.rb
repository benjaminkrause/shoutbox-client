require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'tempfile'
require 'JSON'

describe "ShoutboxClient" do
  context 'configuration' do
    it 'should use the default configuration' do
      ShoutboxClient.configuration.config_file = '/i/dont/exist'
      ShoutboxClient.configuration.host.should == 'localhost'
      ShoutboxClient.configuration.port.should == 3000
    end
    
    it 'should use the values of the config file' do
      tempfile = Tempfile.new( '.shoutbox' )
      tempfile << { "host" => "example.com", "port" => 89 }.to_yaml
      tempfile.close
      ShoutboxClient.configuration.config_file = tempfile.path
      ShoutboxClient.configuration.host.should == 'example.com'
      ShoutboxClient.configuration.port.should == 89
      ShoutboxClient.configuration.config_file = nil
    end
  end
  
  context 'http communication' do
    it 'should create a valid PUT request to the shoutbox' do
      stub_request(:put, "http://localhost:3000/status").
        with(:body    => "{\"group\":\"default\",\"name\":\"test_status\",\"status\":\"green\"}", 
             :headers => {'Accept'=>'application/json', 'User-Agent'=>'Ruby shoutbox-client'}).
        to_return(:status => 200, :body => "OK", :headers => {})

      ShoutboxClient.shout( :group => "default", :name => "test_status", :status => :green ).should == true
    end
  end
end