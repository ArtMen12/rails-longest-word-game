require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = generate_grid(10)
  end

  def score
    @answer = run_game(params[:word], @letters)
  end
end

def generate_grid(grid_size)
  Array.new(grid_size) { ('A'..'Z').to_a.sample }
end

def included?(guess, grid)
  guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
end

def compute_score(attempt)
  attempt.size * 10
end

def run_game(attempt, grid)
  result = {}

  score_and_message = score_and_message(attempt, grid)
  result[:score] = score_and_message.first
  result[:message] = score_and_message.last

  result
end

def score_and_message(attempt, grid)
  if included?(attempt.upcase, grid)
    if english_word?(attempt)
      score = compute_score(attempt)
      [score, "well done"]
    else
      [0, "not an english word"]
    end
  else
    [0, "not in the grid"]
  end
end

def english_word?(word)
  response = open("https://wagon-dictionary.herokuapp.com/#{word}")
  json = JSON.parse(response.read)
  return json['found']
end
