class UsersController < ApplicationController
  def toggle_show_solutions
    @user = current_user
    if params[:show_solutions] == "false"
      @user.update(show_solutions: FALSE)
    else
      @user.update(show_solutions: TRUE)
    end
  end

  def send_feedback
    feedback = Feedback.new(
        message: params[:message],
        user_id: current_user.id,
        user_agent: request.user_agent ,
        accept: request.accept,
        url: URI(request.referer).path
    )

    if !params[:question_id].nil?
      feedback.update learning_object_id: params[:question_id]
    end

    if feedback.save
      FeedbackMailer.new(feedback).deliver_now
    end
  end
end