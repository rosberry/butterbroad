require_relative '../helper/plist_helper.rb'

# Post message about new build with release notes to the slack channel.
private_lane :rsb_post_to_slack_channel do |options|
  slack_url = ENV['SLACK_URL']
  next unless slack_url

  destination = options[:destination]
  release_notes = options[:release_notes]
  configuration = options[:configuration]
  
  next unless destination
  next unless configuration

  scheme = ENV['GYM_SCHEME']

  title = "*#{scheme} - Build #{build_number}* to *#{destination}* has been submitted"
  title += " with `#{configuration}` configuration." if configuration

  slack(
    message: release_notes,
    default_payloads: [],
    attachment_properties: {
      color: "#36a64f",
      pretext: title
    }
  )
end

def rsb_slack_release_notes(tickets)
  description = ''

  features = []
  fixes = []

  tickets.to_a.each do |ticket|
    if ticket.issuetype.name == 'Bug'
      fixes.push(ticket)
    else
      features.push(ticket)
    end
  end

  unless features.empty?
    description += "\n*🎉 Features*:"
    features.each do |ticket|
      description += "\n • [<#{ENV['JIRA_WEBSITE']}/browse/#{ticket.key}|#{ticket.key}>] #{ticket.summary};"
    end    
  end
  
  unless fixes.empty?
    description += "\n" unless description.empty?
    description += "\n*🐛 Fixes*:"
    fixes.each do |ticket|
      description += "\n • [<#{ENV['JIRA_WEBSITE']}/browse/#{ticket.key}|#{ticket.key}>] #{ticket.summary};"
    end
  end

  description
end