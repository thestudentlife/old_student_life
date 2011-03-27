require 'test_helper'

class PublishedArticleTest < ActiveSupport::TestCase
  test "published works correctly" do
    a = Article.create! :name => 'smiley 80s',
      :section => Section.create!(:name => 'news', :url => 'news', :priority => 10)
    user = User.create!(
      :email => 'test@test.com',
      :password => "password",
      :password_confirmation => "password")
    rev = Revision.create! :article => a, :body => 'body', :author => user
    title = ArticleTitle.create! :article => a, :text => '', :author => user
    
    p1 = WebPublishedArticle.create!(
      :article => a,
      :revision => rev,
      :title => title,
      :published_at => (Time.now - 5.minutes)
    )
    p2 = WebPublishedArticle.create!(
      :article => a,
      :revision => rev,
      :title => title,
      :published_at => (Time.now)
    )
    p3 = WebPublishedArticle.create!(
      :article => a,
      :revision => rev,
      :title => title,
      :published_at => (Time.now + 5.minutes)
    )
    
    published = WebPublishedArticle.published.all
    
    assert published.size == 1
    assert published.first == p2
  end
end
