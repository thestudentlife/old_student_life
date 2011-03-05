class Subsection < ActiveRecord::Base
  belongs_to :section
  
  def to_s; name; end
  
  def full_name
    "#{section.name} – #{name}"
  end
end
