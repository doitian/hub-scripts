#!/usr/bin/env ruby

require_relative 'setup'

require 'fileutils'
require 'json'

if ARGV.size == 0 then
  $stderr.puts 'export-labels.rb user/repo'
  exit 1
end

project = ARGV[0]

out_dir = "out/#{project}"
FileUtils.mkdir_p(out_dir)

preview_header = { accept: 'application/vnd.github.symmetra-preview+json' }
client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
client.auto_paginate = true
labels = client.labels(project, preview_header).map do |label|
  {
    name: label.name,
    color: label.color,
    description: label.description
  }
end

File.open("#{out_dir}/labels.json", 'w') do |fd|
  fd.write(JSON.pretty_generate(labels))
end
