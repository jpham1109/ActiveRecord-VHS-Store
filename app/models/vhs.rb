class Vhs < ActiveRecord::Base
    after_initialize :add_serial_number

    belongs_to :movie
    has_many :rentals
    has_many :clients, through: :rentals
    
    def is_available_to_rent?
        Rental.find_by(vhs_id: self.id, current: false)
    end 

    # def self.available_now
    #     self.select{|vhs| vhs.rentals.empty?} + Rental.past_rentals_currently_available_vhs
    #     # binding.pry
    # end 

    def self.available_now
        active_tape = Rental.where(current: true).map(&:vhs)
        remaining_tape = self.all.select{|vhs| !active_tape.include?(vhs)}
        # binding.pry
    end 

    def self.hot_from_the_press(movie_hash, genre_name)
        movie = Movie.create(movie_hash)
        #AR method find_or_create_by https://apidock.com/rails/v4.0.2/ActiveRecord/Relation/find_or_create_by
        genre = Genre.find_or_create_by(name: genre_name)
        movie.genres << genre
        3.times{Vhs.create(movie_id: movie.id)}
    end 

    def num_of_rentals
        self.rentals.size
    end 

    def self.most_used
        # prints a list of 3 vhs that have been most rented in the format: "serial number: 1111111 | title: 'movie title'
        #reverse[range] returns the indexes indicated by the range
        most_used = self.all.sort_by {|vhs| vhs.num_of_rentals}.reverse[0..2]
        most_used.each {|vhs| puts "serial number: #{vhs.serial_number} | title: #{vhs.movie.title}"}
    end 
    
    def self.count_genres
        genres_hash = {}
        self.available_now.map do |vhs|
            vhs.movie.genres.each do |genre|
                genres_hash[genre.name].nil? ? genres_hash[genre.name] = 1 : genres_hash[genre.name] += 1
            end
        end
       genres_hash
    end 

    def self.all_genres
        genres_hash = self.count_genres
        genres_hash.keys
    end
    
    private

    # generates serial number based on the title
    def add_serial_number
        # binding.pry
        serial_number = serial_number_stub
        # Converting to Base 36 can be useful when you want to generate random combinations of letters and numbers, since it counts using every number from 0 to 9 and then every letter from a to z. Read more about base 36 here: https://en.wikipedia.org/wiki/Senary#Base_36_as_senary_compression
        alphanumerics = (0...36).map{ |i| i.to_s 36 }
        13.times{|t| serial_number << alphanumerics.sample}
        self.update(serial_number: serial_number)
    end

    def long_title?
        self.movie.title && self.movie.title.length > 2
    end

    def two_part_title?
        self.movie.title.split(" ")[1] && self.movie.title.split(" ")[1].length > 2
    end

    def serial_number_stub
        # binding.pry
        return "X" if self.movie.title.nil?
        return self.movie.title.split(" ")[1][0..3].gsub(/s/, "").upcase + "-" if two_part_title?
        return self.movie.title.gsub(/s/, "").upcase + "-" unless long_title?
        self.movie.title[0..3].gsub(/s/, "").upcase + "-"
    end
end