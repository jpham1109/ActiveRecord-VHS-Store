class Movie < ActiveRecord::Base
    has_many :vhs
    has_many :rentals, through: :vhs
    has_many :movie_genres
    has_many :genres, through: :movie_genres
    
    
    def self.available_now
        Vhs.available_now.map(&:movie).uniq
        binding.pry
    end
    
    # def number_of_clients
    #     self.vhs.sum{|vhs| vhs.clients.count}
    #     # binding.pry
 
    # end 

    # def self.most_clients
    #     # binding.pry
    #     self.all.max_by{|movie| movie.number_of_clients}
    # end

    def movie_clients
        self.rentals.map(&:client)
    end 

    def self.most_clients
        movies_hash = self.all.each_with_object({}) {|movie, movies_hash| movies_hash[movie] = movie.movie_clients.uniq.count}
        movies_hash.max_by{|movie, client_count| client_count}[0]
    end 

    def num_rentals
        #number of rentals each movie's copies had
        self.vhs.sum {|vhs| vhs.rentals.count}
    end 

    def self.most_rentals
        self.all.sort_by{|movie| movie.num_rentals}.reverse[0..2]
    end 

    def self.most_popular_female_director
        female_director_movies = self.all.select{|movie| movie.female_director}
        female_director_movies.max_by{|movie| movie.num_rentals}.director
    end 

    def self.newest_list
        self.all.sort_by{|movie| movie.year}.reverse
    end

    def self.longest
        self.all.sort_by{|movie| movie.length}.reverse
    end 

    def recommendation
        emoji = ["🤩", "😍", "🤯", "😎", "😤", "😢", "😱"].sample
        puts emoji + "title: #{self.title} \n description: #{self.description} \n length: #{self.length} \n director: #{self.director} \n year: #{self.year}"
    end 

    def self.surprise_me
        self.all.sample.recommendation
    end

    def report_stolen
        Vhs.available_now.select{|vhs| vhs.movie == self}.sample.destroy
        puts "THANK YOU FOR YOUR REPORT. WE WILL LAUNCH AN INVESTIGATION."
    end
end