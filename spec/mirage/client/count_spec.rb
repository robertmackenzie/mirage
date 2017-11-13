require 'spec_helper'

describe Request do
  let(:id) { "url_for_request_entity" }
  let(:request_url) { "requested_url" }
  let(:trigger_url) { "trigger url" }

  let(:body) { "body" }
  let(:parameters) { {"name" => "joe"} }
  let(:headers) { {"header" => "value"} }

  let(:request_json) do
    {body: body,
     headers: headers,
     parameters: parameters,
     request_url: trigger_url,
     id: id}
  end

  it 'should load request data' do
    Request.should_receive(:backedup_get).with(request_url, format: :json).and_return(request_json)

    request = Request.get(request_url)
    request.headers.should == headers
    request.body.should == body
    request.request_url.should == trigger_url
    request.parameters.should == parameters
    request.id.should == id
  end
end
