#!/usr/bin/env ruby

require_relative 'graphql-setup'

if ARGV.size == 2
  repo, pattern = ARGV
  enforce_admins = nil
elsif ARGV.size == 3
  repo, pattern, on_off = ARGV
  enforce_admins = on_off == 'on'
else
  $stderr.puts 'enforce-admins.rb repo pattern [on|off]'
  exit 1
end

repo_owner, repo_name = repo.split('/')

BranchProtectionRulesQuery = GitHubGraphQL::Client.parse <<-GRAPHQL
query($name: String!, $owner: String!) {
  repository(name: $name, owner: $owner) {
    branchProtectionRules(first: 100) {
      nodes {
        id
        pattern
        isAdminEnforced
      }
    }
  }
}
GRAPHQL

EnforceAdminsMutation = GitHubGraphQL::Client.parse <<-GRAPHQL
mutation($id: ID!, $enforce: Boolean!) {
  updateBranchProtectionRule(input: {
    branchProtectionRuleId: $id,
    isAdminEnforced: $enforce,
  }) {
    branchProtectionRule {
      id
      pattern
      isAdminEnforced
    }
  }
}
GRAPHQL

rules = GitHubGraphQL::Client.query(
  BranchProtectionRulesQuery,
  variables: {
    name: repo_name,
    owner: repo_owner
  }
).data.repository.branch_protection_rules.nodes

matched_rule = rules.find {|r| r.pattern == pattern}
if matched_rule.nil?
  $stderr.puts "Protection pattern not found, available: #{rules.map(&:pattern).join(', ')}"
end

if !enforce_admins.nil? && enforce_admins != matched_rule.is_admin_enforced
  matched_rule = GitHubGraphQL::Client.query(
    EnforceAdminsMutation,
    variables: {
      id: matched_rule.id,
      enforce: enforce_admins
    }
  ).data.update_branch_protection_rule.branch_protection_rule
end

puts matched_rule.to_h
