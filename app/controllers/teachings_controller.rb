class TeachingsController < ApplicationController
  authorize_resource :class => false
  def show
    @setup= Setup.take

    #@exercises= Exercise.all.order(week_id: :asc)

    if current_user.role == 'administrator'
      @exercises= Exercise.all.order(:week_id, :start)
    else
      @exercises= Exercise.all.where(user_id: current_user.id).order(:week_id, :start)
    end
  end
end
