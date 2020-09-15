class Movie < ActiveRecord::Base
  def self.all_ratings
    return Movie.all.pluck(:rating).uniq
  end
end