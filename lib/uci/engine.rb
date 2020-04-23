require 'open3'
require 'io/wait'

module Uci
  class InvalidBinary < StandardError; end
  class InvalidCommand < StandardError; end
  class InvalidOption < StandardError; end

  class Engine
    attr_reader :stdin, :stdout, :stderr, :wait_threads, :version, :pid

    COMMANDS = %w(uci isready setoption ucinewgame position go stop ponderhit quit)

    def initialize(engine_path = "bin/stockfish_11_x64_linux")
      @stdin, @stdout, @stderr, @wait_threads = Open3.popen3(engine_path)
      @pid = @wait_threads[:pid]
      @version = @stdout.readline.strip

      raise "Not a uci engine" unless write_to_engine("uci") =~ /^uciok/
    end

    def write_to_engine(command_string)
      command = command_string.split(" ").first
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

      output.strip
    end

    def multipv(n)
      write_to_engine "setoption name MultiPV value #{n}"
    end

    def level(n)
      write_to_engine "setoption name Skill Level value #{n}"
    end

    # The engine is able to limit its strength to a specific Elo rating,
    def elo_rating(elo_rating)
      limit_strength(true)
      write_to_engine "setoption name UCI_Elo value #{elo_rating}"
    end

    def ready?
      write_to_engine("isready").strip == "readyok"
    end

    def analyze(fen, options = {})
      write_to_engine "position fen #{fen}"
      command = "go" # no options
      %w(depth movetime nodes).each do |opt|
        if (x = options[opt.to_sym])
          # these options override each other so just use the first option we find, instead of pass contradicting options
          command = "go #{opt} #{x}"
        end
      end
      command << " searchmoves #{options[:searchmoves]}" if options[:searchmoves]
      write_to_engine command
    end

    protected

    # This should always be implemented together with "UCI_Elo".
    # If UCI_LimitStrength is false, the UCI_Elo value is ignored.
    # If UCI_LimitStrength is true, the engine plays within UCI_Elo value
    def limit_strength(boolean_val = false)
      write_to_engine "setoption name UCI_LimitStrength value #{boolean_val}"
    end
  end
end
