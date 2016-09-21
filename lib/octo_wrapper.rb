require 'octokit'

module MchxChefGen
  @def_endpoint = 'https://github.marchex.com/api/v3'

  def self.protect_branch(token, org, repo,
      endpoint = @def_endpoint,
      contexts = %w(chef_delivery/verify/lint chef_delivery/verify/syntax chef_delivery/verify/unit),
      branch = 'master',
      users = %w(chef-delivery),
      teams = %w()
  )

    data = {
        :protection => true,
        :required_status_checks => {
            :include_admins => true,
            :strict => true,
            :contexts => contexts
        },
        :restrictions => {
            :users => users,
            :teams => teams
        }
    }
    begin
      client = Octokit::Client.new(:access_token => token, :api_endpoint => endpoint)
      result = client.protect_branch(org + '/' + repo, branch, data,
                       {
                           :accept => 'application/vnd.github.loki-preview+json'
                       })
    rescue Exception => e
      puts sprintf("ERROR: Unable to protect branch %s on repo %s/%s to team %s", branch, org, repo, teams)
      puts sprintf("ERROR: response from server was: %s", e)
      throw e
    end
    result
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
