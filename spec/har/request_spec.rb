require File.expand_path("../../spec_helper", __FILE__)

module HAR
  describe Request do
    let(:request) { Request.new json(fixture_path("request.json")) }
    
    it "has a domain" do
      request.domain.should eq("www.google.cz")
    end

    it 'handles parses underscore domains' do
      request = Request.new(json(fixture_path("underscore_request.json")))
      request.domain.should eq("my_weird_underscore.example.com")
    end

  end # Request
end # HAR
