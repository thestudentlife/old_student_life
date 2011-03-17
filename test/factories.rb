Factory.define :user do |u|
  u.email "test@test.com"
  u.password "test"
  u.password_confirmation "test"
end

Factory.define :author do |a|
  a.name "John Doe"
end

Factory.define :section do |s|
  s.name "section"
  s.url "section"
  s.priority 10
end

Factory.define :article do |a|
  a.association :section
end