# Stashing tests output.
private_lane :rsb_stash_save_tests_output do
  next unless need_unit_testing?
  sh('git stash save ./fastlane/test_output/report.html ./fastlane/test_output/report.junit')
end

# Applying stashed tests output.
private_lane :rsb_stash_pop_tests_output do
  next unless need_unit_testing?
  sh('git stash pop')
end

# Run unit tests.
private_lane :rsb_run_tests_if_needed do
  next unless need_unit_testing?

  ENV['SCAN_WORKSPACE'] = ENV['GYM_WORKSPACE']
  ENV['SCAN_PROJECT'] = ENV['GYM_PROJECT']
  scan(
    scheme: ENV['GYM_SCHEME'],
    configuration: ENV['CONFIGURATION_ADHOC'],
    devices: ENV['UNIT_TESTING_DEVICES'],
    code_coverage: true,
    skip_slack: true
  )
end

# Commit test output files.
private_lane :rsb_commit_tests_output do
  next unless need_unit_testing?
  git_add(path: %w[./fastlane/test_output/report.html ./fastlane/test_output/report.junit])
  git_commit(
    path: %w[./fastlane/test_output/report.html ./fastlane/test_output/report.junit],
    message: 'Complete tests'
  )
end

def need_unit_testing?
  ENV['NEED_UNIT_TESTING'] == 'true'
end