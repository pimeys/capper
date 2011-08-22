class Capper
  module Utils
    module Monit

      def monit_config(name, body)
        set(:monit_configs, fetch(:monit_configs, []) << "# #{name}\n#{body}")
      end

    end
  end
end
