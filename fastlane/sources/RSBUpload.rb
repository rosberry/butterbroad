require_relative 'helper/changelog_helper.rb'

default_platform :ios

platform :ios do

  before_all do |lane, options|
    Actions.lane_context[SharedValues::FFREEZING] = options[:ffreezing]
    skip_docs
  end

  after_all do |lane|
    clean_build_artifacts
  end

  error do |lane, exception|
    clean_build_artifacts
    if $git_flow & $release_branch_name
      rsb_remove_release_branch(
        name: $release_branch_name
      )
    end
  end

  ### LANES

  lane :rsb_fabric do |options|
    rsb_upload(
      fabric: true,
      git_flow: options[:git_flow],
      git_build_branch: options[:git_build_branch],
      ci: options[:ci]
    )
  end

  lane :rsb_testflight do |options|
    rsb_upload(
      testflight: true,
      git_flow: options[:git_flow],
      git_build_branch: options[:git_build_branch],
      ci: options[:ci]
    )
  end

  lane :rsb_fabric_testflight do |options|
    rsb_upload(
      fabric: true,
      testflight: true,
      git_flow: options[:git_flow],
      git_build_branch: options[:git_build_branch],
      ci: options[:ci]
    )
  end

  lane :rsb_upload do |options|    
    upload_via_ci = !!options[:ci]    
    if upload_via_ci
      if rsb_possible_to_trigger_ci_build?
        rsb_trigger_ci_fastlane(
          fabric: options[:fabric],
          testflight: options[:testflight],
          git_flow: options[:git_flow],
          git_build_branch: options[:git_build_branch]
        )
        next
      else
        UI.user_error!('You need to configure CI environments: CI_APP_TOKEN, CI_APP_NAME, CI_JENKINS_USER, CI_JENKINS_USER_TOKEN')
      end
    end

    $git_flow = options[:git_flow] == nil ? true : options[:git_flow]
    git_build_branch = options[:git_build_branch] == nil ? rsb_current_git_branch : options[:git_build_branch]
    fabric = !!options[:fabric]
    testflight = !!options[:testflight]
    testflight_fabric = fabric == true && testflight == true

    if testflight
      precheck_if_needed
      check_no_debug_code_if_needed
    end

    if is_ci?
      setup_jenkins
    end

    ensure_git_status_clean

    $release_branch_name = rsb_release_branch_name(testflight)

    ready_tickets = rsb_search_jira_tickets(
      statuses: [rsb_jira_status[:ready]]
    )

    if $git_flow
      rsb_git_checkout('develop')
      rsb_git_pull
      rsb_start_release_branch(
        name: $release_branch_name
      )
    else
      rsb_git_checkout(git_build_branch)
      rsb_git_pull
    end

    rsb_run_tests_if_needed
    rsb_stash_save_tests_output
    rsb_stash_pop_tests_output
    rsb_commit_tests_output

    fabric_configuration = {
      build_configuration: ENV['CONFIGURATION_ADHOC'],
      slack_destination: "Fabric",
      profile_type: :adhoc,
      testflight: false
    }
    testflight_configuration = {
      build_configuration: ENV['CONFIGURATION_APPSTORE'],
      slack_destination: "Testflight",
      profile_type: :appstore,
      testflight: true
    }

    if testflight_fabric
      configurations = [fabric_configuration, testflight_configuration]      
    elsif testflight
      configurations = [testflight_configuration]      
    else
      configurations = [fabric_configuration]      
    end

    slack_release_notes = rsb_slack_release_notes(ready_tickets)
    
    configurations.each do |configuration|
      rsb_update_provisioning_profiles(
        type: configuration[:profile_type]
      )
      rsb_build_and_archive(
        configuration: configuration[:build_configuration]
      )
      if configuration[:testflight]
        rsb_send_to_testflight(
          skip_submission: true
        )
      else 
        fabric_release_notes = rsb_jira_tickets_description(ready_tickets)
        rsb_send_to_crashlytics(
          groups: [ENV['CRASHLYTICS_GROUP']],
          notes: fabric_release_notes
        )
      end
      unless configuration[:testflight] && testflight_fabric == true
        rsb_move_jira_tickets(
          tickets: ready_tickets,
          status: rsb_jira_status[:test_build]
        )
      end
      rsb_post_to_slack_channel(
        configuration: configuration[:build_configuration],
        release_notes: slack_release_notes,
        destination: configuration[:slack_destination]
      )
    end

    if is_ci?
      reset_git_repo(
        force: true, 
        exclude: ['Carthage/Build', 'Carthage/Checkouts']
      )
    end

    changelog_release_notes = rsb_changelog_release_notes(ready_tickets)
    rsb_update_changelog(
      release_notes: changelog_release_notes, 
      commit_changes: true
    )

    rsb_update_build_number
    rsb_commit_build_number_changes

    if $git_flow
      rsb_end_release_branch(
        name: $release_branch_name
      )
    end

    rsb_add_git_tag($release_branch_name)
    rsb_git_push(tags: true)
  end

  lane :rsb_add_devices do
    file_path = prompt(
      text: 'Enter the file path: '
    )

    register_devices(
      devices_file: file_path
    )
  end

  lane :rsb_changelog do |options|
    ready_tickets = rsb_search_jira_tickets(
      statuses: [rsb_jira_status[:ready]]
    )
    changelog_release_notes = rsb_changelog_release_notes(ready_tickets)
    rsb_update_changelog(
      release_notes: changelog_release_notes, 
      commit_changes: false
    )
  end

  lane :rsb_post_to_slack do |options|
    testflight = !!options[:testflight]
    fabric_configuration = {
        build_configuration: ENV['CONFIGURATION_ADHOC'],
        slack_destination: "Fabric"
    }
    testflight_configuration = {
        build_configuration: ENV['CONFIGURATION_APPSTORE'],
        slack_destination: "Testflight"
    }
    if testflight 
      configuration = testflight_configuration
    else 
      configuration = fabric_configuration
    end
    configuration = ENV['CONFIGURATION_ADHOC'] if configuration == nil 

    ready_tickets = rsb_search_jira_tickets(
      statuses: [rsb_jira_status[:ready]]
    )
    slack_release_notes = rsb_slack_release_notes(ready_tickets)
    rsb_post_to_slack_channel(
      configuration: configuration[:build_configuration],
      release_notes: slack_release_notes,
      destination: configuration[:slack_destination]
    )
  end

  ### PRIVATE LANES

  private_lane :rsb_build_and_archive do |options|
    configuration = options[:configuration]
    rsb_update_extensions_build_and_version_numbers_according_to_main_app

    if configuration == ENV['CONFIGURATION_ADHOC']
      gym(    
        configuration: configuration,
        include_bitcode: false,
        export_options: {
            uploadBitcode: false,
            uploadSymbols: true,
            compileBitcode: false
        }
      )
    else
      gym(configuration: configuration) 
    end
  end

  private_lane :rsb_send_to_crashlytics do |options|
    groups = options[:groups].to_a.reject { |group| group.empty? }
    crashlytics(
      groups: groups,
      notes: options[:notes]
    )
  end

  private_lane :rsb_send_to_testflight do |options|
    pilot(
      ipa: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
      skip_submission: options[:skip_submission],
      skip_waiting_for_build_processing: true
    )
  end
end

module SharedValues
  FFREEZING = :FFREEZING  
end

def ffreezing? 
  Actions.lane_context[SharedValues::FFREEZING] == true
end

def precheck_if_needed
  precheck(app_identifier: ENV['BUNDLE_ID']) if ENV['NEED_PRECHECK'] == 'true'
end

def check_no_debug_code_if_needed    
  ensure_no_debug_code(text: 'TODO|FIXME', path: 'Classes/', extension: '.swift') if ENV['CHECK_DEBUG_CODE'] == 'true'
end
