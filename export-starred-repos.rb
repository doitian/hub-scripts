#!/usr/bin/env ruby

require_relative 'graphql-setup'

require 'csv'

StarsQuery = GitHubGraphQL::Client.parse <<-GRAPHQL
query($login: String!, $after: String) {
  user(login: $login) {
    starredRepositories(first: 50, after: $after) {
      edges {
        starredAt
        node {
          nameWithOwner
          url
          description
          primaryLanguage {
            name
          }
          repositoryTopics(first: 20) {
            nodes {
              topic {
                name
              }
            }
          }
        }
      }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
  }
}
GRAPHQL

if ARGV.size == 0 then
  user = 'doitian'
else
  user = ARGV[0]
end

out_dir = "out/#{user}"
FileUtils.mkdir_p(out_dir)

csv_name = "#{out_dir}/starred.csv"
puts "create #{csv_name}"
CSV.open(csv_name, 'wb') do |csv|
  csv << %w(url folder title description tags created)

  has_next_page = true
  end_cursor = nil
  while has_next_page
    result = GitHubGraphQL::Client.query(StarsQuery, variables: {login: user, after: end_cursor})
    starred_repositories = result.data.user.starred_repositories
    has_next_page = starred_repositories.page_info.has_next_page
    end_cursor = starred_repositories.page_info.end_cursor

    starred_repositories.edges.each do |edge|
      repo = edge.node
      puts "  #{repo.name_with_owner}"
      tags = repo.repository_topics.nodes.map {|n| n.topic.name}
      if !repo.primary_language.nil? && !tags.include?(repo.primary_language.name)
        tags = [repo.primary_language.name] + tags
      end
      csv << [ repo.url, 'GitHub Stars', repo.name_with_owner, repo.description, tags.join(','), edge.starred_at ]
    end
  end
end
