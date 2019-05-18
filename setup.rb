Dir.chdir(File.dirname(__FILE__)) do
  require 'bundler/setup'
  require 'dotenv/load'
end
require 'octokit'
