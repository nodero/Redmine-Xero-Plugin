class ProjectXeroDetails < ActiveRecord::Base

	belongs_to :project, :foreign_key => 'project_id'
	validates_numericality_of :rate, :allow_nil => true

end