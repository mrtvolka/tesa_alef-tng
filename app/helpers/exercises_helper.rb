module ExercisesHelper
  def show_day_of_week(value)
    case value.wday
      when 1
        "pondelok"
      when 2
        "utorok"
      when 3
        "streda"
      when 4
        "štvrtok"
      when 5
        "piatok"
      else
        "vikend"
    end
  end
end