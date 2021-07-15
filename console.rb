#!/usr/bin/env ruby

require_relative 'setup'

$github = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])

require 'pry'
Pry.start
