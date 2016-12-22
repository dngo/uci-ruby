require 'spec_helper'

describe Stockfish::AnalysisParser do

  subject(:parser) { Stockfish::AnalysisParser }

  it "suggests_a_move_for_a_normal_position" do
    output = parsed_fixture("analysis_outputs/tough_midgame.txt")
    expect(output[:variations].length).to eql 1
    expect(output[:variations][0][:score]).to eql -12.51
  end

  it "suggests_three_variations_for_multipv_3" do
    output = parsed_fixture("analysis_outputs/multipv_3.txt")
    expect(output[:variations].length).to eql 3
  end

  it "detects_stalemate" do
    output = parsed_fixture("analysis_outputs/stalemate.txt")
    expect(output[:bestmove]).to be_nil
    expect(output[:variations].length).to eql 1
    move = output[:variations][0]
    expect(move[:score]).to eql 0
  end

  it "detects_checkmate" do
    output = parsed_fixture("analysis_outputs/checkmate.txt")
    expect(output[:bestmove]).to be_nil
    expect(output[:variations].length).to eql 1
    move = output[:variations][0]
    expect(move[:score]).to eql "mate 0"
  end

  it "detects_imminent_win_by_checkmate" do
    output = parsed_fixture("analysis_outputs/mate_in_1.txt")
    expect(output[:variations].length).to eql 1
    move = output[:variations][0]
    expect move[:score] == "mate 1"
  end

  it "detects_win_by_checkmate" do
    output = parsed_fixture("analysis_outputs/white_wins_in_4.txt")
    expect(output[:variations].length).to eql 1
    move = output[:variations][0]
    expect move[:score] == "mate 4"
  end

  it "detects_loss_by_checkmate" do
    output = parsed_fixture("analysis_outputs/black_loses_in_3.txt")
    expect(output[:variations].length).to eql 1
    move = output[:variations][0]
    expect move[:score] == "mate -3"
  end

end
