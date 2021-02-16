class Client < ActiveRecord::Base
    has_many :rentals
    has_many :vhs, through: :rentals

    def self.first_rental(client_hash, movie_title)
        client = Client.create(client_hash)
        puts "Welcome to the Vhs store, #{client.name}"
        movie = Movie.find_by(title: movie_title)
        vhs_copies = Vhs.where(movie_id: movie.id)
        vhs = vhs_copies.find{|vhs| vhs.is_available_to_rent?}
        Rental.create(client_id: client.id, vhs_id: vhs.id, current: true)
    end 
    
    # def self.first_rental(client_hash, movie_title)
    #     client = Client.create(client_hash)
    #     puts "Welcome to the VHS store, #{client.name}!"
    #     movie = Movie.find_by(title: movie_title)
    #     vhs = Vhs.available_now.find{|vhs| vhs.movie_id == movie.id}
    #     Rental.create(client_id: client.id, vhs_id: vhs.id, current: true)
    # end 

    # def self.first_rental(client_hash, vhs)
    #     client = Client.create(client_hash)
    #     if vhs.is_available_to_rent?
    #       Rental.create(client_id: client.id, vhs_id: vhs.id, current: true)
    #     else
    #         puts "Please pick an available Vhs"
    #     end 
    # end

    # def past_rentals
    #     #return an array of each client's past rentals
    #     self.rentals.select{|rental| !rental.current}
    # end 

    # def self.most_active
    #     #returns a list of top 5 most active clients (i.e. those who had the most non-current / returned rentals)
    #     self.all.sort_by{|client| client.past_rentals.size}.reverse[0..4]
    # end 

    def num_of_returned_rentals
        Rental.where(client_id: self.id, current: false).size
    end 

    def self.most_active
        #.pop() removes the last number(arg) of items off the end of array and returns those removed items 
        self.all.each_with_object({}) {|client, hash| hash[client] = client.num_of_returned_rentals}.sort_by(&:last).pop(5).reverse
    end 

    def movies
        #movies a client has rented
        self.vhs.map(&:movie)
    end 

    def genres
        #genres a client has watch through rentals
        genres = movies.map(&:genres).flatten
    end 

    def favorite_genre_hash
        genre_hash = {}
        genres.each do |genre|
            key = genre.name
            if genre_hash[key]
                genre_hash[key][:count] += 1
            else
                genre_hash[key] = {}
                genre_hash[key][:genre] = genre
                genre_hash[key][:count] = 1
            end
        end
        genre_hash
    end 

    def favorite_genre
        #please re-seed and test again. Atm not returning the right genre
        # binding.pry
        favorite_genre_hash.max_by(&:count)[1]
    end

    def self.non_grata
        self.all.select do |client|
            client.rentals.any? {|rental| rental.past_due? || rental.returned_late?}
        end
    end 
    
    def late_fee
        self.rentals.count {|rental| rental.returned_late?} * 12
    end 

    def rental_fee
        (self.rentals.count * 5.35).round(2)
    end 

    def total_spent
        self.late_fee + self.rental_fee
    end

    def self.paid_most
        self.all.max_by(&:total_spent)
        binding.pry
    end 
    
    
    def self.total_watch_time
        Rental.all.sum {|rental| rental.vhs.movie.length}
    end 

    def return_one(vhs)
        rental = Rental.find_by(client_id: self.id, vhs_id: vhs.id, current: true)
        rental.update(current: false)
    end 

    def all_current_rentals
        Rental.where(client_id: self.id, current: true)
    end 

    def return_all
        # self.all_current_rentals.map{|rental| rental.update(current: false)}
        self.all_current_rentals.update(current: false)
    end 

    def last_return
        self.return_all
        client = Client.find(id: self.id)
        client.destroy
    end 

end

    # Client.paid_most - returns an instance who has spent most money at the store; one rental is $5,35 upfront (bonus: additional $12 charge for every late return — do not count those that have not yet been returned)
    # Client.total_watch_time - returns an Integer of all movies watched by the all clients combined (assume that a rented movie is a watched movie)

