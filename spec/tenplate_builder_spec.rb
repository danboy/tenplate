require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe TenplateFormBuilder do
  before(:each) do
    @object = mock("A Person object")
    @object_name = :person
    @template = mock("View template object")
    @builder = TenplateFormBuilder.new @object, @object_name, @template, {}, nil
  end

  context "rendering a checkbox" do
    def check_options_full validations = {}
      expected_render_arguments = hash_including(:partial=>"form_templates/check_box", :locals => hash_including(validations[:expected]))
      @template.should_receive(:render).with(expected_render_arguments).and_return(lambda {"Template rendered"})
      render_item(:accepted_terms, validations[:passed_in])
    end

    def check_options_same values = {}
      check_options_full :passed_in => values, :expected => values
    end

    def testing_field(input_name, output_name = input_name)
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
        check_options_full :passed_in => {@input_name => "3232"}, :expected => {@output_name => false}
      end
    end


    context "by calling 'checkbox_tag'" do
      def render_item(field_name, options)
        @builder.check_box_tag(field_name, options).should_not raise_error
      end

      context 'with no options passed in' do
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
            expected_render_arguments = hash_including(:partial=>"form_templates/check_box", :locals => hash_including(key => value))
            @template.should_receive(:render).with(expected_render_arguments).and_return(lambda {"Template rendered"})
            @builder.check_box_tag(:accepted_terms).should_not raise_error
          end
        end

        it "renders the checkbox view template with the checkbox being in an 'unselected' state" do
            check_options_full :passed_in => {}, :expected => {:selected_state => false}
        end
        it "passes a reference to the TenplateFormBuilder" do
           check_options_full :passed_in => {}, :expected => {:builder => @builder}
        end
      end

      context 'with options passed in' do
        context "setting 'checked_value'" do
          it "passes the value supplied if specified" do
            check_options_same :unchecked_value => "323"
          end
        end
        context "setting 'unchecked_value'" do
          it "passes the value supplied if specified" do
            check_options_same :checked_value => "323"
          end
        end
        context "setting 'part_of_group'" do
          it "passes true for true" do
            check_options_same :part_of_group => true
          end

          it "passes false for false" do
            check_options_same :part_of_group => false
          end

          it "passes false a non-boolean value" do
            check_options_full :passed_in => {:part_of_group => "3232"}, :expected => {:part_of_group => false}
          end
        end
        context "setting 'selected'" do
          before(:each) do
            testing_field :selected, :selected_state
          end
          it_should_behave_like "Any boolean option"
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
          it "passes the specified value when supplied" do
            supplied_value = "Accepted T & C"
            check_options_full :expected => {:label_text => supplied_value}, :passed_in => {:label => supplied_value}
          end
        end
        context "setting 'label_for'" do
          it "passes the specified value when supplied" do
            check_options_same :label_for => :manually_specified_field_name
          end
        end
        context "setting 'builder'" do
          it "passes a reference to the TenplateFormBuilder" do
            check_options_full :passed_in => {:builder => mock("Some Other Builder Type")}, :expected => {:builder => @builder}
          end
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
      def render_item(field_name, options)
        @builder.check_box(field_name, options).should_not raise_error
      end

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
            expected_render_arguments = hash_including(:partial=>"form_templates/check_box", :locals => hash_including(key => value))
            @template.should_receive(:render).with(expected_render_arguments).and_return(lambda {"Template rendered"})
            @builder.check_box(:accepted_terms).should_not raise_error
          end
        end

        it "renders the checkbox view template with 'object_name' being set to the object referenced in the builder"  do
          check_options_full :passed_in => {}, :expected => {:object_name => @object}
        end

        it "passes a reference to the TenplateFormBuilder" do
           check_options_full :passed_in => {}, :expected => {:builder => @builder}
        end
      end

      context 'with options passed in' do
        [:label_for, :checked_value, :unchecked_value].each do |attribute_name|
          context "setting '#{attribute_name.to_s}'" do
            it "passes the specified value straight through to view template" do
              specified_value = mock("Manually Specified Value")
              check_options_same attribute_name => specified_value
            end
          end
        end

        context "setting 'scoped_by_object'" do
          it "is ignored and always set to true" do
            check_options_full :passed_in => {:scoped_by_object => false}, :expected => {:scoped_by_object => true}
          end
        end

        context "setting 'label'" do
          it "passes the specified value as 'label_text' to the template" do
            specified_value = "A Different Label"
            check_options_full :passed_in => {:label => specified_value}, :expected => {:label_text => specified_value}
          end
        end

        context "setting 'selected'" do
          it_should_behave_like "Any boolean option"
          before(:each) do
            testing_field :selected, :selected_state
          end
        end

        context "setting 'part_of_group'" do
          before(:each) do
            testing_field :part_of_group
          end
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

        it "passes a reference to the TenplateFormBuilder" do
           check_options_full :passed_in => {}, :expected => {:builder => @builder}
        end
      end
    end
  end
end

