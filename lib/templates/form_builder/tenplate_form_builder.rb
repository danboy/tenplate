class TenplateFormBuilder < ActionView::Helpers::FormBuilder
  helpers = field_helpers + %w(date_select datetime_select time_select collection_select) - %w(hidden_field label fields_for)

  def submit_tag
    if object.new_record?
      @template.render :partial => 'form_templates/create_button'
    else
      @template.render :partial => 'form_templates/update_button'
    end
  end

  helpers.each do |name|
    define_method name do |field, *args|
      options = args.detect {|argument| argument.is_a?(Hash)} || {}

      locals = {:element => super, :label => label(field, options[:label])}
      locals.merge!(:tip => options.delete(:tip) || "")

      if has_errors_on?(field)
        locals.merge!(:error => error_message(field, options))
        @template.render :partial => 'form_templates/field_with_errors', :locals => locals
      else
        @template.render :partial => 'form_templates/field', :locals => locals
      end
    end
  end

  def error_message(field, options)
    if has_errors_on?(field)
      errors = object.errors.on(field)
      if errors.is_a?(Array)
        "#{field.to_s.capitalize} #{errors.to_sentence}."
      else
        "'#{field.to_s.capitalize}' #{errors}."
      end
    else
      ''
    end
  end

  def has_errors_on?(field)
    !(object.nil? || object.errors.on(field).blank?)
  end
end
