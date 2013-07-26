class MoviesController < ApplicationController
	
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def sort_movies_by_title
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
	@titleSortOrder = params[:titleOrder]
	
	movies = @movies
	@titleSetCss = true
  end
  
   
  def sort_movies_by_release_date
	
    mapU = lambda { |x| x[:release_date].to_s.split(' ').values_at(0,1,2) }
	
	@releaseDateSortOrder = params[:releaseDateOrder]
	if(params == nil || params[:releaseDateOrder] == nil || params[:releaseDateOrder] == "none") 
		@movies = @movies.sort_by{|e| mapU.call(e)}
		@releaseDateSortOrder = "desc"
	elsif (@releaseDateSortOrder == "asc") 
		@movies = @movies.sort_by{|e| mapU.call(e)}
		@releaseDateSortOrder = "desc"
	elsif (@releaseDateSortOrder == "desc")
		@movies = @movies.sort_by{|e| mapU.call(e)}.reverse
		@releaseDateSortOrder = "asc"
	end
	if(@releaseDateSortOrder != nil)
		releaseDateSortOrder = @releaseDateSortOrder
		params[:releaseDateOrder] = @releaseDateSortOrder
		session[:releaseDateOrder] = @releaseDateSortOrder
	end	
	movies = @movies
	@releaseDateSetCss = true
  end
  
  attr_accessor:titleSortOrder
  attr_accessor:releaseDateSortOrder
  
  attr_accessor:titleSetCss
  attr_accessor:releaseDateSetCss
  
  attr_accessor:all_ratings
  attr_accessor:ratingsFiltered
  attr_accessor:ratingsChecked
  
  def index  
				
	@titleSetCss = false
	@releaseDateSetCss = false
	
	@redirectValue = false
	
	@all_ratings = Array.new()
	Movie.all(:select => "DISTINCT rating").each { |r| @all_ratings.push(r.rating) }
	
	@ratingsChecked = Hash.new()	
	if(params[:ratings] == nil && session[:ratings] == nil) 
		@ratingsFiltered = @all_ratings
		@all_ratings.each { |ar| @ratingsChecked[ar] = "1" }
	elsif(params[:ratings] == nil)
		@redirectValue = true
		params[:ratings] = session[:ratings]
		@ratingsFiltered = session[:ratings].keys
		@ratingsChecked = session[:ratings]
	else
		@ratingsFiltered = params[:ratings].keys
		@ratingsChecked = params[:ratings]
		session[:ratingsFiltered] = @ratingsFiltered
		session[:ratingsChecked] = @ratingsChecked
		session[:ratings] = params[:ratings]
	end
	
	if(params[:titleOrder] != nil) 
		session[:titleOrder] = params[:titleOrder]
		if(session[:ratingsChecked] != nil)
			@ratingsChecked = session[:ratingsChecked]
		end
		if(session[:ratingsFiltered] != nil)
			@ratingsFiltered = session[:ratingsFiltered]
		end
	end
	if(params[:releaseDateOrder] != nil) 
		session[:releaseDateOrder] = params[:releaseDateOrder]
		if(session[:ratingsChecked] != nil)
			@ratingsChecked = session[:ratingsChecked]
		end
		if(session[:ratingsFiltered] != nil)
			@ratingsFiltered = session[:ratingsFiltered]
		end
	end
		
	
	if(@ratingsFiltered == nil)
		@movies = Movie.all
	else
		@movies = Movie.where("rating IN (?)", @ratingsFiltered).to_a
	end
	
	if(session[:titleOrder] != nil) 
		@titleSortOrder = session[:titleOrder]
	elsif(@titleSortOrder == nil && session[:titleOrder] == nil)
		@titleSortOrder = "asc"
		session[:titleOrder] = @titleSortOrder
	end
	if(params[:titleOrder] == "none" || params[:titleOrder] == "asc" || params[:titleOrder] == "desc") 
		sort_movies_by_title
	end
	
	if(session[:releaseDateOrder] != nil) 
		@releaseDateSortOrder = session[:releaseDateOrder]
	elsif(@releaseDateSortOrder == nil && session[:releaseDateOrder] == nil)
		@releaseDateSortOrder = "asc"
		session[:releaseDateOrder] = @releaseDateSortOrder
	end
	if(params[:releaseDateOrder] == "none" || params[:releaseDateOrder] == "asc" || params[:releaseDateOrder] == "desc") 
		sort_movies_by_release_date
	end		
	
	if(@redirectValue)
	redirect_to movies_path({:titleOrder => session[:titleOrder], :releaseDateOrder => session[:releaseDateOrder], :ratings => session[:ratings]})
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
