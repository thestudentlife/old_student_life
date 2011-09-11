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

	def proposed_titles_with_guard
		proposed_titles_without_guard || []
	end
	alias_method_chain :proposed_titles, :guard
  
  validates_presence_of :name
  
  def to_s; name; end
end
