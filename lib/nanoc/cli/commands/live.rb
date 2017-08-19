# frozen_string_literal: true

usage 'live'
summary 'auto-recompile and serve'
description 'TODO'

module Nanoc::CLI::Commands
  class Live < ::Nanoc::CLI::CommandRunner
    def run
      setup_listener
      serve
    end

    private

    def setup_listener
      require 'listen'

      Listen.to('content', 'layouts', 'lib') do |*|
        notify_updated
      end.start

      Listen.to('.', only: /^\/(Rules|config\.yaml|nanoc\.yaml)/) do |*|
        notify_updated
      end.start

      notify_started
    end

    def serve
      # TODO: Pass options

      pid = Process.fork do
        nanoc = Nanoc::CLI.root_command
        nanoc.command_named('view').run(%w[])
      end
      Process.waitpid(pid)
    end

    def notify_started
      puts '*** Live mode engaged!'
      fork_and_recompile
      puts

      puts '*** Listening for changes…'
      puts
    end

    def notify_updated
      puts '*** Found change; recompiling…'
      fork_and_recompile
      puts
    end

    def fork_and_recompile
      pid = Process.fork { recompile }
      Process.waitpid(pid)
    end

    def recompile
      nanoc = Nanoc::CLI.root_command
      nanoc.command_named('compile').run(%w[])
    end
  end
end

runner Nanoc::CLI::Commands::Live
