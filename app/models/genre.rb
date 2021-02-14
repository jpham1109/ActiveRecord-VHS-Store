class Genre < ActiveRecord::Base
    has_many :movie_genres
    has_many :movies, through: :movie_genres
    # binding.pry
end