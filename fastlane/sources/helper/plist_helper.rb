def app_version 
  get_info_plist_value(
    path: ENV["INFOPLIST_PATH"],
    key: 'CFBundleShortVersionString'
  )
end

def build_number 
  get_info_plist_value(
    path: ENV['INFOPLIST_PATH'],
    key: 'CFBundleVersion'
  )
end

def bundle_name 
  name = get_info_plist_value(
    path: ENV['INFOPLIST_PATH'],
    key: 'CFBundleName'
  )
end

def bundle_display_name 
  name = get_info_plist_value(
    path: ENV['INFOPLIST_PATH'],
    key: 'CFBundleDisplayName'
  )
end