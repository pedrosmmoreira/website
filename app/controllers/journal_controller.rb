class JournalController < ApplicationController
  def show
    @entry = JournalEntry.find_by_slug!(params[:slug])
  end
end
