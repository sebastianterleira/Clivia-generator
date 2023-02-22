module Requester
  def select_main_menu_action
    puts "random | scores | exit"
    print "> "
    gets.chomp.strip.downcase
  end

  def ask_question(question, coder)
    # show category and difficulty from question
    puts "Category: #{question[:category]} | Difficulty: #{question[:difficulty]}"
    puts coder.decode("Question: #{question[:question]}") # show the question
    options = []
    options.push(question[:correct_answer])
    question[:incorrect_answers].each { |option| options.push(option) }
    options.shuffle!
    options.each_with_index { |answers, index| puts "#{index + 1}." "#{answers}" }  # show each one of the options
  end
end
