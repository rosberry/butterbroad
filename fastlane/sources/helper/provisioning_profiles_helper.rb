# Updating provisioning profiles.
private_lane :rsb_update_provisioning_profiles do |options|
  rsb_update_provisioning_profiles_for_app_identifier(
    app_identifier: ENV['BUNDLE_ID'],
    type: options[:type]
  )

  bundle_id_extensions = ENV['BUNDLE_ID_EXTENSIONS']
  next unless bundle_id_extensions

  bundle_id_extensions.split(', ').each do |bundle_id_extension|
    rsb_update_provisioning_profiles_for_app_identifier(
      app_identifier: bundle_id_extension,
      type: options[:type]
    )
  end
end

# Update provisioning profile for concrete bundle id.
def rsb_update_provisioning_profiles_for_app_identifier(options)
  app_identifier = options[:app_identifier]
  type = options[:type]
  match_type = type == :adhoc ? 'adhoc' : 'appstore'

  rsb_match_for_type(
    app_identifier: app_identifier,
    type: match_type,
    force: true,
    readonly: false,
    clone_directly: true
  )
end