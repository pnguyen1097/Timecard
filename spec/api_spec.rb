# encoding: UTF-8
Encoding.default_external = 'UTF-8'
require 'spec_helper.rb'
require 'randexp'

describe 'API', :type => :request do

  # Add data
  (1..3).each do |x|
    u = User.create
    Account.create(:provider => "test_provider", :uid => "test_uid#{x}", :user_id => x)
    p1 = Project.create(:project_name => /\w+/.gen.capitalize, :for => /\w+/.gen.capitalize, :comment => /\w+ \w+ \w+ \w+ \w+/.gen, :user_id => x)
    p2 = Project.create(:project_name => /\w+/.gen.capitalize, :for => /\w+/.gen.capitalize, :comment => /\w+ \w+ \w+/.gen, :user_id => x)
    Entry.create(:time_in => DateTime.parse("2012-07-18T13:30:00.000Z"), :time_out => DateTime.parse("2012-07-18T20:30:00.000Z"), :comment => /\w+ \w+/.gen, :project => p1, :user => u)
    Entry.create(:time_in => DateTime.parse("2012-07-18T13:30:00.000Z"), :time_out => DateTime.parse("2012-07-18T20:30:00.000Z"), :comment => /\w+ \w+/.gen, :project => p2, :user => u)
  end


  OmniAuth.config.mock_auth[:google] = OmniAuth::AuthHash.new({
    :provider => 'test_provider',
    :uid => 'test_uid1',
    :info => {'name' => 'Phuoc Nguyen'}
  })

  before :each do
    # log in
    visit '/auth/google'
  end

  context 'when working with project' do


    it 'POST /main/api/project should create a new project in the database' do
      page.driver.post '/main/api/project', {:project_name => 'Test Project', :for => 'Taivara', :comment => '', :user_id => 1}.to_json
      puts page.body
      proj = Project.first(:project_name => 'Test Project', :user_id => 1);
      proj.should_not be_nil;
    end

    it 'GET /main/api/project should return a json formatted list of all project' do
      visit '/main/api/project'
      page.should have_content(Project.all(:user_id => 1).to_json)
    end

    it 'GET /main/api/project/:id should return a json formatted attributes of project[:id]' do
      visit '/main/api/project/1'
      page.should have_content(Project.get(1).to_json)
    end

    it 'PUT /main/api/project/:id should update a project' do
      page.driver.put '/main/api/project/1', {:project_name => 'Updated project', :for => 'Someone else', :comment => 'Changed comment, too'}.to_json
      page.should have_content({:id => 1, :project_name => 'Updated project', :for => 'Someone else', :comment => 'Changed comment, too'}.to_json)
      proj = Project.get(1)
      proj.project_name.should == 'Updated project'
      proj.for.should == 'Someone else'
      proj.comment.should == 'Changed comment, too'
    end

    it 'DELETE /main/api/project/:id/ should delete a project' do
      page.driver.delete '/main/api/project/1'
      proj = ''
      proj = Project.get(1)
      proj.should be_nil
    end

    it "should not do anything unless the project belong to current user" do
      original = Project.get(6).project_name
      page.driver.put'/main/api/project/6', {:project_name => 'Changed'}.to_json
      proj = Project.get(6)
      proj.project_name.should == original
      page.driver.delete '/main/api/project/3'
      proj.should_not be_nil
    end

  end

  context 'when working with entries' do

    it 'POST /main/api/project/:project_id/entry should create a new project in the database' do
      page.driver.post '/main/api/project/1/entry', {:time_in => '2012-07-18T17:30:00.000Z', :time_out => '2012-07-18T20:30:00.000Z',:comment => '', :user_id => 1}.to_json
      puts page.body
      entry = Entry.first(:time_out => DateTime.parse('2012-07-18T20:30:00.000Z'), :user_id => 1);
      entry.should_not be_nil;
      page.should have_content(entry.to_json)
    end

    it 'GET /main/api/project/:project_id/entry should return a json formatted list of all entries' do
      visit '/main/api/project/1/entry'
      page.should have_content(Entry.all(:project_id => 1, :user_id => 1).to_json)
    end

    it 'GET /main/api/project/:project_id/entry/:entry_id should return a json formatted attributes of entry[:id]' do
      visit '/main/api/project/1/entry/1'
      page.should have_content(Entry.get(1).to_json)
    end

    it 'PUT /main/api/project/:project_id/entry/:entry_id should update an entry' do
      page.driver.put '/main/api/project/1/entry/1', { :time_in => '2013-01-01T14:30:00.000Z', :time_out => '2013-01-01T21:30:00.000Z', :comment => 'Changed comment, too'}.to_json
      page.should have_content({:time_in => Date.parse('2013-01-01T14:30:00.000Z').to_s, :time_out => Date.parse('2013-01-01T21:30:00.000Z').to_s, :comment => 'Changed comment, too'}.to_json)
      entry = Entry.get(1)
      entry.time_in.should == Date.parse('2013-01-01T14:30:00.000Z')
      entry.comment.should == 'Changed comment, too'
    end

    it 'DELETE /main/api/project/:project_id/entry/:entry_id should delete a project' do
      page.driver.delete '/main/api/project/1/entry/1'
      entry = ''
      entry = Project.get(1)
      entry.should be_nil
    end

    it "should not do anything unless the project belong to current user" do
      original = Entry.get(6).comment
      page.driver.put'/main/api/project/6/etnry/6', {:comment=> 'Changed'}.to_json
      entry= Entry.get(6)
      entry.comment.should == original
      page.driver.delete '/main/api/project/6/entry/6'
      entry = ''
      entry = Entry.get(6)
      entry.should_not be_nil
    end

  end
end
