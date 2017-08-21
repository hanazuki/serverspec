module Serverspec::Type
  class PostfixConfig < Base
    def value(opts = {})
      overrides = @options.fetch(:override, {}).flat_map do |k, v|
        %W[-o #{k}=#{v}]
      end

      command = [
        'postconf',
        '-h',
        *('-x' if opts[:expand]),
        *overrides,
        @name
      ]

      ret = @runner.run_command(command.shelljoin)
      return if ret.exit_status.to_i != 0 || ret.stdout.size == 0

      ret.stdout.chomp
    end

    def expanded_value
      value(expand: true)
    end

    def configured?
      !value.nil?
    end
  end
end
