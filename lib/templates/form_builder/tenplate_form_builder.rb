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
      label_parameters = options.delete(:label)

      if label_parameters
        extra_class = label_parameters.delete(:display) == false ? 'hidden' : nil
        label_html_attributes = label_parameters[:html] || {}
        supplied_classes = label_html_attributes[:class]
        label_html_attributes[:class] = supplied_classes.nil? ? extra_class : "#{extra_class} #{supplied_classes}".strip
        label_text = label_parameters.delete(:text)
      else
        label_html_attributes = {}
      end

      locals = {:element => super, :label => label(field, label_text, label_html_attributes)}
      locals.merge!(:tip => options.delete(:tip) || "")

      if has_errors_on?(field)
        locals.merge!(:error => error_message(field, options))
        @template.render :partial => 'form_templates/field_with_errors', :locals => locals
      else
        @template.render :partial => 'form_templates/field', :locals => locals
      end
    end
  end

  def check_box_tag(name, options = {})
    if [true, false, nil].include?(options[:selected]) && options[:selected] == true
      checked_or_not = true
    else
      checked_or_not = false
    end
    checked_value = options[:checked_value].nil? ? "1" : options[:checked_value]
    unchecked_value = options[:unchecked_value].nil? ? "1" : options[:unchecked_value]

    @template.render :partial => 'form_templates/check_box',
                     :locals => {:name => name,
                                 :checked_value => checked_value,
                                 :unchecked_value => unchecked_value,
                                 :checked_or_not => checked_or_not,
                                 :is_scoped_by_object => false,
                                 :label_text => options[:label],
                                 :builder => self,
                                 :options => options}
  end

  def check_box(object_method, options = {})
    if [true, false, nil].include?(options[:selected]) && options[:selected] == true
      checked_or_not = true
    else
      checked_or_not = false
    end
    checked_value = options[:checked_value].nil? ? "1" : options[:checked_value]
    unchecked_value = options[:unchecked_value].nil? ? "1" : options[:unchecked_value]

    @template.render :partial => 'form_templates/check_box',
                     :locals => {:object_name => @object_name,
                                 :object_method => object_method,
                                 :checked_value => checked_value,
                                 :unchecked_value => unchecked_value,
                                 :checked_or_not => checked_or_not,
                                 :is_scoped_by_object => true,
                                 :label_text => options[:label],
                                 :builder => self,
                                 :options => options}
  end

  def check_box_group(items, options = {})
    @template.render :partial => 'form_templates/check_box_group',
                     :locals => {:title => options[:title], :items => items, :builder => self, :selected_values => options[:selected]}
  end

  def auto_render_check_box(hash_or_string, selected_values = [])
    field_name, label = hash_or_string.is_a?(Hash) ? hash_or_string.to_a.flatten : hash_or_string
    if object.respond_to?(field_name)
      check_box(field_name, :label => label, :selected => selected_values.include?(field_name))
    else
      check_box_tag(field_name, :label => label, :selected => selected_values.include?(field_name))
    end
  end

  def radio_button_group(field, options)
    items = options[:items]
    title = options[:title] || field.to_s.capitalize
    selected_item = options[:selected] || value_for(items.first)

    @template.render :partial => 'form_templates/radio_button_group',
                     :locals => {:title => title, :items => items, :field => field, :builder => self, :selected_item => selected_item}
  end

  def label(attribute, hash_or_string, options = {})
    text = label_text_for(hash_or_string)
    @template.label(@object_name, attribute, text, objectify_options(options))
  end

  # Generates a radio button & associated label for the supplied attribute of the 
  # given object.
  def radio_button(attribute, hash_or_string, options = {})
    tag_value = value_for(hash_or_string)
    label_options = options.delete(:label) || {}
    options[:checked] = options.delete(:selected_item) == tag_value ? "checked" : nil

    associated_element_id = "#{object_name}_#{attribute}_#{tag_value}".downcase
    @template.radio_button(@object_name, attribute, tag_value, objectify_options(options)) +
    label(attribute, hash_or_string, label_options.merge(:for => associated_element_id))
  end

  def title(form_title)
    @template.render :partial => 'form_templates/form_title', :locals => {:title => form_title}
  end

  def label_text_for(hash_or_string)
    hash_or_string.is_a?(Hash) ? hash_or_string.keys.first : hash_or_string
  end

  def value_for(hash_or_string)
    hash_or_string.is_a?(Hash) ? hash_or_string.values.first : hash_or_string
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
