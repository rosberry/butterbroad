require_relative '../helper/plist_helper.rb'
require_relative '../helper/git_helper.rb'

# Start release branch.
private_lane :rsb_start_release_branch do |options|
  name = options[:name]
  
  if ffreezing? == true
    sh('git checkout master')    
  else
    sh('git checkout develop')
  end

  $checkout_branch = rsb_current_git_branch
  sh("git checkout -b release/#{name}")
end

# Close release branch.
private_lane :rsb_end_release_branch do |options|
  name = options[:name]

  sh('git checkout develop')
  sh('git pull')
  sh("git merge release/#{name} --no-ff --no-edit")
  sh('git push')

  sh('git checkout master')
  sh('git pull')
  sh("git merge release/#{name} --no-ff --no-edit")
  sh('git push')

  sh("git branch -d release/#{name}")

  checkout_needed_branch_after_completion
end

# Remove release branch if error occurs.
private_lane :rsb_remove_release_branch do |options|
  name = options[:name]
  checkout_needed_branch_after_completion
  sh("git branch -D release/#{name}")
end

def checkout_needed_branch_after_completion
  sh("git checkout #{$checkout_branch}")
end

# Start hotfix branch.
private_lane :rsb_start_hotfix_branch do |options|
  name = options[:name]
  hotfix = "hotfix/#{name}"
  branches = sh('git branch')
  if branches.include? hotfix
    sh("git checkout #{hotfix}")
  else
    remote_branches = sh('git ls-remote --heads')
    if remote_branches.include? hotfix
      sh("git branch #{hotfix} origin/#{hotfix}")
      sh("git checkout #{hotfix}")
    else
      sh('git checkout master')
      sh("git checkout -b #{hotfix}")   
    end
  end
end

private_lane :rsb_finish_hotfix_branch do |options| 
  name = options[:name]
  hotfix = "hotfix/#{name}"
  
  sh('git checkout develop')
  sh('git pull')
  sh("git merge #{hotfix} --no-ff --no-edit")
  sh('git push')

  sh('git checkout master')
  sh('git pull')
  sh("git merge #{hotfix} --no-ff --no-edit")
  sh('git push')

  sh("git branch -D #{hotfix}")

  if remote_branch_exists? hotfix
    sh("git push --delete origin #{hotfix}")
  end
end

# Delete hotfix branch.
private_lane :rsb_delete_hotfix_branch do |options| 
  name = options[:name]
  hotfix = "hotfix/#{name}"
  
  sh('git checkout develop')
  sh("git branch -D #{hotfix}")

  if remote_branch_exists? hotfix
    sh("git push --delete origin #{hotfix}")
  end
end

# Start feature branch.
private_lane :rsb_start_feature_branch do |options| 
  name = options[:name]
  feature = "feature/#{name}"

  branches = sh('git branch')
  if branches.include? feature
    sh("git checkout #{feature}")
  else
    remote_branches = sh('git ls-remote --heads')
    if remote_branches.include? feature
      sh("git branch #{feature} origin/#{feature}")
      sh("git checkout #{feature}")
    else
      sh('git checkout develop')
      sh("git checkout -b #{feature}")
    end
  end
end

# End feature branch.
private_lane :rsb_finish_feature_branch do |options| 
  name = options[:name]
  feature = "feature/#{name}"
  
  sh('git checkout develop')
  sh('git pull')
  sh("git merge #{feature} --no-ff --no-edit")
  sh('git push')

  sh("git branch -D #{feature}")
end

# Push feature branch.
private_lane :rsb_push_feature_branch do |options| 
  name = options[:name]
  feature = "feature/#{name}"
  
  sh("git checkout #{feature}")
  sh("git push -u origin #{feature}")
end

def rsb_git_tag_build_prefix
  prefix = ENV['GIT_TAG_BUILD_PREFIX']
  if prefix
    return "#{prefix}-"
  end
  return ""
end

def rsb_hotfix_branch_name(ticket)
  ticket.key
end

def rsb_release_branch_name(testflight)
  prefix = rsb_git_tag_build_prefix
  if testflight
    name = "#{prefix}rc-#{app_version}-#{build_number}"
  else
    name = "#{prefix}build-#{app_version}-#{build_number}" 
  end
  return name
end

def rsb_feature_branch_name(ticket)  
  if ENV['GIT_FEATURE_MANUAL_NAMING'] == 'true'
    name = prompt(
      text: 'Enter feature name: '
    )
  else 
    name = ticket.summary
  end
    name = name.downcase.tr("'&. /~:^\\", '-')
    "#{ticket.key}-#{name}"
end

def rsb_search_feature_branch_name(ticket)  
  if ENV['GIT_FEATURE_MANUAL_NAMING'] == 'true'
    branches_string = sh('git branch')
    branches = branches_string.split($/)
    name = branches.find {|branch| branch.include? "#{ticket.key}"}
    name = name.gsub('feature/','').gsub('* ','') if name
  else 
    name = rsb_feature_branch_name(ticket)
  end
  name
end