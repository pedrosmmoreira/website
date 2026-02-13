class PagesController < ApplicationController
  def home
    @entries = JournalEntry.all
  end

  def now
  end

  def projects
  end

  def about
  end
end
