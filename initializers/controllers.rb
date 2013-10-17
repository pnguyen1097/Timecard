module Initializers
  module Controllers
    def self.included(base)
      puts "Loading controllers"
      Dir['./controllers/*'].each do |file|
        unless file.to_s[-2..-1] != 'rb'
          puts file.to_s
          require file
        end
      end
    end
  end
end
