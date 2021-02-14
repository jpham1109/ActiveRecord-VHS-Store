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

    def favorite_genre
        
    end 

end

