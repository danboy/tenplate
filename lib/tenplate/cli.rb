require 'rubygems'
require 'highline/import'
require 'ftools'

module Tenplate
  class CLI
    def self.execute(stdout, arguments=[])
      source_dir = File.expand_path(File.dirname(__FILE__) + "/../templates/sass")
      destination_dir = File.expand_path("./public/stylesheets/sass")

      Dir.mkdir(destination_dir) unless File.exist?(destination_dir)

      # Add public/stylesheets/sass directory and symlink to included SASS files
      Dir.open(source_dir).each do |f|
        next if f == ".." || f == "."
        File.safe_unlink("#{destination_dir}/#{f}") if File.symlink?("#{destination_dir}/#{f}")

        if File.exist?("#{destination_dir}/#{f}") && agree("'#{f}' already exists in '#{destination_dir}'. Do you want to delete it? ")
          File.delete("#{destination_dir}/#{f}")
        end
        File.symlink("#{source_dir}/#{f}", "#{destination_dir}/#{f}")
      end
      puts "Your sass has been tenplated..."
    end
  end
end
