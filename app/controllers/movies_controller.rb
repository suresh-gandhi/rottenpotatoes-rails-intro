class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # Retreiving movie ID from the URI route
    @movie = Movie.find(id) # Looking up the movie by unique ID
    
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.ratings # Getting all ratings
    
    flag = false
    
    if(params[:order])
      @order = params[:order]
    elsif(session[:order])
      @order = session[:order]
      flag = true
    end

    if(params[:ratings])
      @checked_ratings = params[:ratings]
    elsif(session[:ratings])
      @checked_ratings = session[:ratings]
      flag = true
    else
      @all_ratings.each do |rating|
        (@checked_ratings ||= {}) [rating]=1
      end
    end
    
    session[:ratings] = @checked_ratings
    session[:order] = @order

    if flag
      redirect_to movies_path(:order => @order, :ratings => @checked_ratings)
    end
    
    if (session[:ratings] == nil)
      @movies = Movie.all
    else
      @movies = Movie.where(rating: @checked_ratings.keys) # Filtering based on ratings stored in session
    end
    
    # Order based on the user input 
    if(@order == :release_date.to_s)
      @movies = @movies.order(:release_date).all
    elsif (@order == :title.to_s)
      @movies = @movies.order(:title).all
    end
    
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
