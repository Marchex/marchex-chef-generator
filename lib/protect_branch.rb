require 'octokit'

module MchxChefGen
  def self.protect_branch(token, org, repo,
      endpoint = 'https://github.marchex.com/api/v3',
      contexts = %w(chef_delivery/verify/lint chef_delivery/verify/syntax chef_delivery/verify/unit),
      branch = 'master',
      users = %w(chef-delivery),
      teams = %w()
  )
    client = Octokit::Client.new(:access_token => token, :api_endpoint => endpoint)

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
end
