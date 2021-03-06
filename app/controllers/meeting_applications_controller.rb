class MeetingApplicationsController < ApplicationController

  before_action :set_meeting, only: %i[create index show]
  before_action :ban_appying_to_same_sex, only: :create

  def create
    @meeting_application = MeetingApplication.create!(meeting_application_params)
    @user = @meeting.planning_user
    respond_to do |format|
      format.html { redirect_back(fallback_location: @meeting, notice: "申請が完了しました。") }
      format.js { render ajax_redirect_to(meeting_path(@meeting)), flash[:notice] = "申請が完了しました。" }
    end
  end

  def destroy
    @meeting = MeetingApplication.find(params[:id]).meeting
    @user = @meeting.planning_user
    current_user.unapply_meeting(@meeting)
    respond_to do |format|
      format.html { redirect_back(fallback_location: @meeting, notice: "申請を取り消しました。") }
      format.js { render ajax_redirect_to(meeting_path(@meeting)), flash[:notice] = "申請を取り消しました。" }
    end
  end

  def index
    @meeting_applications = @meeting.meeting_applications.eager_load([:applicant])
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @meeting_application = MeetingApplication.find(params[:id])
    @partner = @meeting_application.applicant
    Array(current_user.message_rooms).each do |cmr|
      Array(@partner.message_rooms).each do |ncmr|
        @message_room ||= ncmr if cmr == ncmr
      end
    end
  end

  private

  def set_meeting
    @meeting = Meeting.find(params[:meeting_id])
  end

  def ban_appying_to_same_sex
    return if @meeting.planning_user.sex != current_user.sex
    respond_to do |format|
      format.html { redirect_back(fallback_location: @meeting, flash: {error: "このプランには申請できません。"}) }
      format.js { render ajax_redirect_to(meeting_path(@meeting)), flash[:error] = "このプランには申請できません。" }
    end
  end

  def meeting_application_params
    params.require(:meeting_application).permit(:detail).merge(meeting_id: params[:meeting_id], applicant_id: current_user.id)
  end

end
