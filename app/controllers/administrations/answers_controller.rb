module Administrations
  class AnswersController < ApplicationController
    authorize_resource :class => false
    before_filter :get_learning_object

    def create
      begin
        ActiveRecord::Base.transaction do
          @learning_object.answers.create!({
                                              answer_text: params[:answer][:answer_text],
                                              is_correct: params[:answer][:is_correct] == "1"
                                           })
          @learning_object.validate_answers!
        end
      rescue AnswersCorrectnessError
        return redirect_to edit_administrations_learning_object_path id: @learning_object.id, :alert => 'Otázka nesmie mať viac ako jednu správnu odpoveď.'
      rescue AnswersVisibilityError
        return redirect_to edit_administrations_learning_object_path id: @learning_object.id, :alert => 'Otázka nesmie mať viac ako jednu viditeľnú odpoveď.'
      end
      redirect_to edit_administrations_learning_object_path id: @learning_object.id, :notice => 'Odpoveď bola pridaná.'
    end

    def update
      route = edit_administrations_learning_object_path id: @learning_object.id

      begin
        ActiveRecord::Base.transaction do
          @learning_object.answers.each do |a|
            a.update!(
                is_correct: params["correct_answer_#{a.id}"] == "1",
                answer_text: params["edit_answer_text_#{a.id}"]
            )
          end
          @learning_object.validate_answers!
        end
      rescue AnswersCorrectnessError
        return redirect_to route, :alert => 'Otázka nesmie mať viac ako jednu správnu odpoveď.'
      rescue AnswersVisibilityError
        return redirect_to route, :alert => 'Otázka nesmie mať viac ako jednu viditeľnú odpoveď.'
      end

      redirect_to route, :notice => 'Zmeny v odpovediach boli úspešne uložené.'
    end

    def destroy
      Answer.find_by_id(params[:answer_id]).destroy!
      redirect_to edit_administrations_learning_object_path(id: @learning_object.id), notice: 'Otazka bola odstranena'
    end

    private
    def get_learning_object
      begin
        @learning_object = LearningObject.find(params[:learning_object_id])
      rescue ActiveRecord::RecordNotFound
        redirect_to administration_path
      end
    end
  end
end