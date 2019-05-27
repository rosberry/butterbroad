require 'security'

def rsb_credentials(account_name, server)
  credentials = Security::InternetPassword.find(server: server)
  if credentials
    username = credentials.attributes['acct']
    password = credentials.password
  else
    puts '-------------------------------------------------------------------------------------'.green
    puts "Please provide your #{account_name} account credentials".green
    puts 'The login information you enter will be stored in your macOS Keychain'.green
    puts '-------------------------------------------------------------------------------------'.green

    username = ask('Username: ') while username == nil or username.empty?
    password = ask("Password (for #{username}): ") { |q| q.echo = '*' } while password == nil or password.empty?

    Security::InternetPassword.add(server, username, password)
  end
  {
    username: username,
    password: password
  }
end