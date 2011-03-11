require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'tempfile'
require 'json'

describe "ShoutboxClient" do
  context 'configuration' do
    it 'should use the default configuration' do
      ShoutboxClient.configuration.config_file = '/i/dont/exist'
      ShoutboxClient.configuration.host.should == 'localhost'
      ShoutboxClient.configuration.port.should == 3000
    end
    
    it 'should use the values of the config file' do
      tempfile = Tempfile.new( '.shoutbox' )
      tempfile << { "host" => "example.com", "port" => 89, "proxy_host" => "prx", "proxy_port" => 8080 }.to_yaml
      tempfile.close
      ShoutboxClient.configuration.config_file = tempfile.path
      ShoutboxClient.configuration.host.should == 'example.com'
      ShoutboxClient.configuration.port.should == 89
      ShoutboxClient.configuration.proxy_host.should == "prx"
      ShoutboxClient.configuration.proxy_port.should == 8080
      ShoutboxClient.configuration.default_group.should == 'default group'
      ShoutboxClient.configuration.config_file = nil
    end
    
    it 'should use the configured default group' do
      tempfile = Tempfile.new( '.shoutbox' )
      tempfile << { "host" => "example.com", "port" => 89, "proxy_host" => "prx", "proxy_port" => 8080, "default_group" =>  "some group" }.to_yaml
      tempfile.close
      ShoutboxClient.configuration.config_file = tempfile.path
      ShoutboxClient.configuration.default_group.should == 'some group'
      ShoutboxClient.configuration.config_file = nil
    end
  end
  
  context 'http communication' do
    it 'should create a valid PUT request to the shoutbox' do
      stub_request(:put, "http://localhost:3000/status").
        with(:body    => "{\"statusId\":\"test_status\",\"group\":\"my_group\",\"status\":\"green\"}", 
             :headers => {'Accept'=>'application/json', 'User-Agent'=>'Ruby shoutbox-client'}).
        to_return(:status => 200, :body => "OK", :headers => {})

      ShoutboxClient.shout( :group => "my_group", :statusId => "test_status", :status => :green ).should == true
    end
    
    it 'should create use group default if no group given' do
      stub_request(:put, "http://localhost:3000/status").
        with(:body    => "{\"statusId\":\"test_status\",\"group\":\"default group\",\"status\":\"green\"}", 
             :headers => {'Accept'=>'application/json', 'User-Agent'=>'Ruby shoutbox-client'}).
        to_return(:status => 200, :body => "OK", :headers => {})

      ShoutboxClient.shout( :statusId => "test_status", :status => :green ).should == true
    end

    it 'should include a message when status is yellow and message is given' do
      stub_request(:put, "http://localhost:3000/status").
        with(:body    => "{\"statusId\":\"test_status\",\"group\":\"default group\",\"status\":\"yellow\",\"message\":\"This is what you should do now..\"}", 
             :headers => {'Accept'=>'application/json', 'User-Agent'=>'Ruby shoutbox-client'}).
        to_return(:status => 200, :body => "OK", :headers => {})

      ShoutboxClient.shout( :statusId => "test_status", :status => :yellow, :message => "This is what you should do now.." ).should == true
    end
    
    it 'should include a message when status is red' do
      stub_request(:put, "http://localhost:3000/status").
        with(:body    => "{\"statusId\":\"test_status\",\"group\":\"default group\",\"status\":\"red\",\"message\":\"This is what you should do now..\"}", 
             :headers => {'Accept'=>'application/json', 'User-Agent'=>'Ruby shoutbox-client'}).
        to_return(:status => 200, :body => "OK", :headers => {})

      ShoutboxClient.shout( :statusId => "test_status", :status => :red, :message => "This is what you should do now.." ).should == true
    end
    
    it 'should deny red update if message is missing' do
      lambda {
        ShoutboxClient.shout( :statusId => "test_status", :status => :red )
      }.should raise_error(ArgumentError)
    end

    it 'should deny yellow update if message is missing' do
      lambda {
        ShoutboxClient.shout( :statusId => "test_status", :status => :yellow )
      }.should raise_error(ArgumentError)
    end

    it 'should send optional status on green update' do
      stub_request(:put, "http://localhost:3000/status").
        with(:body    => "{\"statusId\":\"test_status\",\"group\":\"default group\",\"status\":\"green\",\"message\":\"everything's ok!\"}", 
             :headers => {'Accept'=>'application/json', 'User-Agent'=>'Ruby shoutbox-client'}).
        to_return(:status => 200, :body => "OK", :headers => {})
      lambda {
        ShoutboxClient.shout( :statusId => "test_status", :status => :green, :message => "everything's ok!" )
      }.should_not raise_error(ArgumentError)
    end
    
    it 'should delete a status' do
      stub_request(:delete, "http://localhost:3000/status").
        with(:body    => "{\"statusId\":\"test_status\",\"group\":\"default group\"}",
             :headers => {'Accept'=>'application/json', 'User-Agent'=>'Ruby shoutbox-client'}).
        to_return(:status => 200, :body => "OK", :headers => {})
      
      ShoutboxClient.shout( :statusId => "test_status", :status => :remove ).should == true
    end
    
  end
end
