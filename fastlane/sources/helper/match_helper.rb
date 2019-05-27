def rsb_match_for_type(options)
  match_git_url = ENV['MATCH_GIT_URL']
  match_git_branch = ENV['MATCH_GIT_BRANCH']

  if !match_git_url || !match_git_branch
    UI.user_error!('You need to configure the match environments: MATCH_GIT_URL, MATCH_GIT_BRANCH')
  end

  app_identifier = options[:app_identifier]
  type = options[:type]
  force = options[:force]
  readonly = options[:readonly]
  clone_directly = options[:clone_directly]

  match(
    type: type,
    app_identifier: app_identifier,
    force: force,
    readonly: readonly,
    skip_docs: true,
    clone_branch_directly: clone_directly,
    shallow_clone: true
  )
end
