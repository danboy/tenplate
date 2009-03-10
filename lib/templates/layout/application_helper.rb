# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def ie?
    m = /MSIE\s+([0-9, \.]+)/.match(request.user_agent)
    unless m.nil?
      m[1].to_f
    end
  end

end
