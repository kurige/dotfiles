#!/usr/bin/env ruby
# encoding: utf-8

require 'rexml/document'
require 'net/http'

def current(location, f_or_c)
  response = Net::HTTP.get_response(URI.parse(URI.escape("http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=#{location}")))
  doc = REXML::Document.new(response.body)
  obs = doc.elements['current_observation'].elements
  temp = f_or_c === 'f' ? obs['temp_f'].text : obs['temp_c'].text
  text = obs['weather'].text

  return "#{text}\t#{temp}"
end

print current(ARGV[0], ARGV[1])
