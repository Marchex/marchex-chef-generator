require 'octokit'

module MchxChefGen
  @def_endpoint = 'https://github.marchex.com/api/v3'

  def self.protect_branch(token, org, repo,
      endpoint = @def_endpoint,
      contexts = %w(),
      branch = 'master',
      users = %w(chef-delivery),
      teams = %w()
  )

    data = {
      :protection => true,
# currently not using status checks: we do not want to restrict
# whether Workflow is allowed to merge at any time.
#       :required_status_checks => {
#         :include_admins => true,
#         :strict => true,
#         :contexts => contexts
#       },
      :restrictions => {
        :users => users,
        :teams => teams
      },
      :accept => 'application/vnd.github.loki-preview+json'
    }
    begin
      client = Octokit::Client.new(:access_token => token, :api_endpoint => endpoint)
      result = client.protect_branch(org + '/' + repo, branch, data)
    rescue Exception => e
      puts sprintf("ERROR: Unable to protect branch %s on repo %s/%s to team %s", branch, org, repo, teams)
      puts sprintf("ERROR: response from server was: %s", e)
      throw e
    end
    result
  end

  def self.set_pre_receive_hook(token, org, repo,
      hook_id = 1, # 'workflow-master', see below
      endpoint = @def_endpoint
  )
    begin
      # pre-receive hook '1' is workflow-master, which rejects all
      # non-"chef-delivery" pushes to master.  if we want to pass a name instead,
      # we will need to add more calls.
      client = Octokit::Client.new(:access_token => token, :api_endpoint => endpoint)
      result = client.patch "#{endpoint}/repos/#{org}/#{repo}/pre-receive-hooks/#{hook_id}", {
        :enforcement  => 'enabled',
        :accept       => 'application/vnd.github.eye-scream-preview'
      }

    rescue Exception => e
      puts sprintf("ERROR: Unable to set pre-receive-hook '%d' for '%s/%s'", hook_id, org, repo)
      puts sprintf("ERROR: response from server was: %s", e)
      throw e
    end
    result
  end

  def self.remove_old_hooks(token, org, repo,
      endpoint = @def_endpoint
  )
    begin
      client = Octokit::Client.new(:access_token => token, :api_endpoint => endpoint)
      hooks = client.hooks(org + '/' + repo)
      hooks.each do |hook|
        # we no longer use Delivery webhooks, and old jira1.sea1 hooks
        # have been replaced by jira.marchex.com hooks.  remove old stuff.
        # if we get other hooks to remove we can add them to this list.
        if hook[:config][:url] =~ /\bdelivery\.marchex\.com\b/ ||
           hook[:config][:url] =~ /\bjira1\.sea1\.marchex\.com\b/
          client.remove_hook(org + '/' + repo, hook[:id])
        end
      end

    rescue Exception => e
      puts sprintf("ERROR: Unable to remove hooks for repo %s/%s", org, repo)
      puts sprintf("ERROR: response from server was: %s", e)
      throw e
    end

  end

  def self.create_repo(token, cookbook,
      endpoint = @def_endpoint,
      org = 'marchex-chef'
  )
    begin
      client = Octokit::Client.new(:access_token => token, :api_endpoint => endpoint)
      client.create_repository(cookbook, {:organization => org})

    rescue Exception => e
      puts sprintf("ERROR: Unable to create repository %s in org %s", cookbook, org)
      puts sprintf("ERROR: response from server was: %s", e)
      throw e
    end
  end

end
