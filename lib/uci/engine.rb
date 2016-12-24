require 'open3'
require 'io/wait'


module Uci

  class InvalidBinary < StandardError; end
  class InvalidCommand < StandardError; end
  class InvalidOption < StandardError; end

  class Engine
    attr_reader :stdin, :stdout, :stderr, :wait_threads, :version, :pid

    COMMANDS = %w( uci isready setoption ucinewgame position go stop ponderhit quit )

    def initialize(engine_path = "bin/stockfish_8_x64_linux")
      @stdin, @stdout, @stderr, @wait_threads = Open3.popen3(engine_path)
      @pid = @wait_threads[:pid]
      @version = @stdout.readline.strip

      raise "Not a uci engine" unless write_to_engine("uci") =~ /^uciok/
    end

    def write_to_engine(command_string)
      command = command_string.split(" ").first
      #Rails.logger.info "UCI Engine command_string: #{command_string}, command: #{command}"
      stdin.puts command_string

      output = ""
      case command
      when "quit"
        output << "shutting down engine"
      when "uci"
        loop do
          output << (line = @stdout.readline)
          break if line =~ /^uciok/
        end
      when "go"
        begin
          loop do
            output << (line = @stdout.readline)
            break if line =~ /^bestmove/
          end
        rescue EOFError
        end
      when "position", "setoption"
        output << ""
      else
        output << @stdout.readline
      end

      #Rails.logger.info "UCI Engine response: #{output}"
      output.strip
    end

    def multipv(n)
      write_to_engine "setoption name MultiPV value #{n}"
    end

    def ready?
      write_to_engine("isready").strip == "readyok"
    end

    def analyze(fen, options)
      write_to_engine "position fen #{fen}"
      %w( depth movetime nodes ).each do |command|
        if (x = options[command.to_sym])
          return write_to_engine "go #{command} #{x}"
        end
      end
    end

  end
end
