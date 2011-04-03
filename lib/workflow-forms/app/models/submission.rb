class Submission < ActiveRecord::Base
	serialize :data, Hash
	
	validates :data, :presence => true
	validates :form, :presence => true
	
	belongs_to :form
end
