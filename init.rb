module Heroku::Command
  class Releases < Base
    def index
      releases = heroku.releases(extract_app)

      output = []
      output << "Rel   Change                          By                    When"
      output << "----  ----------                      ----------            ----------"

      releases.reverse.slice(0, 15).each do |r|
        name = r["name"]
        descr = truncate(r["descr"], 30)
        user = truncate(r["user"], 20)
        time_ago = delta_format(Time.parse(r["created_at"]))
        output << "%-4s  %-30s  %-20s  %-25s" % [name, descr, user, time_ago]
      end

      display output.join("\n")
    end

    private

    def pluralize(str, n)
      n == 1 ? str : "#{str}s"
    end

    def delta_format(start, finish = Time.now)
      secs  = (finish.to_i - start.to_i).abs
      mins  = (secs/60).round
      hours = (mins/60).round
      days  = (hours/24).round
      if days > 0
        start.to_s
      elsif hours > 0
        "#{hours} #{pluralize("hour", hours)} ago"
      elsif mins > 0
        "#{mins} #{pluralize("minute", mins)} ago"
      else
        "#{secs} #{pluralize("second", secs)} ago"
      end
    end

    def truncate(text, length)
      (text.size > length) ? text[0, length - 3] + "..." : text
    end
  end

  class Rollback < Base
    def index
      release = args.shift.downcase.strip rescue nil
      raise(CommandFailed, "Specify a release") unless release

      heroku.rollback(extract_app, release)
      display "Rolled back to #{release}"
    end
  end
end

class Heroku::Client
  def releases(app)
    JSON.parse get("/apps/#{app}/releases").to_s
  end

  def rollback(app, release)
    post("/apps/#{app}/releases", :rollback => release)
  end
end
