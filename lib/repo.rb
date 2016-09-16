require 'tty-prompt'

def do_init_repo(repo_name)
  prompt = TTY::Prompt.new
  repo_url = "https://github.marchex.com/marchex-chef/#{repo_name}"

  prompt.say("Checking to see whether #{repo_url} already exists...", color: :bright_yellow)
  repo_check_http_code =  Mixlib::ShellOut.new("curl -IsS -o /dev/null --connect-timeout 3 -w '%\{http_code\}' #{repo_url}").run_command.stdout
  if (repo_check_http_code != "404")
    prompt.say("repository already exists at #{repo_url} -- not creating/modifying it.", color: :bright_yellow)
  elsif(prompt.yes?("Initialize repo at #{repo_url}?"))
    shell_command("git init #{repo_name}")
    shell_command("hub create marchex-chef/#{repo_name}", repo_name)
    shell_command("git add .", repo_name)
    shell_command("git commit -m 'Initial commit.'", repo_name)
    shell_command("git push origin master", repo_name)
    if repo_name !~ /^tests_/ then
      # Running github_protect_branch immediately after the initial push fails sometimes, so sleep for 3 seconds
      prompt.say("Sleeping for 5 seconds after repo creation before proceeding...", color: :bright_yellow)
      sleep(5)
      # Set up master branch protection rules
      shell_command("github_protect_branch -o marchex-chef -r #{repo_name} -s 'chef_delivery/verify/lint' -s 'chef_delivery/verify/syntax' -s 'chef_delivery/verify/unit' -u chef-delivery")
      # Add project to delivery server
      shell_command("delivery init --repo-name #{repo_name} --github marchex-chef --server delivery.marchex.com --ent marchex --org marchex --skip-build-cookbook --user #{ENV['USER']}", repo_name)
      # Push delivery pipeline branch and prompt user to create a PR
      shell_command("git push origin initialize-delivery-pipeline", repo_name)
      prompt.say("Please go to #{repo_url}/compare/initialize-delivery-pipeline?expand=1 and create a pull request.", color: :bright_green)
    end
  end
end
