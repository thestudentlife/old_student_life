module WorkflowArticleLockHelpers
  def locked?; not self.locked_by.nil?; end
  def lock(user); self.locked_by = user; end
  def unlock; self.locked_by = nil; end
end

class WorkflowArticle < ActiveRecord::Base
  include WorkflowArticleLockHelpers
  
  belongs_to :article
  belongs_to :locked_by, :class_name => 'User', :foreign_key => 'locked_by'
  
  serialize :proposed_titles, Array
  
  validates_presence_of :name
  
  def to_s; name; end
end

# WebDAV really needs to be converted into an Engine

WorkflowArticle.class_eval do
  after_save do
    Rails.cache.delete Workflow::Dav::Cache.lockfile_key(id)
  end
  before_destroy do
    Rails.cache.delete Workflow::Dav::Cache.lockfile_key(id)
  end
end