class Genre < ActiveRecord::Base
    has_many :movie_genres
    has_many :movies, through: :movie_genres
    # binding.pry

    def self.most_popular
        Genre.all.sort_by{|genre| genre.movies.count}.reverse[0..4]
    end 

    def average_movie_length
        sum = self.movies.sum{|movie| movie.length}
        return 0 if sum == 0
        average_movie_length = sum/self.movies.size.to_f.round(2)
        binding.pry
    end

    def self.longest_movies
        self.all.max_by(&:average_movie_length)
    end
end