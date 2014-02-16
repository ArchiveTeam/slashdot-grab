#!/usr/bin/env ruby

require 'celluloid'
require 'connection_pool'
require 'mechanize'
require 'uri'

# For each story in the input list, find its SID.


WORKERS = 4
AGENT = ConnectionPool.new(:size => WORKERS) do
  Mechanize.new do |m|
    m.user_agent_alias = 'Linux Firefox'
  end
end

class Retriever
  include Celluloid

  def go(url)
    AGENT.with do |agent|
      agent.request_headers = { 'Cookie' => 'betagroup=34; mobileordesktop=desktop' }
      page = agent.get(url)

      # The discussion ID on D2 (which is what we'll get as an anonymous user on betagroup 34) is in a Javascript call of the form
      #
      # D2.discussion_id(THE_ID);
      #
      # Pull it out.
      page.body =~ /D2\.discussion_id\((\d+)\);/
      sid = $1
  
      "#{url}\t#{sid}"
    end
  end
end

R = Retriever.pool(:size => WORKERS)

futures = $stdin.read.split("\n").map { |url| R.future(:go, url) }

futures.map { |f| puts f.value }
