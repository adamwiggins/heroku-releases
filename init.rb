module Heroku::Command
  class Releases < Base
    def index
      releases = heroku.releases(extract_app)

      output = []
      output << "Rel  Code     When                       What      Who"
      output << "---  -------  -------------------------  --------  -----------"

      releases.reverse.slice(0, 15).each do |r|
        output << "%-4s %-8s %-26s %-9s %s" % [ r['name'], r['code'], r['created_at'], r['descr'], r['user'] ]
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
