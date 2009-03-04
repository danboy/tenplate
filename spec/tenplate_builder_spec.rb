require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Person
end

describe TenplateFormBuilder do
  before(:each) do
    @object = mock("A Person object")
    @object_name = @object
    @template = mock("View template object")
    @builder = TenplateFormBuilder.new @object, @object_name, @template, {}, nil
  end

  def testing_option(input_name, output_name = input_name)
    @input_name = input_name
    @output_name = output_name
  end

  shared_examples_for "Any boolean option" do
    it "passes the view template a 'part_of_group' of false when given false" do
      check_options_full :passed_in => {@input_name => false},  :expected => {@output_name => false}
    end

    it "passes the view template a 'part_of_group' of true when given true" do
      check_options_full :passed_in => {@input_name => true},   :expected => {@output_name => true}
    end

    it "passes the view template a 'part_of_group' of false for a non-boolean value" do
      supplied_value = mock("Customized value for '#{@input_name}'")
      check_options_full :passed_in => {@input_name => supplied_value}, :expected => {@output_name => false}
    end
  end

  shared_examples_for "Any customizable option" do
    it "passes the specified value when supplied" do
      supplied_value = mock("Customized value for '#{@input_name}'")
      check_options_full :passed_in => {@input_name => supplied_value}, :expected => { @output_name => supplied_value}
    end
  end

  shared_examples_for "Any item rendered using the TenplateFormBuilder" do
    it "passes a reference to the TenplateFormBuilder" do
       check_options_full :passed_in => {}, :expected => {:builder => @builder}
    end
  end

  context "rendering a 'standard' input type" do
    context "when no errors present on field" do
      before(:each) do
        @object.stub!(:errors).and_return(mock("Error proxy object", :on => false))
        @rendered_input = lambda {"Input rendered"}
        @rendered_label = lambda {"Label rendered"}
        @rendered_template = lambda {"Template rendered"}
        @template.stub!(:text_field).and_return(@rendered_input)
        @template.stub!(:label).and_return(@rendered_label)
        @template.stub!(:render).and_return(@rendered_template)
      end

      [:text_field, :text_area].each do |input_type|
        context "and requesting a '#{input_type}'" do
          it "renders a '#{input_type}' input" do
            expected_input_args = [@object, :first_name, hash_including(:object)]
            @template.should_receive(input_type).with(*expected_input_args).and_return(@rendered_input)
            @builder.send(input_type, :first_name).should_not raise_error
          end
        end
      end

      it "renders a label for the input" do
        expected_label_args = [@object, :first_name, nil, hash_including(:object => @object)]
        @template.should_receive(:label).with(*expected_label_args).and_return(@rendered_label)
        @builder.text_field(:first_name).should_not raise_error
      end

      it "renders the 'field.html.haml' partial"  do
        expected = hash_including(:partial => "form_templates/field")
        @template.should_receive(:render).with(expected).and_return(lambda {"Template rendered"})
        @builder.text_field(:first_name).should_not raise_error
      end
    end
  end

  context "rendering a checkbox" do
    context "by calling 'checkbox_tag'" do
      def check_options_full(validations = {})
        expected_render_arguments = hash_including(:partial => "form_templates/check_box", :locals => hash_including(validations[:expected]))
        @template.should_receive(:render).with(expected_render_arguments).and_return(lambda {"Template rendered"})
        @builder.check_box_tag(:accepted_terms, validations[:passed_in]).should_not raise_error
      end

      context 'with no options passed in' do
        it_should_behave_like "Any item rendered using the TenplateFormBuilder"

        {:name => :accepted_terms,
        :checked_value => '1',
        :unchecked_value => '0',
        :scoped_by_object => false,
        :label_text => 'Accepted Terms',
        :label_for => :accepted_terms,
        :part_of_group => false,
        :options => {}
        }.each_pair do |key, value|
          it "renders the checkbox view template with '#{key}' set to '#{value}'"  do
            expected_render_arguments = hash_including(:partial => "form_templates/check_box", :locals => hash_including(key => value))
            @template.should_receive(:render).with(expected_render_arguments).and_return(lambda {"Template rendered"})
            @builder.check_box_tag(:accepted_terms).should_not raise_error
          end
        end

        it "renders the checkbox view template with the checkbox being in an 'unselected' state" do
          check_options_full :passed_in => {}, :expected => {:selected_state => false}
        end
      end

      context 'with options passed in' do
        it_should_behave_like "Any item rendered using the TenplateFormBuilder"

        context "setting 'checked_value'" do
          before(:each) {testing_option :unchecked_value}
          it_should_behave_like "Any customizable option"
        end

        it "should have the same label signature as 'checkbox' (:label => {:text => xxxx})" do
          custom_label = "I accept these terms"
          check_options_full :passed_in => {:label => {:text => custom_label}}, :expected => {:label_text => custom_label}
        end

        context "setting 'unchecked_value'" do
          before(:each) {testing_option :checked_value}
          it_should_behave_like "Any customizable option"
        end

        context "setting 'part_of_group'" do
          it_should_behave_like "Any boolean option"
          before(:each) {testing_option :part_of_group}
        end

        context "setting 'selected'" do
          it_should_behave_like "Any boolean option"
          before(:each) {testing_option :selected, :selected_state}
        end

        context "manually setting 'scoped_by_object' is ignored" do
          it "passes false for false" do
            check_options_full :passed_in => {:scoped_by_object => false},  :expected => {:scoped_by_object => false}
          end

          it "passes false for true" do
            check_options_full :passed_in => {:scoped_by_object => true},   :expected => {:scoped_by_object => false}
          end

          it "passes false for a non-boolean value" do
            check_options_full :passed_in => {:scoped_by_object => "3232"}, :expected => {:scoped_by_object => false}
          end
        end

        context "setting a custom label" do
          before(:each) {testing_option :label, :label_text}
          it "renders label with value of options[:label][:text]" do
            custom_label = "I accept these terms"
            check_options_full :passed_in => {:label => {:text => custom_label}}, :expected => {:label_text => custom_label}
          end
        end

        context "setting 'label_for'" do
          before(:each) {testing_option :label_for}
          it_should_behave_like "Any customizable option"
        end


        context "setting 'options'" do
          supported_attributes = [:disabled, :size, :alt, :tabindex, :accesskey, :onfocus, :onblur, :onselect, :onchange]

          it "removes all invalid attributes for the 'checkbox' input type" do
            bad_attributes = {:disbled => true, :label => {:text => :text_label}, :bad_tag => :bad_data}
            check_options_full :passed_in => bad_attributes, :expected => {:options => {}}
          end

          supported_attributes.each do |html_attribute|
            it "passes value of '#{html_attribute}' directly through" do
              supplied_value = mock("User specified value")
              check_options_full :passed_in => {html_attribute => supplied_value}, :expected => {:options => {html_attribute => supplied_value}}
            end
          end
        end
      end
    end

    context "by calling 'check_box'" do
      def check_options_full(validations = {})
        expected_render_arguments = hash_including(:partial => "form_templates/check_box", :locals => hash_including(validations[:expected]))
        @template.should_receive(:render).with(expected_render_arguments).and_return(lambda {"Template rendered"})
        @builder.check_box(:accepted_terms, validations[:passed_in]).should_not raise_error
      end

      it_should_behave_like "Any item rendered using the TenplateFormBuilder"

      context 'with no options passed in' do
        {:object_method    => :accepted_terms,
         :checked_value    => '1',
         :unchecked_value  => '0',
         :scoped_by_object => true,
         :label_text       => 'Accepted Terms',
         :label_for        => :accepted_terms,
         :part_of_group    => false,
         :options          => {}
        }.each_pair do |key, value|
          it "renders the checkbox view template with '#{key}' set to '#{value}'"  do
            expected_render_arguments = hash_including(:partial => "form_templates/check_box", :locals => hash_including(key => value))
            @template.should_receive(:render).with(expected_render_arguments).and_return(lambda {"Template rendered"})
            @builder.check_box(:accepted_terms).should_not raise_error
          end
        end

        it "renders the checkbox view template with 'object_name' being set to the object referenced in the builder"  do
          check_options_full :passed_in => {}, :expected => {:object_name => @object}
        end
      end

      context "when passing in a hash w/ a value which is a field on the associated model" do
        it "renders the correct label as the 'value' of the hash w/o the label_method being required"
      end

      context 'with options passed in' do
        [:label_for, :checked_value, :unchecked_value].each do |option_name|
          context "setting '#{option_name.to_s}'" do
            before(:each) {testing_option option_name}
            it_should_behave_like "Any customizable option"
          end
        end

        context "setting a custom label" do
          it "renders label with value of options[:label][:text]" do
            custom_label = "I accept these terms"
            check_options_full :passed_in => {:label => {:text => custom_label}}, :expected => {:label_text => custom_label}
          end
        end

        context "setting 'selected'" do
          before(:each) {testing_option :selected, :selected_state}
          it_should_behave_like "Any boolean option"
        end

        context "setting 'part_of_group'" do
          before(:each) {testing_option :part_of_group}
          it_should_behave_like "Any boolean option"
        end

        context "setting 'options'" do
          supported_attributes = [:disabled, :size, :alt, :tabindex, :accesskey, :onfocus, :onblur, :onselect, :onchange]

          it "removes all invalid attributes for the 'checkbox' input type" do
            bad_attributes = {:disbled => true, :label => {:text => "Custom Label"}, :bad_tag => :bad_data}
            check_options_full :passed_in => bad_attributes, :expected => {:options => {}}
          end

          supported_attributes.each do |html_attribute|
            it "passes value of '#{html_attribute}' directly through" do
              supplied_value = mock("User specified value")
              check_options_full :passed_in => {html_attribute => supplied_value}, :expected => {:options => {html_attribute => supplied_value}}
            end
          end
        end

        context "setting a custom label" do
          it "renders label with value of options[:label][:text]" do
            custom_label = "I accept these terms"
            check_options_full :passed_in => {:label => {:text => custom_label}}, :expected => {:label_text => custom_label}
          end
        end
      end
    end
  end

  context "rendering a group of 'radio_button' items" do
    before(:each) do
      @genders = [:male, :female]
    end

    def check_arguments(args = {})
      passed_in_or_default = args[:passed_in] || [:gender, {:items => @genders}]
      @template.should_receive(:render).with(*args[:expected]).and_return(lambda {"Template rendered"})
      @builder.radio_button_group(*passed_in_or_default).should_not raise_error
    end

    it "passes the 'TenplateFormBuilder' object as the value of 'builder'" do
      check_arguments(:expected => hash_including(:partial => "form_templates/radio_button_group", :locals => hash_including(:builder => @builder)))
    end

    {:items => [:male, :female],
     :title => "Gender",
     :selected_item => :male
    }.each do |attribute, value|
      it "passes '#{value}' as the default value of '#{attribute}'" do
        check_arguments(:expected => hash_including(:partial => "form_templates/radio_button_group", :locals => hash_including(attribute => value)))
      end
    end

    context "when passing in a custom title" do
      it "passes the supplied string as the title of the radio button group" do
        custom_title = "My own title"
        check_arguments(:expected => hash_including(:partial => "form_templates/radio_button_group", :locals => hash_including(:title => custom_title)),
                        :passed_in => [:gender, {:title => custom_title}])
      end
    end

    context "setting a specific item in the group the default item to be 'selected'" do
      it "passes the value of the specified item as the value of 'selected_item'" do
        check_arguments(:expected => hash_including(:partial => "form_templates/radio_button_group", :locals => hash_including(:selected_item => @genders.last)),
                        :passed_in => [:gender, {:items => @genders, :selected => @genders.last}])
      end
    end
  end

  context "rendering a group of 'checkbox' items" do
    before(:each) do
      @field_name_or_items = mock("Collection of items to render with checkboxes", :size => 1, :each => [])
    end

    def check_options_full(validations = {})
      expected_render_arguments = hash_including(:partial => "form_templates/check_box_group", :locals => hash_including(validations[:expected]))
      @template.should_receive(:render).with(expected_render_arguments).and_return(lambda {"Template rendered"})
      @builder.check_box_group(@field_name_or_items, validations[:passed_in]).should_not raise_error
    end

    it_should_behave_like "Any item rendered using the TenplateFormBuilder"

    it "passes the array of items supplied directly through as 'items'" do
      expected_render_arguments = hash_including(:partial => "form_templates/check_box_group", :locals => hash_including(:items => @field_name_or_items))
      @template.should_receive(:render).with(expected_render_arguments).and_return(lambda {"Template rendered"})
      @builder.check_box_group(@field_name_or_items).should_not raise_error
    end

    context "when there are 1 or less items passed in" do
      before(:each) { @field_name_or_items.stub!(:size => 1) }

      it "passes a false value for 'part_of_group'" do
        check_options_full :passed_in => {}, :expected => {:part_of_group => false}
      end
    end

    context "when there are more than 1 items passed in" do
      before(:each) { @field_name_or_items.stub!(:size => 2) }

      it "passes a true value for 'part_of_group'" do
        check_options_full :passed_in => {}, :expected => {:part_of_group => true}
      end
    end

    context 'with no options passed in' do
      {:title           => nil,
       :selected_values => [],
       :part_of_group   => false,
       :options         => {}
      }.each_pair do |key, default_value|
        it "renders the checkbox view template with '#{key}' set to '#{default_value}'"  do
          expected_render_arguments = hash_including(:partial => "form_templates/check_box_group", :locals => hash_including(key => default_value))
          @template.should_receive(:render).with(expected_render_arguments).and_return(lambda {"Template rendered"})
          @builder.check_box_group(@field_name_or_items).should_not raise_error
        end
      end
    end

    context 'with options passed in' do
      context "setting 'title'" do
        before(:each) {testing_option :title}
        it_should_behave_like "Any customizable option"
      end

      context "setting 'selected'" do
        before(:each) {testing_option :selected, :selected_values}
        it_should_behave_like "Any customizable option"
      end
    end
  end

  context "auto-rendering a checkbox" do
    context "when passing in an ActiveRecord instance" do
      before(:each) do
        class Role; end
        @object.stub!(:downcase).and_return("person")
        @selected_items = mock("Items Selected by Default", :include? => false)
        @active_record_object = mock("ActiveRecord object", :class => Role, :name => "Administrator")
        @active_record_object.stub!(:is_a?).with(Hash).and_return(false)
        @active_record_object.stub!(:is_a?).with(ActiveRecord::Base).and_return(true)
        @object_name.stub!(:respond_to?).and_return(true)
        @object_name.stub!(:to_s).and_return("Person")
      end

      {:checked_value   => 1,
       :unchecked_value => 0,
       :label           => "':label_method' not set!",
       :part_of_group   => false,
       :selected        => false
      }.each do |option_name, default_value|
        it "passes a default value of '#{default_value}' for '#{option_name.to_s}'" do
          expected_render_arguments = ["person[role_ids][]", hash_including(option_name => default_value)]
          @builder.should_receive(:check_box_tag).with(*expected_render_arguments).and_return(lambda {"Checkbox tag rendered"})
          @builder.auto_render_check_box(@active_record_object, @selected_items).should_not raise_error
        end
      end

      context "setting 'label_method'" do
        it "passes the value of sending the supplied method to the object specified as the label for the checkbox" do
          expected_render_arguments = ["person[role_ids][]", hash_including(:label => @active_record_object.name)]
          @builder.should_receive(:check_box_tag).with(*expected_render_arguments).and_return(lambda {"Checkbox tag rendered"})
          @builder.auto_render_check_box(@active_record_object, [], :label_method => :name).should_not raise_error
        end

        it "removes the value of 'label_method' from the list of options passed to the view" do
          expected_render_arguments = ["person[role_ids][]", hash_not_including(:label_method)]
          @builder.should_receive(:check_box_tag).with(*expected_render_arguments).and_return(lambda {"Checkbox tag rendered"})
          @builder.auto_render_check_box(@active_record_object, [], :label_method => :name).should_not raise_error
        end
      end

      context "setting 'value_method'" do
        it "names the group of check boxes scoped by the parent object & a pluralized form of the value method ('name' -> 'names')" do
          @builder.should_receive(:check_box_tag).with("person[role_names][]", anything()).and_return(lambda {"Checkbox tag rendered"})
          @builder.auto_render_check_box(@active_record_object, [], :value_method => :name).should_not raise_error
        end

        it "sets the 'checked_value' of the checkbox to the results of issuing the provided method against the supplied object" do
          expected_render_arguments = ["person[role_names][]", hash_including(:checked_value => @active_record_object.name)]
          @builder.should_receive(:check_box_tag).with(*expected_render_arguments).and_return(lambda {"Checkbox tag rendered"})
          @builder.auto_render_check_box(@active_record_object, [], :value_method => :name).should_not raise_error
        end

        it "removes the value of 'value_method' from the list of options passed to the view" do
          expected_render_arguments = ["person[role_names][]", hash_not_including(:value_method)]
          @builder.should_receive(:check_box_tag).with(*expected_render_arguments).and_return(lambda {"Checkbox tag rendered"})
          @builder.auto_render_check_box(@active_record_object, [], :value_method => :name).should_not raise_error
        end
      end

      context "the object bound to the form is associated with" do
        before(:each) do
          @object_name.stub!(:respond_to?).with("role_ids").and_return(true)
          @object_name.stub!(:label_method).with("role_ids").and_return(true)
          @suggested_id = "person_#{@active_record_object.class.to_s.downcase}_#{@active_record_object.id}"
        end

        [:id, :label_for].each do |attribute_name|
          it "passes an auto-suggested value through as '#{attribute_name}' capable of capturing multiple checkboxes selections" do
            expected_render_arguments = ["person[role_ids][]", hash_including(attribute_name => @suggested_id)]
            @builder.should_receive(:check_box_tag).with(*expected_render_arguments).and_return(lambda {"Checkbox tag rendered"})
            @builder.auto_render_check_box(@active_record_object, @selected_items).should_not raise_error
          end
        end
      end

      context "the object bound to the form is not associated with" do
        before(:each) do
          @object_name.stub!(:respond_to?).with("role_ids").and_return(false)
          @active_record_object.stub!(:is_a?).with(Regexp).and_return(false)
        end

        it "passes the object specified straight through as 'id'" do
          expected_render_arguments = [@active_record_object, hash_including(:id => @active_record_object)]
          @builder.should_receive(:check_box_tag).with(*expected_render_arguments).and_return(lambda {"Checkbox tag rendered"})
          @builder.auto_render_check_box(@active_record_object, @selected_items).should_not raise_error
        end

        it "passes the object specified straight through as 'label_for'" do
          expected_render_arguments = [@active_record_object, hash_including(:label_for => @active_record_object)]
          @builder.should_receive(:check_box_tag).with(*expected_render_arguments).and_return(lambda {"Checkbox tag rendered"})
          @builder.auto_render_check_box(@active_record_object, @selected_items).should_not raise_error
        end
      end
    end

    context "when passing in a Hash" do
      before(:each) do
        @object.stub!(:downcase).and_return("person")
        @hash_of_roles = {:admin => "Administrator"}
        @object_name.stub!(:respond_to?).and_return(true)
      end

      def check_options_full(validations = {})
        expected_render_arguments = hash_including(:partial => "form_templates/check_box", :locals => hash_including(validations[:expected]))
        @template.should_receive(:render).with(expected_render_arguments).and_return(lambda {"Template rendered"})
        @builder.check_box(@hash_of_roles, validations[:passed_in]).should_not raise_error
      end

      {:label => "Administrator",
       :selected => false,
       :part_of_group => false,
       :checked_value => 1,
       :unchecked_value => 0
      }.each do |option_name, default_value|
        it "passes a default value of '#{default_value}' for '#{option_name.to_s}'" do
          expected_render_arguments = [:admin, hash_including(option_name => default_value)]
          @builder.should_receive(:check_box).with(*expected_render_arguments).and_return(lambda {"Checkbox tag rendered"})
          @builder.auto_render_check_box(@hash_of_roles).should_not raise_error
        end
      end

      context "and 'selected_values' includes the key of the provided Hash" do
        it "sets 'selected' to true" do
          selected_items = :admin
          expected_render_arguments = [:admin, hash_including(:selected => true)]
          @builder.should_receive(:check_box).with(*expected_render_arguments).and_return(lambda {"Checkbox tag rendered"})
          @builder.auto_render_check_box(@hash_of_roles, selected_items).should_not raise_error
        end
      end

      context "setting 'part_of_group'" do
        before(:each) {testing_option :part_of_group}
        it_should_behave_like "Any boolean option"
      end
    end
  end

  context "rendering a radio button" do
    before(:each) do
      @label = "blue"
      @value = 1
      @hash_or_string = {@value => @label}
      @attribute = :favorite_color
      @radio_proc = mock("Results from radio button call", :call => "Radio rendered", :+ => lambda {"Radio & Label both rendered"})
      @label_proc = mock("Results from label call", :call => "Label rendered")
      @default_passed_in_args = [@attribute, @hash_or_string]
    end

    def render_radio_button(expected_label, expected_input, passed_in = @default_passed_in_args)
      @template.should_receive(:radio_button).with(*expected_input).and_return(@radio_proc)
      @template.should_receive(:label).with(*expected_label).and_return(@label_proc)
      @builder.radio_button(*passed_in).should_not raise_error
    end

    context 'by passing in a Hash for the value/label' do
      it "renders a radio button and label for specified attribute scoped by the object bound to the form" do
        expected_radio_render_args = [@object, @attribute, @value, anything()]
        expected_label_render_args = [@object, @attribute, @label, hash_including(:for => anything(), :object => @object)]
        render_radio_button(expected_label_render_args, expected_radio_render_args)
      end
    end

    context 'by passing in a String for the value/label' do
      before(:each) do
        @hash_or_string = "blue"
        @attribute = :favorite_color
        @radio_proc = mock("Results from radio button call", :call => "Radio rendered", :+ => lambda {"Radio & Label both rendered"})
        @label_proc = mock("Results from label call", :call => "Label rendered")
        @default_passed_in_args = [@attribute, @hash_or_string]
      end

      it "renders a radio button and label for specified attribute scoped by the object bound to the form" do
        expected_radio_render_arguments = [@object, @attribute, @hash_or_string, anything()]
        expected_label_render_arguments = [@object, @attribute, @hash_or_string, hash_including(:for => anything(), :object => @object)]
        render_radio_button(expected_label_render_arguments, expected_radio_render_arguments)
      end
    end

    context "when value of 'selected_item' is equal to the value of the input being rendered" do
      it "renders with a value of 'checked' for the 'checked' attribute" do
        expected_radio_render_arguments = [@object, @attribute, @value, hash_including(:checked => "checked")]
        expected_label_render_arguments = [@object, @attribute, @label, hash_including(:for => anything(), :object => @object)]
        render_radio_button(expected_label_render_arguments, expected_radio_render_arguments, @default_passed_in_args.push({:selected_item => @value}))
      end
    end

    context "when value of 'selected_item' is not equal to the value of the input being rendered" do
      it "renders without the 'checked' attribute" do
        expected_radio_render_arguments = [@object, @attribute, @value, hash_not_including(:checked)]
        expected_label_render_arguments = [@object, @attribute, @label, hash_including(:for => anything(), :object => @object)]
        render_radio_button(expected_label_render_arguments, expected_radio_render_arguments)
      end
    end

    it "renders a label with a 'for' attribute matching the 'id' of the associated radio button" do
      expected_radio_render_arguments = [@object, @attribute, @value, anything()]
      expected_label_render_arguments = [@object, @attribute, @label, hash_including(:for => "#{@object_name}_#{@attribute}_#{@value}".downcase, :object => @object)]
      render_radio_button(expected_label_render_arguments, expected_radio_render_arguments)
    end

    it "passes items associated to the :label options directly through to the label rendering" do
      label_options = {:testing_option_for_label => "passed successfully"}
      expected_radio_render_arguments = [@object, @attribute, @value, anything()]
      expected_label_render_arguments = [@object, @attribute, @label, hash_including(label_options)]
      render_radio_button(expected_label_render_arguments, expected_radio_render_arguments, @default_passed_in_args.push(:label => label_options))
    end
  end

  context "rendering a label" do
    context "by passing in a Hash" do
      before(:each) do
        @key            = :were_accepted
        @text           = "I accept the terms"
        @hash_or_string = {@key => @text}
      end

      it "renders the first key returned as the label text" do
        @template.should_receive(:label).with(@object, :accepted_terms, @text, :object => @object_name).and_return(lambda {"Rendered label input tag"})
        @builder.label(:accepted_terms, @hash_or_string)
      end
    end

    context "by passing in a String" do
      before(:each) do
        @hash_or_string = "I accept"
      end

      it "renders the supplied string as the label text" do
        @template.should_receive(:label).with(@object, :accepted_terms, @hash_or_string, :object => @object_name).and_return(lambda {"Rendered label input tag"})
        @builder.label(:accepted_terms, @hash_or_string)
      end
    end
  end

  context "rendering a form title" do
    it "passes the supplied string as 'title'" do
      custom_title = mock("Custom title")
      @template.should_receive(:render).with(:partial => "form_templates/form_title",
                                             :locals => {:title => custom_title}).and_return(lambda {"Rendered form title"})
      @builder.title(custom_title).should_not raise_error
    end
  end

  context "rendering a form subtitle" do
    it "passes the supplied string as 'subtitle'" do
      custom_subtitle = mock("Custom subtitle")
      @template.should_receive(:render).with(:partial => "form_templates/form_subtitle",
                                             :locals => {:subtitle => custom_subtitle}).and_return(lambda {"Rendered form subtitle"})
      @builder.subtitle(custom_subtitle).should_not raise_error
    end
  end
end
