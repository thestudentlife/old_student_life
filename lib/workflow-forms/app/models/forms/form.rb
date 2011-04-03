class Forms::Form < ActiveRecord::Base
	serialize :definition, Array
	
	validates :definition, :presence => true
	validates :name, :presence => true
	
	has_many :submissions
end
