#!/usr/bin/env ruby

require_relative 'setup'
require 'json'

if ARGV.size != 1 then
  $stderr.puts 'batch-cards.rb cards.json'
  exit 1
end

path = ARGV.first

preview_header = { accept: 'application/vnd.github.inertia-preview+json' }
client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])

File.open(path, 'r') do |fd|
  JSON.parse(fd.read).each_pair do |(col_id, notes)|
    if col_id.to_i.to_s == col_id
      notes.each do |note|
        puts "create: #{note.lines.first}"
        if note.is_a?(Integer) then
          client.create_project_card(col_id.to_i, preview_header.merge(content_id: note.to_i, content_type: 'Issue'))
        else
          client.create_project_card(col_id.to_i, preview_header.merge(note: note))
        end
      end
    end
  end
end
