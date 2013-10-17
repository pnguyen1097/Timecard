puts "Loading initializers"
module Initializers

  [ "extensions", "assets", "auth", "models", "controllers" ].each do |file|
    require "#{File.dirname(__FILE__)}/#{file}"
  end

  def self.included(base)

    # grab all of the modules nested under Initializers
    submodules = constants.collect do |const_name|
      const_get(const_name)
    end.select do |const| const.class == Module
    end

    # automatically include those submodules when Initializers
    # is included
    submodules.each do |submodule|
      base.send :include, submodule
    end
  end

end
