module Heroku::Command
  class Releases < Base
    def index
      releases = heroku.releases(extract_app)

      output = []
      output << "Rel  Change    Commit   By                    Timestamp"
      output << "---  --------  -------  --------------------  -------------------------"

      releases.reverse.slice(0, 15).each do |r|
        output << "%-4s %-9s %-8s %-21s %s" % [ r['name'], r['descr'], r['commit'], r['user'], r['created_at'] ]
      end

      display output.join("\n")
    end
  end
end

class Heroku::Client
  def releases(app)
    JSON.parse get("/apps/#{app}/releases")
  end
end
