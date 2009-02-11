dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

require 'tenplate/cli'

module Tenplate
  # Returns the path of file relative to the Tenplate root.
  def self.scope(file) # :nodoc:
    File.join(File.dirname(__FILE__), '..', file)
  end
end
