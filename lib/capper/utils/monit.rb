class Capper
  module Utils
    module Monit

      def monit_config(name, body, options={})
        set(:monit_configs, fetch(:monit_configs, {}).merge(name => {
          :options => options, :body => body
        }))
      end

    end
  end
end
