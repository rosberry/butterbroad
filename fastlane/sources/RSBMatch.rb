desc 'Create all certificates and profiles via match'
lane :rsb_match_init do
  types = %w[appstore development adhoc]
  types.each do |type|
    rsb_match_for_type(
      app_identifier: ENV['BUNDLE_ID'],
      type: type,
      clone_directly: false
    )

    bundle_id_extensions = ENV['BUNDLE_ID_EXTENSIONS']
    next unless bundle_id_extensions
    bundle_id_extensions.split(', ').each do |bundle_id_extension|
      rsb_match_for_type(
        app_identifier: bundle_id_extension,
        type: type,
        clone_directly: false
      )
    end
  end
end

desc 'Download all certificates and profiles via match'
lane :rsb_match do
  types = %w[appstore development adhoc]
  types.each do |type|
    rsb_match_for_type(
      app_identifier: ENV['BUNDLE_ID'],
      type: type,
      force: false,
      readonly: true,
      clone_directly: true
    )

    bundle_id_extensions = ENV['BUNDLE_ID_EXTENSIONS']
    next unless bundle_id_extensions
    bundle_id_extensions.split(', ').each do |bundle_id_extension|
      rsb_match_for_type(
        app_identifier: bundle_id_extension,
        type: type,
        force: false,
        readonly: true,
        clone_directly: true
      )
    end
  end
end

desc 'Remove all certificates and profiles'
lane :rsb_match_nuke do
  url = ENV['MATCH_GIT_URL']
  branch = ENV['MATCH_GIT_BRANCH']
  delete_remote_branch(url, branch)
end
