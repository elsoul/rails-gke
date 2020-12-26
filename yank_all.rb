#!/usr/bin/env ruby
# encoding: UTF-8

require'json'
def yank
    gemname = (ARGV.index('-g') && ARGV[ARGV.index('-g') + 1]) || (puts('Please enter gem name:') || gets.strip)
    data = JSON.parse `curl -s https://rubygems.org/api/v1/versions/#{gemname}.json`
    versions = data.map {|v| v['number']} .reverse
    puts "\n\n#{gemname} versions: #{versions.join ', '}"
    puts "\nHow many versions to yank (starting at the first release) (none/ALL/number)?"

    case (answer = gets.strip)
    when /ALL/
        puts "Yanking ALL versions!"
        versions.each {|v| puts `gem yank #{gemname} -v #{v}`;sleep 30 }
    when /^[\-\d]+$/
        versions = versions[0...answer.to_i]
        puts "Yanking versions: #{versions.join ', '}"
        versions.each {|v| puts `gem yank #{gemname} -v #{v}` }
    else
        puts "No action was performed"
    end 
end

yank