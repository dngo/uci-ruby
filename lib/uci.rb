require "uci/engine"
require "uci/analysis_parser"


module Uci

  def self.analyze(fen, options = {})
    multipv = options.delete(:multipv)
    engine = Engine.new
    engine.multipv(multipv) if multipv
    AnalysisParser.new(engine.analyze(fen, options)).parse
  end

end
