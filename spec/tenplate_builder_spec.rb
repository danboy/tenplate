require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe TenplateFormBuilder do
  before(:each) do
    @object = mock("A Person object")
    @object_name = :person
    @template = mock("View template object")
    @builder = TenplateFormBuilder.new @object, @object_name, @template, {}, nil
  end

   context 'rendering a checkbox tag' do
     def check_options_full validations = {} 
       render_arguments = hash_including(:partial=>"form_templates/check_box", :locals => hash_including(validations[:expected]))
       @template.should_receive(:render).with(render_arguments).and_return(lambda {"Template rendered"})
       @builder.check_box_tag(:accepted_terms, validations[:passed_in]).should_not raise_error
     end
     def check_options_same values = {}
       check_options_full :passed_in => values, :expected => values
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
        it "passes a 'selected_state' of true when given true" do
          check_options_full :passed_in => {:selected => true}, :expected => {:selected_state => true}
        end
        it "passes a 'selected_state' of false when given false" do
          check_options_full :passed_in => {:selected => false}, :expected => {:selected_state => false}
        end
        it "passes a 'selected_state' of false when given a non-boolean value" do
          check_options_full :passed_in => {:selected => "3232"}, :expected => {:selected_state => false}
        end
      end
      context "setting 'scoped_by_object'" do
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
end

