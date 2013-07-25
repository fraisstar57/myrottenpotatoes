class MoviesController < ApplicationController
	
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def sort_movies
	@sortOrder = params[:order]
	if(params == nil || params[:order] == nil) 
		@movies = @movies.sort_by{|e| e[:title]}
		@sortOrder = "asc"
	elsif (@sortOrder == "asc") 
		@movies = @movies.sort_by{|e| e[:title]}
		@sortOrder = "desc"
	elsif (@sortOrder == "desc")
		@movies = @movies.sort_by{|e| e[:title]}.reverse
		@sortOrder = "asc"
	end
	if(@sortOrder != nil)
		sortOrder = @sortOrder
		params[:order] = @sortOrder
		session[:order] = @sortOrder
	end
	movies = @movies
  end
  
  attr_accessor:sortOrder
  
  def index  
	@movies = Movie.all
	if(session[:order] != nil) 
		@sortOrder = session[:order]
	elsif(@sortOrder == nil && session[:order] == nil)
		@sortOrder = "none"
	end
	if(params[:order] == "none" || params[:order] == "asc" || params[:order] == "desc") 
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
