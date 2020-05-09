#!/usr/bin/env ruby

require_relative 'setup'

if ARGV.size != 2 then
  $stderr.puts 'export-thread.rb user/repo number'
  exit 1
end

def normalize(text)
  if text
    text.gsub(/\r\n?/, "\n")
  else
    ''
  end
end

repo, number = ARGV

client = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
client.auto_paginate = true

issue = client.issue(repo, number)
comments = client.issue_comments(repo, number)

md_out = []
md_out << "# #{issue['title']}"
md_out << ''
md_out << "<#{issue['html_url']}>"
if issue['body']
  md_out << ''
  md_out << normalize(issue['body'])
end

comments.each do |c|
  md_out << ''
  md_out << '---'
  md_out << "**@#{c['user']['login']}** at [#{c['created_at']}](#{c['html_url']})"
  md_out << ''
  md_out << normalize(c['body'])
end

puts md_out.join("\n")
