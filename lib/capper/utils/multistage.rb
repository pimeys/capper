class Capper
  module Utils
    module Multistage

      def stage(name, &block)
        stages = fetch(:stages, [])

        if stages.include?(name)
          abort "Multiple stages with the same name are not allowed"
        end

        namespace :multistage do
          task(name, {}, &block)
        end

        desc "Set the target stage to `#{name}'."
        task(name) do
          set(:current_stage, name.to_sym)
          find_and_execute_task("multistage:#{name}")
        end

        set(:stages, [stages, name].flatten)
      end

    end
  end
end
