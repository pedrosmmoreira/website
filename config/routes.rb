Rails.application.routes.draw do
  root "pages#home"

  get "now", to: "pages#now"
  get "projects", to: "pages#projects"
  get "about", to: "pages#about"

  get "journal", to: redirect("/", status: 301), as: :journal
  get "journal/:slug", to: "journal#show", as: :journal_entry

  get "404", to: "errors#not_found"
end
