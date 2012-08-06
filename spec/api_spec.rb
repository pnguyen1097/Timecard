# encoding: UTF-8
Encoding.default_external = 'UTF-8'
require 'spec_helper.rb'
require 'randexp'

describe 'API', :type => :request do

  # Add data
  (1..3).each do |x|
    User.create
    Account.create(:provider => "test_provider", :uid => "test_uid#{x}", :user_id => x)
    Project.create(:project_name => /\w+/.gen.capitalize, :for => /\w+/.gen.capitalize, :comment => /\w+ \w+ \w+ \w+ \w+/.gen, :user_id => x)
    Project.create(:project_name => /\w+/.gen.capitalize, :for => /\w+/.gen.capitalize, :comment => /\w+ \w+ \w+/.gen, :user_id => x)
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
      original = Project.get(3).project_name
      page.driver.put'/main/api/project/3', :project_name => 'Stranger updated this'
      proj = Project.get(3)
      proj.project_name.should == original
      page.driver.delete '/main/api/project/3'
      proj.should_not be_nil
    end

  end

end
