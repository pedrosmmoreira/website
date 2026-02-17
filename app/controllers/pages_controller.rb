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

  def sitemap
    @entries = JournalEntry.all
    respond_to do |format|
      format.xml
    end
  end
end
