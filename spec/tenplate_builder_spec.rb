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
    context 'with no options passed in' do

               #:locals => {:name => name,
                               #:checked_value => checked_value,
                               #:unchecked_value => unchecked_value,
                               #:checked_or_not => checked_or_not,
                               #:is_scoped_by_object => false,
                               #:label_text => options.delete(:label),
                               #:label_for => options.delete(:label_for) || name,
                               #:builder => self,
                               #:is_part_of_group => options.delete(:is_part_of_group),
                               #:options => options}

      {:name => :first_name,
      :checked_value => '1',
      :unchecked_value => '0',
      :is_scoped_by_object => false,
      :label_text => 'First Name',
      :label_for => :first_name,
      :is_part_of_group => false,
      :options => {}
      }.each_pair do |key, value|
        it "should render the checkbox view template with '#{key}' set to '#{value}'"  do
          render_arguments = hash_including(:partial=>"form_templates/check_box", :locals => hash_including(key => value))
          @template.should_receive(:render).with(render_arguments).and_return(lambda {"Template rendered"})
          @builder.check_box_tag(:first_name).should_not raise_error
        end
      end
    end
  end
end

