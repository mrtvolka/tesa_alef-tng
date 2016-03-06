module ApplicationHelper
  def is_active_page(var, controller_action)
    if(!var.nil? && (controller_action == "weeks/enter_test" || controller_action == "weeks/list" ||
        controller_action == "weeks/test_list" || controller_action == "weeks/index"))
      '-inactive'
    else
      ''
    end
  end

  def is_active_page2(var)
    if(var.nil?)
      ''
    else
      '-inactive'
    end
  end
end
