require_relative '../helper/string_exts_helper.rb'

def remote_branch_exists?(branch)
  result = `git branch -a | egrep 'remotes/origin/#{branch}' |  wc -l`  
  result.strip.to_bool
end

def rsb_git_checkout(branch)
    sh('git checkout ' + branch)
end

def delete_remote_branch(origin, branch)
    sh('git push ' + origin + ' --delete ' + branch)
end

def rsb_git_pull
  sh('git pull')
end

def rsb_git_push(tags: false)
  sh('git push')
  if tags
	  sh('git push --tags')
  end
end

def rsb_add_git_tag(name)
  sh("git tag #{name}")
end

def rsb_current_git_branch
  return sh('git rev-parse --abbrev-ref HEAD').gsub("\n", "")
end