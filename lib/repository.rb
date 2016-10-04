require 'fileutils'
require 'tty-prompt'

module MchxChefGen
  class Repository

    def initialize(cookbook_name, rel_path, basedir = nil)
      @name = cookbook_name
      @rel_path = rel_path
      @basedir = basedir # defaults to current working directory
    end

    def init_repo
      token = ENV['GITHUB_TOKEN']
      prompt = TTY::Prompt.new
      repo_url = "https://github.marchex.com/marchex-chef/#{@name}"

      prompt.say("Checking to see whether #{repo_url} already exists...", color: :bright_yellow)
      repo_check_http_code =  Mixlib::ShellOut.new("curl -IsS -o /dev/null --connect-timeout 3 -w '%\{http_code\}' #{repo_url}").run_command.stdout
      if (repo_check_http_code != "404")
        prompt.say("repository already exists at #{repo_url} -- not creating/modifying it.", color: :bright_yellow)
      elsif(prompt.yes?("Initialize repo at #{repo_url}?"))
        shell_command("git init #{@name}")
        puts "REPO_NAME: #{@name}"
        MchxChefGen.create_repo(token, @name)
        shell_command("git remote add origin git@github.marchex.com:marchex-chef/#{@name}.git", @name)

        shell_command("git add .", @name)
        #  Inspec doesnt have a .gitignore, and doesnt allow for templating either
        if File.exists?(@name + '/.gitignore')
          shell_command("git add -f .gitignore", @name) #
        end
        shell_command("git commit -m 'Initial commit.'", @name)
        shell_command("git push origin master", @name)

        unless @name =~ /^tests_/ then
          # Running github_protect_branch immediately after the initial push fails sometimes, so sleep for 3 seconds
          prompt.say('Sleeping for 5 seconds after repo creation before proceeding...', color: :bright_yellow)
          sleep(5)
          # Set up master branch protection rules
          MchxChefGen.protect_branch(token, 'marchex-chef', @name)
          # Add project to delivery server
          shell_command("delivery init --repo-name #{@name} --github marchex-chef --server delivery.marchex.com --ent marchex --org marchex --skip-build-cookbook --user #{ENV['USER']}", @name)
          # Push delivery pipeline branch and prompt user to create a PR
          shell_command("git push origin initialize-delivery-pipeline", @name)
          prompt.say("Please go to #{repo_url}/compare/initialize-delivery-pipeline?expand=1 and create a pull request.", color: :bright_green)

        end
        relocate_repo

      end
    end

    def set_basedir(home = ENV['HOME'])
      basedir_file = home + '/.marchex-chef-basedir'
      if File.exist?(basedir_file)
        @basedir = File.read(basedir_file).chomp
      else
        @basedir = '.'
      end
      @basedir
    end

    # this can return null if there's no .marchex-chef-basedir file (see above)
    def get_basedir
      set_basedir if @basedir.nil?
      @basedir
    end
    # @rel_path is either /cookbooks or /tests
    def get_repodir
      get_basedir + '/' + @rel_path + '/' + @name
    end

    def get_groupdir
      get_basedir + '/' + @rel_path
    end

    def relocate_repo
      dir = get_groupdir
      FileUtils.mkdir_p dir unless File.exist? dir
      # git init create the new repo in the working directory; assuming that
      FileUtils.mv './' + @name, dir
    end
  end
end

