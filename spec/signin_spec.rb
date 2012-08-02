require 'spec_helper'

feature 'User should be able to login using Google Account' do

  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:google] = OmniAuth::AuthHash.new({
    :provider => 'Google',
    :uid => 'https://www.google.com/accounts/o8/id?id=AItOawm_DNI2mQM77rx6dbKe7dedUxsj-elvrHA',
    :info => {'name' => 'Phuoc Nguyen'}
  })

  scenario 'User login with a valid Google Account' do
    visit '/login'
    click_on 'Sign in with Google'
    page.should have_content('Phuoc Nguyen')
  end

  scenario 'Sign in failed with the provider' do
    visit '/login'
    OmniAuth.config.mock_auth[:google] = :invalid_credentials
    click_on 'Sign in with Google'
    page.should have_content('Log In')
  end


end
