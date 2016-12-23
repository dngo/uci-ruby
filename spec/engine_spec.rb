require 'spec_helper'


describe Uci::Engine do

  subject(:engine) { Uci::Engine.new }

  it "test_engine_version_is_valid" do
    expect(engine.version).to match(/^Stockfish \d+/)
  end

  it "test_engine_is_ready?" do
    expect(engine.ready?).to be_truthy
  end

  it "test_engine_returns_position_analysis" do
    fen = read_fixture("positions/stalemate.txt")
    analysis_output = engine.analyze(fen, { :depth => 6 })
    expect(analysis_output).to match(/^info/)
    expect(analysis_output).to match(/^bestmove/)
    fen = read_fixture("positions/start.txt")
    analysis_output = engine.analyze(fen, { :depth => 6 })
    expect(analysis_output).to match(/^info/)
    expect(analysis_output).to match(/^bestmove/)
  end

  it "test_multipv_mode_returns_multipv_output" do
    engine.multipv(3)
    fen = read_fixture("positions/white_wins_in_4.txt")
    analysis_output = engine.analyze(fen, { :depth => 6 })
    expect(analysis_output).to match(/multipv 3/)
    expect(analysis_output).to match(/^bestmove/)
  end

end
