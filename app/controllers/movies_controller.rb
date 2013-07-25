class MoviesController < ApplicationController
	
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def sort_movies
	@titleSortOrder = params[:titleOrder]
	if(params == nil || params[:titleOrder] == nil || params[:titleOrder] == "none") 
		@movies = @movies.sort_by{|e| e[:title]}
		@titleSortOrder = "desc"
	elsif (@titleSortOrder == "asc") 
		@movies = @movies.sort_by{|e| e[:title]}
		@titleSortOrder = "desc"
	elsif (@titleSortOrder == "desc")
		@movies = @movies.sort_by{|e| e[:title]}.reverse
		@titleSortOrder = "asc"
	end
	if(@titleSortOrder != nil)
		titleSortOrder = @titleSortOrder
		params[:titleOrder] = @titleSortOrder
		session[:titleOrder] = @titleSortOrder
	end
	movies = @movies
  end
  
  attr_accessor:titleSortOrder
  attr_accessor:releaseDateSortOrder
  
  def index  
	@movies = Movie.all
	if(params[:titleOrder] != nil) 
		session[:titleOrder] = params[:titleOrder]
	end
	if(session[:titleOrder] != nil) 
		@titleSortOrder = session[:titleOrder]
	elsif(@titleSortOrder == nil && session[:titleOrder] == nil)
		@titleSortOrder = "asc"
		session[:titleOrder] = @titleSortOrder
	end
	if(params[:titleOrder] == "none" || params[:titleOrder] == "asc" || params[:titleOrder] == "desc") 
		sort_movies
	end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
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
