require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe TenplateFormBuilder do
  before(:each) do
    @object = mock("A Person object")
    @object_name = :person
    @template = mock("View template object")
    @builder = TenplateFormBuilder.new @object, @object_name, @template, {}, nil
  end

  def check_options_full validations = {}
    expected_render_arguments = hash_including(:partial => @partial_file_path, :locals => hash_including(validations[:expected]))
    @template.should_receive(:render).with(expected_render_arguments).and_return(lambda {"Template rendered"})
    render_item(@field_name_or_items, validations[:passed_in])
  end

  def check_options_same values = {}
    check_options_full :passed_in => values, :expected => values
  end

  def testing_option(input_name, output_name = input_name)
    @input_name = input_name
    @output_name = output_name
  end

  context "rendering a checkbox" do
    before(:each) do
      @partial_file_path = "form_templates/check_box"
      @field_name_or_items = :accepted_terms
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

    context "by calling 'checkbox_tag'" do
      def render_item(field, options = {})
        @builder.check_box_tag(field, options).should_not raise_error
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
            render_item(:accepted_terms)
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

        context "setting 'label_text'" do
          before(:each) {testing_option :label, :label_text}
          it_should_behave_like "Any customizable option"
        end

        context "setting 'label_for'" do
          before(:each) {testing_option :label_for}
          it_should_behave_like "Any customizable option"
        end


        context "setting 'options'" do
          supported_attributes = [:disabled, :size, :alt, :tabindex, :accesskey, :onfocus, :onblur, :onselect, :onchange]

          it "removes all invalid attributes for the 'checkbox' input type" do
            bad_attributes = {:disbled => true, :label => :text_label, :bad_tag => :bad_data}
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

    context "by calling 'checkbox'" do
      def render_item(field, options)
        @builder.check_box(field, options).should_not raise_error
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

      context 'with options passed in' do
        [:label_for, :checked_value, :unchecked_value].each do |option_name|
          context "setting '#{option_name.to_s}'" do
            before(:each) {testing_option option_name}
            it_should_behave_like "Any customizable option"
          end
        end

        context "setting 'label'" do
          before(:each) {testing_option :label, :label_text}
          it_should_behave_like "Any customizable option"
        end

        context "setting 'scoped_by_object'" do
          it "is ignored and always set to true" do
            check_options_full :passed_in => {:scoped_by_object => false}, :expected => {:scoped_by_object => true}
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
            bad_attributes = {:disbled => true, :label => :text_label, :bad_tag => :bad_data}
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
  end

  context "rendering a group of 'checkbox' items" do
    def render_item(field, options = {})
      @builder.check_box_group(field, options).should_not raise_error
    end

    before(:each) do
      @field_name_or_items = mock("Collection of items to render with checkboxes", :size => 1, :each => [])
      @partial_file_path = "form_templates/check_box_group"
    end

    it_should_behave_like "Any item rendered using the TenplateFormBuilder"

    it "passes the array of items supplied directly through as 'items'" do
      expected_render_arguments = hash_including(:partial => "form_templates/check_box_group", :locals => hash_including(:items => @field_name_or_items))
      @template.should_receive(:render).with(expected_render_arguments).and_return(lambda {"Template rendered"})
      render_item(@field_name_or_items)
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
          render_item(@field_name_or_items)
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

  context "rendering a label" do
    context "by passing in a Hash" do
      before(:each) do
        @hash_or_string = {:were_accepted => "I accept the terms"}
      end

      it "renders the first key returned as the label text" do
        @template.should_receive(:label).with(@object, :accepted_terms, :were_accepted, :object => @object_name).and_return(lambda {"Rendered label input tag"})
        @builder.label(:accepted_terms, @hash_or_string)
      end
    end

    context "by passing in a String" do
      before(:each) do
        @hash_or_string = "I accpeet"
      end

      it "renders the supplied string as the label text" do
        @template.should_receive(:label).with(@object, :accepted_terms, @hash_or_string, :object => @object_name).and_return(lambda {"Rendered label input tag"})
        @builder.label(:accepted_terms, @hash_or_string)
      end
    end
  end
end
