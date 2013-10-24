class AssignmentType < ActiveRecord::Base
  attr_accessible :due_date_present, :levels, :max_value, :name,
    :percentage_course, :point_setting, :points_predictor_display,
    :predictor_description, :resubmission, :universal_point_value, :course,
    :course_id, :order_placement, :student_weightable, :mass_grade,
    :score_levels_attributes, :score_level, :mass_grade_type, :course,
    :student_logged_revert_button_text, :student_logged_button_text,
    :notify_released

  belongs_to :course
  belongs_to :grade_scheme
  has_many :assignments
  has_many :submissions, :through => :assignments
  has_many :assignment_weights
  has_many :grades
  has_many :score_levels, -> { order "value" }
  accepts_nested_attributes_for :score_levels, allow_destroy: true

  validates_presence_of :name, :points_predictor_display, :point_setting

  scope :student_weightable, -> { where(:student_weightable => true) }
  scope :ordered, -> { order 'order_placement ASC' }
  scope :weighted_for_student, ->(student) { joins("LEFT OUTER JOIN assignment_weights ON assignment_types.id = assignment_weights.assignment_type_id AND assignment_weights.student_id = '#{sanitize student.id}'") }

  def self.weights_for_student(student)
    group('assignment_types.id').weighted_for_student(student).pluck('assignment_types.id, COALESCE(MAX(assignment_weights.weight), 0)')
  end

  def weight_for_student(student)
    return 1 unless student_weightable?
    assignment_weights.where(student: student).weight
  end

  #These determine how assignment types appears in the predictor
  def slider?
    points_predictor_display == "Slider"
  end

  def fixed?
    points_predictor_display == "Fixed"
  end

  def select?
    points_predictor_display == "Select List"
  end

  def per_assignment?
    points_predictor_display == "Set per Assignment"
  end

  #Checks if the assignment type has associated score levels
  def has_levels?
    score_levels.present?
  end

  #Powers the To Do list, checks if there are assignments within the next week (soon is a scope in the Assignment model)
  def has_soon_assignments?
    assignments.any?(&:soon?)
  end

  #Determines how the assignment type is handled in Quick Grade
  def grade_checkboxes?
    mass_grade_type == "Checkbox"
  end

  def grade_select?
    mass_grade_type == "Select List"
  end

  def grade_radio?
    mass_grade_type == "Radio Buttons"
  end

  def grade_text?
    mass_grade_type == "Text"
  end

  def grade_per_assignment?
    mass_grade_type == "Set per Assignment"
  end

end
