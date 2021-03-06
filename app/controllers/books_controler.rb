class BooksController < ApplicationController

  get '/books' do
    if !logged_in?
      redirect '/login'
    end

    @reader = current_user
    erb :'/books/index'

  end

  get '/books/new' do
    if !logged_in?
      redirect '/login'
    end

    erb :'/books/new'
  end

  get '/books/:slug' do

    if !logged_in?
      redirect '/login'
    end

    @book = Book.find_by_slug(params[:slug])
    erb :'/books/show'
  end

  post '/books' do
    if !logged_in?
      redirect '/login'
    end

    if params[:name].empty? || params[:author].empty?
      redirect '/books/new'
    end

    current_user.community.books do |book|
      if book.slug == params[:name].downcase.tr(' ', '-')
        redirect '/books/new'
      end
    end

    @book = Book.create(name: params[:name], author: params[:author], description: params[:description], comments: params[:comments])
    @book.reader = current_user
    @book.community = current_user.community
    @book.number_of_ratings = 0.0
    @book.all_ratings = 0.0
    @book.save
    @book.rating = @book.add_new_rating(params[:rating])
    @book.save
    redirect '/books'
  end

  post '/rate/:slug' do
    if !logged_in?
      redirect '/login'
    end
    if Book.find_by_slug(params[:slug]).reader != current_user
        redirect '/books'
    end
    book = Book.find_by_slug(params[:slug])
    book.rating = book.add_new_rating(params[:rating].to_f)
    book.save
    erb :'books/index'
  end

  get '/books/:slug/edit' do
    if !logged_in?
      redirect '/login'
    end
    if Book.find_by_slug(params[:slug]).reader != current_user
        redirect '/books'
    end
    @book = Book.find_by_slug(params[:slug])
    erb :'/books/edit'

  end

  patch '/books/:slug/edit' do
    if !logged_in?
      redirect '/login'
    end

    if Book.find_by_slug(params[:slug]).reader != current_user
        redirect '/books'
    end

    current_user.community.books do |book|
      if book.slug == params[:name].downcase.tr(' ', '-')
        redirect '/books'
      end
    end

    book = Book.find_by_slug(params[:slug])

    if !params[:name].empty?
      book.name = params[:name]
    end
    if !params[:author].empty?
      book.author = params[:author]
    end
    if !params[:description].empty?
      book.description = params[:description]
    end
    if !params[:comments].empty?
      book.comments = params[:comments]
    end
    book.save
    redirect '/books'

  end

  delete '/books/:slug/delete' do
    if !logged_in?
      redirect '/login'
    end

    if Book.find_by_slug(params[:slug]).reader != current_user
        redirect '/books'
    end

    Book.find_by_slug(params[:slug]).delete
    redirect '/books'

  end

end
