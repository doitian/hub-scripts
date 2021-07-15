#!/usr/bin/env ruby

require_relative 'setup'

require 'erb'

preview_header = { accept: 'application/vnd.github.inertia-preview+json' }

if ARGV.size != 2 then
  $stderr.puts 'export-column.rb column template.erb'
  exit 1
end

column_id, template = ARGV

erb = ERB.new(File.open(template).read)

client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
client.auto_paginate = true

column = client.project_column(column_id, preview_header)
project = column.rels[:project].get(headers: preview_header).data
column_url = project['html_url'] + "#column-#{column_id}"

puts "# #{project['name']} / [#{column['name']}](#{column_url})\n"

client.column_cards(column_id, preview_header).each do |card|
  if card.note.nil?
    item_type = 'Issue'
    item = card.rels[:content].get(headers: preview_header).data
  else
    item_type = 'Note'
    item = card
  end
  puts erb.result(binding)
end

