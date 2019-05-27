require_relative '../helper/git_helper.rb'

private_lane :rsb_trigger_ci_fastlane do |options|
  fabric = !!options[:fabric]
  testflight = !!options[:testflight]
  git_flow = options[:git_flow]
  git_flow = true if git_flow == nil
  git_build_branch = options[:git_build_branch]
  git_build_branch = rsb_current_git_branch if git_build_branch == nil

  app_token = ENV['CI_APP_TOKEN']
  app_name = ENV['CI_APP_NAME']  
  jenkins_user = ENV['CI_JENKINS_USER']
  jenkins_user_token = ENV['CI_JENKINS_USER_TOKEN']
  domain = ENV['CI_DOMAIN']
  if domain.nil?
      domain = 'cis.local:9090'
  end

  if git_flow
    git_build_branch = 'develop'
  end
  
  rsb_git_checkout(git_build_branch)
  rsb_git_pull
  rsb_git_push

  url = 'http://' + jenkins_user + ':' + jenkins_user_token + '@' + domain + '/job/' + app_name + '/buildWithParameters?token=' + app_token
  url += "&fabric=#{fabric}" + "&testflight=#{testflight}" + "&git_flow=#{git_flow}" + '&git_build_branch=' + git_build_branch
  sh('curl -X GET ' + '"' + url + '"')
end

def rsb_possible_to_trigger_ci_build?
  ENV['CI_APP_TOKEN'] && ENV['CI_APP_NAME'] && !is_ci?
end