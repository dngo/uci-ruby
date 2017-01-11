require 'spec_helper'


describe Uci::Engine do

  subject(:engine) { Uci::Engine.new }
  let(:fen) { "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1" }

  it "implements uci protocol" do
    expect(engine.write_to_engine('uci')).to match(/uciok/)
  end

  it "test_engine_version_is_valid" do
    expect(engine.version).to match(/^Stockfish \d+/)
  end

  it "test_engine_is_ready?" do
    expect(engine.ready?).to be_truthy
  end

  it "sets position by fen" do
    expect(engine.write_to_engine("position fen #{fen}")).to eql('')
  end

  it "sets position by moves" do
    expect(engine.write_to_engine("position startpos moves e2e4 ")).to eql('')
  end

  it "only responds to valid commands" do
    expect(engine.write_to_engine('bad string') ).to eql("Unknown command: bad string")
  end

  describe '#analyze' do
    it "gets the best move from a fen" do
      expect(engine.analyze(fen, movetime: 500)).to match(/^bestmove e2e4/)
    end

    it "returns_position_analysis" do
      fen = read_fixture("positions/stalemate.txt")
      analysis_output = engine.analyze(fen, { :depth => 6 })
      expect(analysis_output).to match(/^info/)
      expect(analysis_output).to match(/^bestmove/)
      fen = read_fixture("positions/start.txt")
      analysis_output = engine.analyze(fen, { :depth => 6 })
      expect(analysis_output).to match(/^info/)
      expect(analysis_output).to match(/^bestmove/)
    end

    it "the engine supports multi best line" do
      engine.multipv(3)
      fen = read_fixture("positions/white_wins_in_4.txt")
      analysis_output = engine.analyze(fen, { :depth => 6 })
      expect(analysis_output).to match(/multipv 3/)
      expect(analysis_output).to match(/^bestmove/)
    end

    it "the engine supports levels" do
      engine.level(1)
      fen = read_fixture("positions/white_wins_in_4.txt")
      analysis_output = engine.analyze(fen)
      expect(analysis_output).to match(/^bestmove/)
    end
  end

end
