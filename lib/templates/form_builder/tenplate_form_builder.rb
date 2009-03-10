class TenplateFormBuilder < ActionView::Helpers::FormBuilder
  helpers = field_helpers + %w(date_select datetime_select time_select collection_select) - %w(hidden_field label fields_for text_field)

  helpers.each do |name|
    define_method name do |field, *args|
      options = args.detect {|argument| argument.is_a?(Hash)} || {}
      label_text = {}
      label_html_attributes = {}
      if label = options.delete(:label)
        label_html_attributes.merge!(:class => 'hidden') if (label.delete(:display) == false)
        label_html_attributes.merge!(:text  => label.delete(:text))
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

  def label_attributes(object_method, label_hash={})
    label_hash ||= {}
    label_html_attributes = { :text  => label_hash.delete(:text) || object_method.to_s.titleize,
                              :for   => label_hash.delete(:for) || object_method,
                              }
  end

  def text_field(object_method , options={})
    label_html_attributes = label_attributes(object_method, options.delete(:label))
    tip = options.delete(:tip)
    value = options.delete(:value) || object.respond_to?(object_method) && object.send(object_method) || nil
    supported_attributes = [:class, :id, :disabled, :size, :alt, :tabindex, :accesskey, :onfocus, :onblur, :onselect, :onchange, :value]
    options.delete_if {|attribute_name, attribute_value| !supported_attributes.include?(attribute_name.to_sym)}
    @template.render :partial => "form_templates/text_field",
                     :locals => {:object_name => object_name,
                                 :object_method => object_method,
                                 :label_text  => label_html_attributes[:text],
                                 :label_for   => label_html_attributes[:for],
                                 :value       => value,
                                 :builder     => self,
                                 :scoped_by_object => true,
                                 :tip         => tip,
                                 :options     => options
                                }
  end

  def text_field_tag(name, options={})
    label_html_attributes = label_attributes(name, options.delete(:label))
    tip = options.delete(:tip)
    supported_attributes = [:class, :id, :disabled, :size, :alt, :tabindex, :accesskey, :onfocus, :onblur, :onselect, :onchange, :value]
    options.delete_if {|attribute_name, attribute_value| !supported_attributes.include?(attribute_name.to_sym)}
    @template.render :partial => "form_templates/text_field",
                     :locals  => {:name       => name,
                                  :label_text  => label_html_attributes[:text],
                                  :label_for   => label_html_attributes[:for],
                                  :value      => options[:value],
                                  :scoped_by_object => false,
                                  :tip =>tip,
                                  :options    => options
                                 }

  end

  def check_box_tag(name, options = {})
    options.delete(:label_method)
    options.delete(:value_method)
    options.delete(:scoped_by_object)
    part_of_group        = options.delete(:part_of_group) == true
    label_text           = options[:label] && options[:label][:text] ? options[:label].delete(:text) : name.to_s.titleize
    label_for            = options[:label] && options[:label][:for]  ? options[:label].delete(:for) : name
    selected_state       = options.delete(:selected) == true
    checked_value        = options[:checked_value].nil? ? "1" : options.delete(:checked_value)
    unchecked_value      = options[:unchecked_value].nil? ? "0" : options.delete(:unchecked_value)
    supported_attributes = [:checked, :class, :id, :disabled, :size, :alt, :tabindex, :accesskey, :onfocus, :onblur, :onselect, :onchange]
    options.delete_if {|attribute_name, attribute_value| !supported_attributes.include?(attribute_name.to_sym)}

    @template.render :partial => 'form_templates/check_box',
                     :locals => {:name             => name,
                                 :checked_value    => checked_value,
                                 :unchecked_value  => unchecked_value,
                                 :selected_state   => selected_state,
                                 :scoped_by_object => false,
                                 :label_text       => label_text,
                                 :label_for        => label_for,
                                 :builder          => self,
                                 :part_of_group    => part_of_group,
                                 :options          => options}
  end

  def check_box(object_method, options = {})
    label_text      = options[:label] && options[:label][:text] ? options[:label].delete(:text) : object_method.to_s.titleize
    label_for       = options[:label] && options[:label][:for]  ? options[:label].delete(:for) : object_method
    checked_value   = options[:checked_value].nil? ? "1" : options.delete(:checked_value)
    unchecked_value = options[:unchecked_value].nil? ? "0" : options.delete(:unchecked_value)
    part_of_group   = options.delete(:part_of_group) == true
    value_method    = object_method.is_a?(Hash) ? object_method.keys.first : object_method
    if options.delete(:selected) == true || (object.respond_to?(value_method) && object.send(value_method) == true)
      selected_state = "checked"
    end

    supported_attributes = [:checked, :class, :id, :disabled, :size, :alt, :tabindex, :accesskey, :onfocus, :onblur, :onselect, :onchange]
    options.delete_if {|attribute_name, attribute_value| !supported_attributes.include?(attribute_name.to_sym)}

    @template.render :partial => 'form_templates/check_box',
                     :locals => {:object_name         => object_name,
                                 :object_method       => object_method,
                                 :scoped_by_object    => true,
                                 :label_text          => label_text,
                                 :label_for           => label_for,
                                 :checked_value       => checked_value,
                                 :unchecked_value     => unchecked_value,
                                 :selected_state      => selected_state,
                                 :part_of_group       => part_of_group,
                                 :builder             => self,
                                 :options             => options}
  end

  def check_box_group(items, options = {})
    selected_values = options.delete(:selected) || []
    part_of_group   = !items.nil? && items.size > 1
    title           = options.delete(:title)

    @template.render :partial => 'form_templates/check_box_group',
                     :locals => {:title           => title,
                                 :items           => items,
                                 :builder         => self,
                                 :part_of_group   => part_of_group,
                                 :options         => options,
                                 :selected_values => selected_values}
  end

  def auto_render_check_box(checkboxable_object, selected_values = [], options = {})
    part_of_group = options[:part_of_group] == true
    checked_value = 1
    unchecked_value = 0
    field_name, label_text = checkboxable_object.is_a?(Hash) ? checkboxable_object.to_a.flatten : checkboxable_object
    if !field_name.is_a?(ActiveRecord::Base) && object.respond_to?(field_name)
      selected = Array(selected_values).include?(field_name) || object.send(field_name) == true
      check_box(field_name, :label => {:text => label_text},
                            :selected => selected,
                            :part_of_group => part_of_group,
                            :checked_value => checked_value,
                            :unchecked_value => unchecked_value
                            )
    else
      checkboxable_object_id = field_name
      scoped_field_name = options[:scoped_by] || field_name.class.to_s.downcase
      pluralized_value_method = options[:value_method] ? options[:value_method].to_s.pluralize : "ids"
      potential_scoping = "#{scoped_field_name}_#{pluralized_value_method}"
      if object.respond_to?(potential_scoping)
        field_name = "#{object_name.downcase}[#{potential_scoping}][]"
        checkboxable_object_id = "#{object_name.downcase}_#{scoped_field_name}_#{checkboxable_object.id}"
      end

      if !options[:label_method].nil? && checkboxable_object.respond_to?(options[:label_method])
        label_text = checkboxable_object.send(options[:label_method])
        options.delete(:label_method)
      else
        label_text = "':label_method' not set!"
      end

      if options[:value_method] && checkboxable_object.respond_to?(options[:value_method])
        checked_value = checkboxable_object.send(options[:value_method])
        options.delete(:value_method)
      end
      selected_value = Array(selected_values).include?(field_name) || Array(selected_values).include?(checked_value)

      check_box_tag(field_name, options.merge({:label           => {:text => label_text, :for => checkboxable_object_id},
                                               :id              => checkboxable_object_id,
                                               :selected        => selected_value,
                                               :checked_value   => checked_value,
                                               :unchecked_value => unchecked_value,
                                               :part_of_group   => part_of_group}))
    end
  end

  def radio_button_group(field, options =  {})
    items = options[:items] || []
    title = options[:title] || field.to_s.capitalize
    selected_item = options[:selected] || value_for(items.first)

    @template.render :partial => 'form_templates/radio_button_group',
                     :locals => {:title => title, :items => items, :field => field, :builder => self, :selected_item => selected_item}
  end

  # Generates a radio button & associated label for the supplied attribute of the 
  # given object.
  def radio_button(attribute, hash_or_string, options = {})
    tag_value         = value_for(hash_or_string)
    label_options     = options.delete(:label) || {}
    options[:checked] = options.delete(:selected_item) == tag_value ? "checked" : nil
    options.delete_if {|key, value| value.nil?}

    associated_element_id = "#{object_name}_#{attribute}_#{tag_value}".downcase
    radio_html = @template.radio_button(@object_name, attribute, tag_value, objectify_options(options))
    label_html = label(attribute, hash_or_string, label_options.merge(:for => associated_element_id))
    radio_html + label_html
  end

  def text_area_tag(name, options = {})
    label_html_attributes = label_attributes(name, options.delete(:label))
    tip = options.delete(:tip)
    supported_attributes = [:class, :id, :disabled, :size, :alt, :tabindex, :accesskey, :onfocus, :onblur, :onselect, :onchange, :value]
    options.delete_if {|attribute_name, attribute_value| !supported_attributes.include?(attribute_name.to_sym)}

    @template.render :partial => 'form_templates/text_area',
                     :locals  => {:name                => name,
                                  :value               => options[:value],
                                  :label_text          => label_html_attributes[:text],
                                  :label_for           => label_html_attributes[:for],
                                  :tip                 => tip,
                                  :builder             => self,
                                  :scoped_by_object    => false,
                                  :options             => options
                                 }
  end

  def text_area(object_method, options = {})
    label_html_attributes = label_attributes(object_method, options.delete(:label))
    tip = options.delete(:tip)
    value_method = options.delete(:value_method) || object_method
    value =  value = options.delete(:value) || object.respond_to?(object_method) && object.send(object_method)
    label_method = options.delete(:label_method) || object_method
    supported_attributes = [:class, :id, :disabled, :size, :alt, :tabindex, :accesskey, :onfocus, :onblur, :onselect, :onchange, :value]
    options.delete_if {|attribute_name, attribute_value| !supported_attributes.include?(attribute_name.to_sym)}

    @template.render :partial => 'form_templates/text_area',
                     :locals  => {:object_name         => object_name,
                                  :object_method       => object_method,
                                  :value_method        => value_method,
                                  :label_method        => label_method,
                                  :label_text          => label_html_attributes[:text],
                                  :label_for           => label_html_attributes[:for],
                                  :tip                 => tip,
                                  :builder             => self,
                                  :scoped_by_object    => true,
                                  :value               => value,
                                  :options             => options
                                 }
  end

  def label(attribute, hash_or_string, options = {})
    text = label_text_for(hash_or_string)
    @template.label(@object_name, attribute, text, objectify_options(options))
  end

  def title(form_title)
    @template.render :partial => 'form_templates/form_title', :locals => {:title => form_title}
  end

  def subtitle(form_subtitle)
    @template.render :partial => 'form_templates/form_subtitle', :locals => {:subtitle => form_subtitle}
  end

  private
    def label_text_for(hash_or_string)
      hash_or_string.is_a?(Hash) ? hash_or_string.values.first : hash_or_string
    end

    def value_for(hash_or_string)
      hash_or_string.is_a?(Hash) ? hash_or_string.keys.first : hash_or_string
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
