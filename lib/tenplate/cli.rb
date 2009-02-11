require 'rubygems'
require 'highline/import'
require 'ftools'

module Tenplate
  class CLI
    def self.execute(stdout, arguments=[])
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
      puts "Your sass has been tenplated..."
    end

    private
      def self.deletion_confirmed?(file)
        agree("'#{file}' already exists. Do you want to delete it? ")
      end
  end
end
