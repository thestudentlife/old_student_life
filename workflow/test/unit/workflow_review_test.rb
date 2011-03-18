require 'test_helper'

class WorkflowReviewTest < ActiveSupport::TestCase
  test "article can't have two reviews in same review slot" do
    news = Section.create! :name => "news", :priority => 10, :url => "news"
    slot = ReviewSlot.create! :name => "Section Editor"
    
    a = Article.create! :section => news, :name => "smiley 80s"
    r1 = WorkflowReview.create! :article => a, :review_slot => slot
    
    r2 = WorkflowReview.new :article => a, :review_slot => slot
    assert (not r2.save)
    assert r2.errors[:review_slot]
  end
  test "article can have two reviews in different slots" do
    news = Section.create! :name => "news", :priority => 10, :url => "news"
    slot1 = ReviewSlot.create! :name => "Section Editor"
    slot2 = ReviewSlot.create! :name => "Copy Editor"
    
    a = Article.create! :section => news, :name => "smiley 80s"
    r1 = WorkflowReview.create! :article => a, :review_slot => slot1
    
    r2 = WorkflowReview.new :article => a, :review_slot => slot2
    assert (r2.save)
  end
end
