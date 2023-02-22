module Presenter
  def show_message(message)
    print "#{'#' * 35}\n#{message}\n#{'#' * 35}\n"
  end

  def print_score(score)
    puts "Well done! Your score is #{score}"
    puts ("-" * 60).to_s
  end
end
