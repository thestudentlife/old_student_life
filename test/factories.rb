Factory.define :user do |u|
  u.email "test@test.com"
  u.password "test"
  u.password_confirmation "test"
end

Factory.define :author do |a|
  a.name "John Doe"
end