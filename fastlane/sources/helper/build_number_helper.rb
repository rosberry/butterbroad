require_relative 'plist_helper.rb'

# Commiting build number changes
private_lane :rsb_commit_build_number_changes do
  sh("git commit -a -m 'Change the build number'")
end

# Updating build number
private_lane :rsb_update_build_number do
  plist_path = ENV['INFOPLIST_PATH']
  number = (build_number.to_i + 1).to_s

  set_info_plist_value(
    path: plist_path,
    key: 'CFBundleVersion',
    value: number
  )

  plist_path_extensions = ENV['INFOPLIST_PATH_EXTENSIONS']
  next unless plist_path_extensions

  plist_path_extensions.split(', ').each do |plist_path_extension|
    set_info_plist_value(
      path: plist_path_extension,
      key: 'CFBundleVersion',
      value: number
    )
  end
end

private_lane :rsb_update_extensions_build_and_version_numbers_according_to_main_app do
  info_plist_extensions = ENV['INFOPLIST_PATH_EXTENSIONS']
  next unless info_plist_extensions

  info_plist_extensions.split(', ').each do |info_plist_extension|
    set_info_plist_value(path: info_plist_extension, key: 'CFBundleVersion', value: build_number)
    set_info_plist_value(path: info_plist_extension, key: 'CFBundleShortVersionString', value: app_version)
  end
end