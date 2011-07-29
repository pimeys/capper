require "erubis"

class Capper
  module Utils
    module Templates

      # render an erb template from config/deploy/templates to the current
      # server list. this will render and upload templates serially using a
      # server-specific @variables binding. see get_binding for details.
      def upload_template(name, path, options={})
        template = "config/deploy/templates/#{name}.erb"

        unless File.exist?(template)
          template = File.expand_path("../../templates/#{name}.erb", __FILE__)
        end

        erb = Erubis::Eruby.new(File.open(template).read)
        prefix = options.delete(:prefix)

        if task = current_task
          servers = find_servers_for_task(task, options)
        else
          servers = find_servers(options)
        end

        if servers.empty?
          raise Capistrano::NoMatchingServersError, "no servers matching #{task.options.inspect}"
        end

        servers.each do |server|
          result = erb.result(get_binding(prefix, server.host))
          put(result, path, options.merge!(:host => server.host))
        end
      end

      # this allows for server specific variables. example:
      #
      # set :unicorn_worker_processes, {
      #   "app1.example.com" => 4,
      #   "app2.example.com" => 8,
      # }
      def get_binding(prefix, server)
        b = binding()

        variables.keys.select do |k|
          k =~ /^#{prefix}_/
        end.each do |k|
          v = fetch(k)

          if v.kind_of?(Hash)
            eval("set(:#{k}, \"#{v[server] || v["default"]}\")", b)
          else
            eval("set(:#{k}, \"#{v}\")", b)
          end
        end

        return b
      end
      private :get_binding

    end
  end
end
