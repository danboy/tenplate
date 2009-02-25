require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe CheckBoxItem do
  it "should accept a symbol for a field name" do
    lambda {CheckBoxItem.new(:first_name)}.should_not raise_error
  end
end

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
       @builder.check_box_tag(:first_name, validations[:passed_in]).should_not raise_error
     end
     def check_options_same values = {}
       check_options_full :passed_in => values, :expected => values
     end

    context 'with no options passed in' do
      {:name => :first_name,
      :checked_value => '1',
      :unchecked_value => '0',
      :is_scoped_by_object => false,
      :label_text => 'First Name',
      :label_for => :first_name,
      :is_part_of_group => false,
      :options => {}
      }.each_pair do |key, value|
        it "renders the checkbox view template with '#{key}' set to '#{value}'"  do
          expected_render_arguments = hash_including(:partial=>"form_templates/check_box", :locals => hash_including(key => value))
          @template.should_receive(:render).with(expected_render_arguments).and_return(lambda {"Template rendered"})
          @builder.check_box_tag(:first_name).should_not raise_error
        end
      end

      it "renders the checkbox view template with the checkbox being in an 'unselected' state" do
        check_options_full :passed_in => {}, :expected => {:selected_state => false}
      end
    end

    context 'with options passed in' do
      context 'setting checked value' do
        it "passes the value supplied if specified" do
          check_options_same :unchecked_value => "323"
        end
      end

      context 'setting unchecked value' do
        it "passes the value supplied if specified" do
          check_options_same :checked_value => "323"
        end
      end

      context 'setting is_part_of_group' do
        it "passes true for true" do
          check_options_same :is_part_of_group => true
        end

        it "passes false for false" do
          check_options_same :is_part_of_group => false
        end

        it "passes false a non-boolean value" do
          check_options_full :passed_in => {:is_part_of_group => "3232"}, :expected => {:is_part_of_group => false}
        end
      end

      context "setting 'selected'" do
        it "passes true for true" do
          check_options_full :passed_in => {:selected => true}, :expected => {:selected_state => true}
        end

        it "passes false for false" do
          check_options_full :passed_in => {:selected => false}, :expected => {:selected_state => false}
        end

        it "passes false a non-boolean value" do
          check_options_full :passed_in => {:selected => "3232"}, :expected => {:selected_state => false}
        end
      end
    end
  end
end

