
module Initializers
  module Models
    puts "Loading models"

    DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/dev.db")

    Dir['./models/*'].each do |file|
      unless file.to_s[-2..-1] != 'rb'
        puts file.to_s
        require file
      end
    end

    DataMapper.auto_upgrade!

    # seed the database
    load "#{File.dirname(__FILE__)}/seeds.rb"
  end
end
