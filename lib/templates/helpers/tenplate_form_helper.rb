module TenplateFormHelper
  # Good example for refactoring group
  def tenplate_form_for(record_or_name_or_array, *args, &proc)
    options = args.detect {|argument| argument.is_a?(Hash)}
    if options.nil?
      options = {:builder => TenplateFormBuilder}
      args << options
    end
    options[:builder] = TenplateFormBuilder unless options.nil?

    form_for(record_or_name_or_array, *args, &proc)
  end

  def tenplate_fields_for(record_or_name_or_array, *args, &proc)
    options = args.detect {|argument| argument.is_a?(Hash)}
    if options.nil?
      options = {:builder => TenplateFormBuilder}
      args << options
    end
    options[:builder] = TenplateFormBuilder unless options.nil?

    fields_for(record_or_name_or_array, *args, &proc)
  end

  def fieldset_section(options = {}, &block)
    haml_tag :fieldset, options[:html] do
      unless options[:legend].nil? || options[:legend].blank?
        haml_tag :legend do
          puts options[:legend]
        end
      end
      yield
    end
  end

  def checkbox_item_wrapper(is_part_of_group = false, &block)
    if is_part_of_group
      wrapping_tag = :li
      extra_attributes = {}
    else
      wrapping_tag = :div
      extra_attributes = {:class => :checkbox}
    end

    wrapping_tag = is_part_of_group ? :li : :div
    haml_tag wrapping_tag, extra_attributes do
      yield
    end
  end
end
