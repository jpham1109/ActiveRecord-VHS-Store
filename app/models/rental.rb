class Rental < ActiveRecord::Base
    belongs_to :client
    belongs_to :vhs

    
    def due_date
        #due_date - returns a date one week from when the record was created
        # due_date = self.created_at.to_datetime + 7
        self.created_at + 7.days
    end 
    
    def past_due?
        self.current == true && self.due_date < DateTime.now
    end

    def returned_late?
        self.current == false && self.due_date < self.updated_at
    end 
    
    def self.past_due_date
        #returns a list of all the rentals past due date
        Rental.all.select{|rental| rental.past_due? || rental.returned_late?}
    end 

    def self.past_rentals_currently_available_vhs
        Rental.select{|rental| !rental.current}.map(&:vhs)
    end 

    # def self.currently_rented
    #     #returns a list of all the rentals currently rented
    #     self.all.select{|rental| rental.current}
    # end 

    # def self.rented_in_the_past
    #     #returns a list of all the rentals rented in the past?
    #     self.all.select{|rental| !rental.current}
    # end 
end