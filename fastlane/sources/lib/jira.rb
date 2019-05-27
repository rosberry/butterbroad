require_relative '../helper/credentials_helper.rb'

private_lane :rsb_move_jira_tickets do |options|
  project = ENV['JIRA_PROJECT']
  jira_website = ENV['JIRA_WEBSITE']
  next unless jira_website
  next unless project

  tickets = options[:tickets]  
  next unless !tickets.empty?

  to_status = options[:status][:transition].downcase
  
  client = rsb_jira_client

  tickets.each do |ticket|
    transitions = client.Transition.all(issue: ticket)
    transitions.each do |transition|
      transition_name = transition.name.downcase
      status_name = transition.to.attrs["name"].downcase
      next unless (transition_name == to_status || status_name == to_status)
      to_transition_id = transition.id
      transition = ticket.transitions.build
      transition.save!('transition' => { 'id' => to_transition_id })
    end
  end
end

private_lane :rsb_search_jira_tickets do |options|
  project_name = ENV['JIRA_PROJECT']
  jira_website = ENV['JIRA_WEBSITE']
  component = ENV['JIRA_COMPONENT']
  label = ENV['JIRA_TASK_LABEL']

  next unless jira_website
  next unless project_name

  client = rsb_jira_client

  statuses = options[:statuses]
  mine = options[:mine]
  task = options[:task]
  task = false if ffreezing?

  jql_string = "project = #{project_name.shellescape}"
  jql_string += " AND sprint in openSprints()"
  jql_string += " AND status in (#{statuses.map{ |status| status[:name].shellescape }.join(", ")})" if (statuses && statuses.count > 0)
  jql_string += " AND component = #{component}" if component
  jql_string += " AND labels = #{label}" if label
  if mine != nil
    mine ? jql_string += " AND assignee = currentuser()" : jql_string += " AND (assignee != currentuser() OR assignee is EMPTY)"
  end
  if task != nil
    task ? jql_string += " AND issuetype != bug" : jql_string += " AND issuetype = bug"
  end

  tickets = client.Issue.jql(jql_string)  

  key = options[:key]
  if key
    ticket = rsb_select_jira_ticket_with_key(tickets, key)
    tickets = [ticket] if ticket
  end

  tickets
end

private_lane :rsb_get_selected_jira_ticket_key_from_browser do |options|
  require 'uri'
  require 'cgi'

  chrome = options[:browser] && options[:browser].downcase == "chrome"
  if chrome
    running = sh('osascript -e \'application "Google Chrome" is running\' | tr -d \'\n\'')
    url = sh('osascript -e \'tell application "Google Chrome" to get URL of active tab of first window\' | tr -d \'\n\'') if running == "true" 
  else
    running = sh('osascript -e \'application "Safari" is running\' | tr -d \'\n\'')
    url = sh('osascript -e \'tell application "Safari" to return URL of front document\' | tr -d \'\n\'') if running == "true"  
  end
  unless url && !(url.include? "execution error")
    next rsb_get_selected_jira_ticket_key_from_browser(browser: "chrome") unless chrome
    next    
  end

  uri = URI.parse(URI.encode(url))  
  env_uri = URI.parse(ENV['JIRA_WEBSITE'])
  
  unless uri.host == env_uri.host
    next rsb_get_selected_jira_ticket_key_from_browser(browser: "chrome") unless chrome
    next
  end

  next uri.path.split('/').last if uri.path && uri.path.include?("browse")

  parameters = CGI.parse(uri.query) if uri.query
  next if parameters.empty?

  parameters['selectedIssue'].first
end

def rsb_select_jira_tickets_assigned_to_me(tickets)
  client = rsb_jira_client
  me = client.User.myself
  tickets.select { |ticket| !ticket.assignee.nil? }.select { |ticket| me.accountId == ticket.assignee.accountId }
end

def rsb_select_jira_tickets_not_assigned_to_me(tickets)
  client = rsb_jira_client
  me = client.User.myself
  tickets.select { |ticket| ticket.assignee.nil? || me.accountId != ticket.assignee.accountId }
end

def rsb_select_jira_tickets_with_statuses(tickets, statuses)
  status_names = statuses.map { |status| status[:name] }
  tickets.select { |ticket| status_names.include? ticket.status.attrs["name"] } 
end

def rsb_select_jira_ticket_with_key(tickets, key)
  key_parameters = key.split('-')
  if key_parameters.count > 1 
    ticket_key = key 
  else
    project_key = tickets.first.project.key  
    ticket_key = "#{project_key}-#{key}"
  end 
  tickets.select { |ticket| ticket_key == ticket.key }.first
end

def rsb_select_jira_tasks(tickets)
  tickets.select { |ticket| ticket.issuetype.name != 'Bug' }
end

def rsb_select_jira_bugs(tickets)
  tickets.select { |ticket| ticket.issuetype.name == 'Bug' }
end

def rsb_select_jira_ticket_with_dialog(tickets, dialog_title)
  if tickets.count > 1
    ticket_titles = tickets.map { |ticket| "#{ticket.status.attrs["name"]}: #{ticket.issuetype.name}, #{ticket.key}, #{ticket.summary}" }
    selected_ticket_title = UI.select(dialog_title, ticket_titles)
    tickets[ticket_titles.index(selected_ticket_title)]
  else
    tickets.first
  end
end

def rsb_jira_tickets_description(tickets)

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
    description += "\nFeatures:"
    features.each do |ticket|
      description += "\n  #{ticket.summary} (#{ENV['JIRA_WEBSITE']}/browse/#{ticket.key})"
    end    
  end
  
  unless fixes.empty?
    description += "\n" unless description.empty?
    description += "\nFixes:"
    fixes.each do |ticket|
      description += "\n  #{ticket.summary} (#{ENV['JIRA_WEBSITE']}/browse/#{ticket.key})"
    end
  end

  description
end

def rsb_jira_client
  Actions.verify_gem!('jira-ruby')

  jira_website = ENV['JIRA_WEBSITE']
  credentials = rsb_credentials('JIRA', jira_website)
  options = {
    site: jira_website,
    context_path: '',
    auth_type: :basic,
    username: credentials[:username],
    password: credentials[:password]
  }

  JIRA::Client.new(options)
end

def rsb_jira_status
  { 
    :to_do        => { :name => "To Do",        :transition => "To Do" },
    :doing        => { :name => "Doing",        :transition => "In Progress" },
    :code_review  => { :name => "Code Review",  :transition => "Code Review" },
    :ready        => { :name => "Ready",        :transition => "Ready" },
    :test_build   => { :name => "Test Build",   :transition => "Test Build" },
    :done         => { :name => "Done",         :transition => "Done" },
    :wont_do      => { :name => "Won't Do",     :transition => "Won't Do" }
  }
end