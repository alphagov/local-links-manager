module UrlStatusPresentation
  include ActionView::Helpers::DateHelper

  def status_description
    return "Not checked" unless status
    return "Good" if status == "ok"

    case status
    when "caution"
      "Note: #{problem_summary}"
    when "broken"
      "Broken: #{problem_summary}"
    when "missing"
      "Missing"
    when "pending"
      "Pending"
    else
      problem_summary
    end
  end

  def label_status_class
    return nil unless status
    return "label label-success" if status == "ok"
    return "label label-danger" if status == "broken"
    return "label label-warning" if status == "caution"
    return "label label-danger" if status == "missing"

    "label label-info"
  end

  def status_tag_colour
    return "grey" unless status
    return "green" if status == "ok"
    return "yellow" if status == "caution"

    "red"
  end

  def last_checked
    if link_last_checked
      "#{time_ago_in_words(link_last_checked)} ago"
    else
      "Link not checked"
    end
  end

  def updated?
    view_context.flash[:updated].present? &&
      view_context.flash[:updated]["url"] == url &&
      view_context.flash[:updated]["lgil"] == interaction.lgil_code
  end
end
