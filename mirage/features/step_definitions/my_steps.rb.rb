Before do
  $mirage.clear
end

Before('@command_line') do
  stop_mockserver
end


When /^the response for '([^']*)' (with pattern '([^']*)' )?(with a delay of '(\d+)' )?is:$/ do |endpoint, *args, response|

  options = {:response => response}
  delay_regex = /with a delay of '(\d+)'/
  pattern_regex = /with pattern '([^']*)'/
  args = args.values_at(0,2).flatten
  args.each do |arg|
    case arg
      when delay_regex then options[:delay] = arg.scan(delay_regex).first[0]
      when pattern_regex then options[:pattern] = arg.scan(pattern_regex).first[0]
    end
  end
  @response_id = $mirage.set(endpoint, options).body
end

When /^getting '(.*?)'$/ do |endpoint|
  get_response(endpoint)
end

When /^getting '(.*?)' with request body:$/ do |endpoint, request_body|
  get_response(endpoint, :body => request_body)
end

def get_response(endpoint, parameters={})
  start_time = Time.now
  @response = $mirage.get(endpoint, parameters)
  @response_time = Time.now - start_time
end

When /^getting '(.*?)' with request parameters:$/ do |endpoint, table|
  parameters = {}
  table.hashes.each do |hash|
    parameters[hash['parameter'].to_sym] = hash['value']
  end
  get_response(endpoint, parameters)
end

Then /^'(.*?)' should be returned$/ do |expected_response|
  @response.body.should == expected_response
end

Then /^a (404|500) should be returned$/ do |error_code|
  @response.code.should == error_code.to_i
end

When /^I clear '(.*?)' (responses|requests) from the MockServer$/ do |endpoint, thing|

  if endpoint == 'all'
    $mirage.clear
  else
    $mirage.clear(thing,endpoint).code.should == 200
  end
end

When /^peeking at the response for response id '(.*?)'$/ do |response_id|
  @response = $mirage.peek(response_id)
end

Given /^an attempt is made to set '(.*?)' without a response$/ do |endpoint|
  @response = $mirage.set(endpoint)
end

Then /^tracking the request should return a 404$/ do
  $mirage.check(@response_id).code.should == 404
end

Then /^the response id should be '(\d+)'$/ do |response_id|
  @response_id.should == response_id
end

Then /^'(.*?)' should have been tracked$/ do |text|
  $mirage.check(@response_id).body.should == text
end

Then /^'(.*?)' should have been tracked for response id '(.*?)'$/ do |text, response_id|
   $mirage.check(response_id).body.should == text
end

Then /^tracking the request for response id '(.*?)' should return a 404$/ do |response_id|
  $mirage.check(response_id).code.should == 404
end

Then /^it should take at least '(.*)' seconds$/ do |time|
 (@response_time).should >= time.to_f
end

When /^I (rollback|snapshot) the MockServer$/ do |action|
  case action
    when 'rollback' then $mirage.rollback
    when 'snapshot' then $mirage.snapshot
  end
end

Given /^the response for '([^']*)' is file '([^']*)'$/ do |endpoint, file_path|
  $mirage.set(endpoint, :file=>File.new(file_path))
end

Then /^the response should be a file the same as '([^']*)'$/ do |file_path|
  @response.save_as("temp.download")
  FileUtils.cmp("temp.download", file_path).should == true
end
Then /^mirage should be running on '(.*)'$/ do |url|
  Mechanize.new.get(url).code.to_i.should == 200
end
Given /^I start Mirage$/ do
  start_mockserver
end