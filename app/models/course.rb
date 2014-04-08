class Course < ActiveRecord::Base
  attr_accessible :courseno, :name,
    :semester, :year, :badge_setting, :team_setting, :team_term, :user_term,
    :user_id, :course_id, :homepage_message, :group_setting,
    :total_assignment_weight, :assignment_weight_close_at, :team_roles,
    :section_leader_term, :group_term, :assignment_weight_type,
    :has_submissions, :teams_visible, :badge_use_scope,
    :weight_term, :badges_value, :predictor_setting, :max_group_size,
    :min_group_size, :shared_badges, :graph_display, :max_assignment_weight,
    :assignments, :default_assignment_weight, :accepts_submissions,
    :tagline, :academic_history_visible, :office, :phone, :class_email,
    :twitter_handle, :twitter_hashtag, :location, :office_hours, :meeting_times,
    :use_timeline, :media_file, :media_credit, :media_caption, :assignment_term,
    :challenge_term, :badge_term, :grading_philosophy, :team_score_average,
    :team_challenges, :team_leader_term, :max_assignment_types_weighted,
    :point_total, :in_team_leaderboard, :grade_scheme_elements_attributes, 
    :add_team_score_to_student

  has_many :course_memberships
  has_many :users, :through => :course_memberships
  accepts_nested_attributes_for :users

  with_options :dependent => :destroy do |c|
    c.has_many :assignment_types
    c.has_many :assignments
    c.has_many :badges
    c.has_many :categories
    c.has_many :challenges
    c.has_many :challenge_grades, :through => :challenges
    c.has_many :earned_badges
    c.has_many :grade_scheme_elements
    c.has_many :grades
    c.has_many :groups
    c.has_many :group_memberships
    c.has_many :rubrics
    c.has_many :submissions
    c.has_many :teams
  end

  accepts_nested_attributes_for :grade_scheme_elements, allow_destroy: true

  validates_presence_of :name, :courseno

  def user_term
    super.presence || 'Player'
  end

  def team_term
    super.presence || 'Team'
  end

  def group_term
    super.presence || 'Group'
  end

  def team_leader_term
    super.presence || 'Team Leader'
  end

  def weight_term
    super.presence || 'Multiplier'
  end

  def badge_term
    super.presence || 'Badge'
  end

  def assignment_term
    super.presence || 'Assignment'
  end

  def challenge_term
    super.presence || 'Challenge'
  end

  def students
    users.students
  end

  def has_teams?
    team_setting == true
  end

  def has_team_challenges?
    team_challenges == true
  end

  def graph_display?
    graph_display == true
  end

  def teams_visible?
    teams_visible == true
  end

  def in_team_leaderboard?
    in_team_leaderboard == true
  end

  def has_badges?
    badge_setting == true
  end

  def valuable_badges?
    badges_value == true
  end

  def predictor_on?
    predictor_setting == true
  end

  def has_groups?
    group_setting == true
  end

  def course_badges?
    badge_use_scope == "Course"
  end

  def assignment_badges?
    badge_use_scope == "Assignment"
  end

  def multi_badges?
    badge_use_scope == "Both"
  end

  def shared_badges?
    shared_badges == true
  end

  def formatted_tagline
    if tagline.present?
      tagline
    else
      " "
    end
  end

  def total_points
    assignments.point_total
  end

  def student_weighted?
    total_assignment_weight.to_i > 0
  end

  def assignment_weight_open?
    assignment_weight_close_at.nil? || assignment_weight_close_at > Time.now
  end

  def team_roles?
    team_roles == true
  end

  def has_submissions?
    accepts_submissions == true
  end

  def grade_level_for_score(score)
    grade_scheme_elements.where('low_range <= ? AND high_range >= ?', score, score).pluck('level').first
  end

  def grade_letter_for_score(score)
    
    grade_scheme_elements.where('low_range <= ? AND high_range >= ?', score, score).pluck('letter').first
  end

  def element_for_score(score)
    grade_scheme_elements.where('low_range <= ? AND high_range >= ?', score, score).first
  end

  def membership_for_student(student)
    course_memberships.detect { |m| m.user_id == student.id }
  end

  def assignment_weight_for_student(student)
    student.assignment_weights.pluck('weight').sum
  end

  def assignment_weight_spent_for_student(student)
    assignment_weight_for_student(student) >= total_assignment_weight.to_i
  end

  def score_for_student(student)
    course_memberships.where(:user_id => student).first.score
  end

  def minimum_course_score
    course_memberships.order('course_memberships.score ASC').first.user
  end

  def maximum_course_score
    #.max
  end

  def average_course_score
    #.max
  end

  def median_course_score
    #len % 2 == 1 ? sorted[len/2] : (sorted[len/2 - 1] + sorted[len/2]).to_f / 2
  end

  def student_count
    students.count
  end

  def graded_student_count
    students.being_graded.count
  end

  def professor
    users.where(:role => "professor").first
  end
  
  #badges
  def course_badge_count
   badges.count
  end
  
  def awarded_course_badge_count
   earned_badges.count
  end
  
end
