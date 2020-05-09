#!/usr/bin/env ruby

require_relative 'setup'

if ARGV.size != 3
  $stderr.puts 'enforce-admins.rb repo branch on|off'
  exit 1
end

class Hash
    def slice(*keys)
      keys.each_with_object(self.class.new) { |k, hash| hash[k] = self[k] if has_key?(k) }
    end
end

repo, branch, on_off = ARGV
enforce_admins = on_off == 'on'

client = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
current = client.branch_protection(repo, branch).to_h

options = {
  enforce_admins: enforce_admins,
  required_status_checks: current[:required_status_checks].slice(:strict, :contexts),
  required_pull_request_reviews: current[:required_pull_request_reviews].slice(:dismissal_restrictions, :dismiss_stale_reviews, :require_code_owner_reviews, :required_approving_review_count)
}

if current[:restrictions]
  options[:restrictions] = {
    users: current[:restrictions][:users].map {|u| u[:login] },
    teams: current[:restrictions][:teams].map {|t| t[:slug] }
  }
end

client.protect_branch(repo, branch, options)
