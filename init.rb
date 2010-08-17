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

    def rollback
      release = args.shift.downcase.strip rescue nil
      raise(CommandFailed, "Specify a release") unless release

      heroku.rollback(extract_app, release)
      display "Rolled back to #{release}"
    end
  end
end

class Heroku::Client
  def releases(app)
    JSON.parse get("/apps/#{app}/releases")
  end

  def rollback(app, release)
    post("/apps/#{app}/releases", :rollback => release)
  end
end
