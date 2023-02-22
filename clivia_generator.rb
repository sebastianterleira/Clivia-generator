require_relative "presenter"
require_relative "requester"
require "terminal-table"
require "json"
require "httparty"
require "htmlentities"

class CliviaGenerator
  include Presenter
  include Requester
  include HTTParty

  def initialize
    @coder = HTMLEntities.new
    input = ARGV.shift
    @filename = input.nil? ? "scores.json" : input
    @questions = []
    @question = {}
    @score = 0
  end

  def start
    action = nil
    until action == "exit"
      show_message("#   Welcome to Clivia Generator   #")
      action = select_main_menu_action
      case action
      when "random" then random_trivia
      when "scores" then print_scores
      when "exit" then show_message("#     Thanks for using Clivia     #")
      else
        puts "Invalid option"
      end
    end
  end

  def random_trivia
    @questions = load_questions[:results]
    ask_questions
  end

  def ask_questions
    @questions.each do |question|
      ask_question(question, @coder)
      print "> "
      answers = gets.chomp
      if question[:correct_answer].include? answers
        puts "#{answers}... Correct!"
        @score += 10
      else
        puts "#{answers}... Incorrect!"
        puts "The correct answer was: #{question[:correct_answer]}"
      end
    end
    print_score(@score)
    puts "Do you want to save your score? (y/n)"
    print "> "
    no = ["n", "N"]
    yes = ["y", "Y"]
    choice = gets.chomp
    if yes.include? choice
      puts "Type the name to assign to the score"
      print "> "
      input = gets.chomp
      name = input == "" ? "Anonymous" : input
      data = { name: name, score: @score }
      save(data) unless data.nil?
    end
    nil if no.include? choice
  end

  def save(data)
    scores = parse_scores
    scores.push(data)
    File.write(@filename, scores.to_json)
  end

  def parse_scores
    File.open(@filename, "a+") do |file|
      file.write("[]") if file.read == ""
    end

    JSON.parse(File.read(@filename), { symbolize_names: true })
  end

  def load_questions
    # ask the api for a random set of questions
    response = HTTParty.get("https://opentdb.com/api.php?amount=10")
    raise HTTParty::ResponseError, response unless response.success?

    # then parse the questions
    JSON.parse(response.body, symbolize_names: true)
  end

  def parse_questions(questions)
    coder = HTMLEntities.new
    questions.map do |question|
      hash = { category: question[:category],
               type: question[:multiple],
               difficulty: question[:difficulty],
               question: code.decode(question[:question]).delete('\\"'),
               correct_answer: code.decode(question[:correct_answer]).delete('\\"'),
               incorrect_answers: question[:incorrect_answers].map { |q| coder.decode(q).delete('\\"') } }
      @questions << hash
    end
  end

  def print_scores
    scores = parse_scores.sort_by { |hash| hash[:score] }
    table = Terminal::Table.new
    table.title = "Top Scores"
    table.headings = ["Name", "Score"]
    table.rows = scores.map do |score|
      [score[:name], score[:score]]
    end
    puts table
  end
end

trivia = CliviaGenerator.new
trivia.start
