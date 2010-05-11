%w{
  base
  interacter
  project
  ticket
  rubygems
  systems/github
}.each {|lib| require 'ticketmaster/' + lib }

module TicketMaster
  # @todo: Fix this, and make it new
  def self.interact_with(client)
    Interacter.new(client)
  end

  class NotYetImplemented < StandardError
  end
end

github = TicketMaster.interact_with(:github)
p github.project.find("Flimpl", {:user => "sirupsen"}).tickets
