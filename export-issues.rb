#!/usr/bin/env ruby

require 'date'
require 'fileutils'
require 'csv'
require 'dotenv/load'
require 'octokit'

if ARGV.size == 0 then
  $stderr.puts 'export-issues.rb user/repo'
  exit 1
end

project = ARGV[0]

out_dir = "out/#{project}"
FileUtils.mkdir_p(out_dir)

now = Time.now
last_time_file = "#{out_dir}/issues.time"

client = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
client.auto_paginate = true
if File.exists?(last_time_file) then
  last_time = Time.at(File.read(last_time_file).to_i)
  search_option = { since: last_time.to_datetime.iso8601 }
  csv_name = "#{out_dir}/issues_since_#{search_option[:since].gsub(':', '')}.csv"
else
  search_option = {}
  csv_name = "#{out_dir}/issues.csv"
end

puts "create #{csv_name}"
CSV.open(csv_name, 'wb') do |csv|
  csv << %w(Title Notes Resources)
  client.issues(project, search_option).each do |issue|
    title = "\##{issue['number']} #{issue['title']}"
    assignee = issue['assignee'] && issue['assignee']['login']
    csv << [ title, issue['html_url'], assignee ]
  end
end

File.open(last_time_file, 'w') do |last_time_fd|
  last_time_fd.puts(now.to_i)
end
