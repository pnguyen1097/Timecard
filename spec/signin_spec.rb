require 'spec_helper'

describe 'Sign in feature', :type => :request do

  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:google] = OmniAuth::AuthHash.new({
    :provider => 'google',
    :uid => 'https://www.google.com/accounts/o8/id?id=AItOawm_DNI2mQM77rx6dbKe7dedUxsj-elvrHA',
    :info => {'name' => 'Phuoc Nguyen'}
  })

  context 'when user is valid' do
    it 'should sign user in if provided with a valid Google account' do
      visit '/login'
      click_on 'Sign in with Google'
      page.should have_content('Phuoc Nguyen')
    end
  end

  context 'when user is invalid' do
    it 'should redirect to the login page if sign in failed' do
      visit '/login'
      OmniAuth.config.mock_auth[:google] = :invalid_credentials
      click_on 'Sign in with Google'
      current_path.should == '/login'
    end

    it 'should redirect to the login page if not logged-in when viewing protected page.' do
      visit '/main'
      current_path.should == '/login'
    end
  end


end
