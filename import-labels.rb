#!/usr/bin/env ruby

require_relative 'setup'

require 'fileutils'
require 'json'

if ARGV.size != 2 then
  $stderr.puts 'import-labels.rb user/repo issues.json'
  exit 1
end

project, path = ARGV

labels_to_add = {}
File.open(path, 'r') do |fd|
  JSON.parse(fd.read).each do |label|
    labels_to_add[label['name']] = {
      color: label['color'],
      description: label['description']
    }
  end
end

preview_header = { accept: 'application/vnd.github.symmetra-preview+json' }
client = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
client.auto_paginate = true

client.labels(project, preview_header).each do |label|
  label_to_update = labels_to_add.delete(label[:name])
  if label_to_update && (label_to_update[:color] != label[:color] || label_to_update[:description] != label[:description]) then
    puts "update #{label[:name]}"
    client.update_label(project, label[:name], label_to_update.merge(preview_header))
  end
end

labels_to_add.each do |(name, label)|
  extra = preview_header.merge(description: label[:description])
  puts "add #{name}"
  client.add_label(project, name, label[:color], extra)
end

