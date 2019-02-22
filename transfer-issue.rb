#!/usr/bin/env ruby

require_relative 'setup'
require 'json'

if ARGV.size < 3 then
  $stderr.puts 'transfer-issue.rb from_repo to_repo number...'
  exit 1
end

from_repo, to_repo = ARGV

client = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])

ARGV[2..-1].each do |from_number|
  issue = client.issue(from_repo, from_number)

  transfered = client.create_issue(
    to_repo,
    issue['title'],
    issue['body'],
    assignees: issue['assignees'].map {|u| u['login']},
    labels: issue['labels'].map {|l| l['name']}.join(","),
    accept: 'application/vnd.github.symmetra-preview+json'
  )

  puts "transfered #{issue['html_url']} to #{transfered['html_url']}"

  client.add_comment(
    from_repo,
    from_number,
    "transfered to #{transfered['html_url']}"
  )
  client.close_issue(
    from_repo,
    from_number
  )
end
