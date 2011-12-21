require 'rubygems'
require 'highline/import'
require 'ftools'

module Tenplate
  class UnsupportedProjectType < StandardError; end

  class CLI
    def self.execute(stdout, arguments=[])
      install_sass_templates

      # Form builder stuff
      source_dir = File.expand_path(File.dirname(__FILE__) + "/../templates/form_builder/form_templates")
      destination_dir = File.expand_path("./app/views")

      unless File.exist?(destination_dir)
        raise UnsupportedProjectType, "Rails projects are the only supported project-type at this time. Exiting."
      end
      destination_dir << "/form_templates"
      Dir.mkdir(destination_dir) unless File.exist?(destination_dir)

      question_text = "Do you want to copy or symlink the form builder files into your project? [c/s]: "
      copy_or_symlink = ask(question_text, lambda {|answer| answer.match(/^s/i) ? :symlink : :copy }) do |response|
        response.validate = /^[csCS]/
      end

      # Add app/views/form_templates directory and symlink/copy included template files files
      Dir.open(source_dir).each do |f|
        destination_path = "#{destination_dir}/#{f}"
        source_path      = "#{source_dir}/#{f}"

        next if f == ".." || f == "."
        File.safe_unlink(destination_path) if File.symlink?(destination_path)

        if File.exists?(destination_path) && deletion_confirmed?(destination_path)
          File.delete(destination_path)
        end
        File.send(copy_or_symlink, source_path, destination_path)
      end

      # Now copy the form builder to './lib'
      # Yes...this needs to be cleaned up...a lot...just like the rest of the file
      destination_dir = File.expand_path("./lib")

      unless File.exist?(destination_dir)
        raise UnsupportedProjectType, "Rails projects are the only supported project-type at this time. Exiting."
      end

      destination_path = "#{destination_dir}/tenplate_form_builder.rb"
      source_path = File.expand_path(File.dirname(__FILE__) + "/../templates/form_builder/tenplate_form_builder.rb")
      File.safe_unlink(destination_path) if File.symlink?(destination_path)

      if File.exists?(destination_path) && deletion_confirmed?(destination_path)
        File.delete(destination_path)
      end
      File.send(copy_or_symlink, source_path, destination_path)

      form_builder_instructions =<<-MESSAGE_ENDING

#################### NOTE ####################
To simplify use of the form builder, add the following to your
application_helper.rb file:

  def tenplate_form_for(record_or_name_or_array, *args, &proc)
    options = args.detect {|argument| argument.is_a?(Hash)}
    if options.nil?
      options = {:builder => TenplateFormBuilder}
      args << options
    end
    options[:builder] = TenplateFormBuilder unless options.nil?

    form_for(record_or_name_or_array, *args, &proc)
  end

Then call in your views like so:
- tenplate_form_for [...standard form syntax here] do |f|
  f.text_field :attribute
  ...etc

      MESSAGE_ENDING

      puts form_builder_instructions
      ask("Press enter to continue... ")

      puts "\n\n"
      say "Your sass has been tenplated..."
    end

    private
      def self.deletion_confirmed?(file)
        agree("'#{file}' already exists. Do you want to delete it? ")
      end

      def self.install_sass_templates
        source_dir = File.expand_path(File.dirname(__FILE__) + "/../templates/sass")
        destination_dir = File.expand_path("./public/stylesheets/sass")

        Dir.mkdir(destination_dir) unless File.exist?(destination_dir)

        question_text = "Do you want to copy or symlink the tenplate sass files? [c/s]: "
        copy_or_symlink = ask(question_text, lambda {|answer| answer.match(/^s/i) ? :symlink : :copy }) do |response|
          response.validate = /^[csCS]/
        end

        # Add public/stylesheets/sass directory and symlink to included SASS files
        Dir.open(source_dir).each do |f|
          destination_path = "#{destination_dir}/#{f}"
          source_path      = "#{source_dir}/#{f}"

          next if f == ".." || f == "."
          File.safe_unlink(destination_path) if File.symlink?(destination_path)

          if File.exists?(destination_path) && deletion_confirmed?(destination_path)
            File.delete(destination_path)
          end
          File.send(copy_or_symlink, source_path, destination_path)
        end
      end
  end
end
