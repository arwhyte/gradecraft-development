class AssignmentsController < ApplicationController
  before_filter :ensure_staff?, :except => :feed

  def index
    respond_with @assignments = current_course.assignments.order('due_at ASC')
  end

   def settings
    @title = "Assignments"
    @assignments = current_course.assignments
    @assignment_types = current_course.assignment_types
    @grade_schemes = current_course.grade_schemes
    respond_to do |format|
      format.html
      format.json { render json: @assignments.as_json(only:[:id, :name, :description, :point_total, :due_at, :assignment_type_id, :grade_scheme_id, :grade_scope, :visible, :required ]) }
    end
  end

  def show
    @assignment = current_course.assignments.find(params[:id])
    @groups = @assignment.groups
    @team = current_course.teams.find_by(id: params[:team_id]) if params[:team_id]
    @students = @team ? @team.students : current_course.students
    respond_with @assignment
  end

  def new
    @title = "Create a New Assignment"
    @assignment = current_course.assignments.new
    @assignment_types = current_course.assignment_types
    @grade_schemes = current_course.grade_schemes
  end

  def edit
    @assignment = current_course.assignments.find(params[:id])
    @assignment_rubrics = current_course.rubric_ids.map do |rubric_id|
      @assignment.assignment_rubrics.where(rubric_id: rubric_id).first_or_initialize
    end
    respond_with @assignment
  end

  def create
    @assignment = current_course.assignments.new(params[:assignment])
    if @assignment.save
      respond_with @assignment, :location => assignment_path(@assignment), :notice => 'Assignment was successfully created.'
    else
      respond_with @assignment
    end
  end

  def update
    @assignment = current_course.assignments.find(params[:id])
    @assignment.update_attributes(params[:assignment])
    respond_with @assignment
  end

  def destroy
    @assignment = current_course.assignments.find(params[:id])
    @assignment.destroy

    respond_to do |format|
      format.html { redirect_to assignments_url }
      format.json { head :ok }
    end
  end

  def feed
    @assignments = current_course.assignments
    respond_with @assignments.with_due_date do |format|
      format.ics do
        render :text => CalendarBuilder.new(:assignments => @assignments.with_due_date ).to_ics, :content_type => 'text/calendar'
      end
    end
  end

  private

  def assignment_params
    params.require(:assignment).permit(:assignment_rubrics_attributes => [:id, :rubric_id, :_destroy])
  end
end
