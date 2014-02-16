#!/usr/bin/env ruby

require 'mechanize'
require 'uri'

agent = Mechanize.new do |m|
  m.user_agent_alias = 'Linux Firefox'
end

years = (1998..2014)

years.each do |year|
  $stderr.puts "Retrieving stories for #{year}"

  page = agent.get("http://slashdot.org/archive.pl?op=bytime&year=#{year}")
  links = page.links.select { |l| l.href =~ %r{/story/} }

  links.map { |l| URI(l.href).tap { |u| u.scheme = 'http' }.to_s }.each { |href| puts href }
end
