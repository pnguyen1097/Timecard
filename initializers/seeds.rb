
# Dummy test user

if Identity.first(username: "mario").nil?
  user = User.create
  puts user.inspect
  identity = Identity.create(
    username: "mario",
    name: "mario",
    password: "superadmin",
    password_confirmation: "superadmin"
  )
  puts identity.errors.inspect
  account = Account.create(
    provider: "identity",
    uid: identity.id,
    user_id: user.id
  )
  puts account.errors.inspect
end
