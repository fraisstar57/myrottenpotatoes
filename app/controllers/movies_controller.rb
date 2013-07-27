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
		session[:titleOrder] = @titleSortOrder
		#@titleSortOrder = "desc"
		@titleSortOrder = "asc"
	elsif (@titleSortOrder == "asc") 
		@movies = @movies.sort_by{|e| e[:title]}
		session[:titleOrder] = @titleSortOrder
		#@titleSortOrder = "desc"
		@titleSortOrder = "asc"
	elsif (@titleSortOrder == "desc")
		@movies = @movies.sort_by{|e| e[:title]}.reverse
		session[:titleOrder] = @titleSortOrder
		@titleSortOrder = "asc"
	end
	if(@titleSortOrder != nil)
		titleSortOrder = @titleSortOrder
		params[:titleOrder] = @titleSortOrder
	end
	@titleSortOrder = params[:titleOrder]
	session[:titleSortLastToRun] = true
	
	movies = @movies
	@titleSetCss = true
  end
  
   
  def sort_movies_by_release_date
	
    mapU = lambda { |x| x[:release_date].to_s.split(' ').values_at(0,1,2) }
	
	@releaseDateSortOrder = params[:releaseDateOrder]
	if(params == nil || params[:releaseDateOrder] == nil || params[:releaseDateOrder] == "none") 
		@movies = @movies.sort_by{|e| mapU.call(e)}
		session[:releaseDateOrder] = @releaseDateSortOrder
		#@releaseDateSortOrder = "desc"
		@releaseDateSortOrder = "asc"
	elsif (@releaseDateSortOrder == "asc") 
		@movies = @movies.sort_by{|e| mapU.call(e)}
		session[:releaseDateOrder] = @releaseDateSortOrder
		#@releaseDateSortOrder = "desc"
		@releaseDateSortOrder = "asc"
	elsif (@releaseDateSortOrder == "desc")
		@movies = @movies.sort_by{|e| mapU.call(e)}.reverse
		session[:releaseDateOrder] = @releaseDateSortOrder
		@releaseDateSortOrder = "asc"
	end
	if(@releaseDateSortOrder != nil)
		releaseDateSortOrder = @releaseDateSortOrder
		params[:releaseDateOrder] = @releaseDateSortOrder
	end	
	session[:titleSortLastToRun] = false
	
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
	#local vars
	@titleSetCss = false
	@releaseDateSetCss = false
	@redirectRating = false
	@redirectTitle = false
	@redirectDate = false
	
	#get's the ratings list
	@all_ratings = Array.new()
	Movie.all(:select => "DISTINCT rating").each { |r| @all_ratings.push(r.rating) }
	
	#the hash for the checked values
	@ratingsChecked = Hash.new()	
	#checks everything if none are set
	if(params[:ratings] == nil && session[:ratings] == nil) 
		@ratingsFiltered = @all_ratings
		@all_ratings.each { |ar| @ratingsChecked[ar] = "1" }
	#pulls the ratings from session if avalible
	elsif(params[:ratings] == nil)
		@redirectRating = true
		params[:ratings] = session[:ratings]
		@ratingsFiltered = session[:ratings].keys
		@ratingsChecked = session[:ratings]
	#uses the params that were checked
	else
		@ratingsFiltered = params[:ratings].keys
		@ratingsChecked = params[:ratings]
		session[:ratingsFiltered] = @ratingsFiltered
		session[:ratingsChecked] = @ratingsChecked
		session[:ratings] = params[:ratings]
	end
	
	#like above, we need 3 conditions: nil, nil in params not in session, params but we need it for both.
	#since they're mutually exclusive, we have 5 scenairos
		#Title has params: it nukes the other / sort on title
		#Date has params: it nukes the other / redirect with title params
		#Title has session but no params: it nukes the other / sort on date
		#Date has session but no params: it nukes the other / redirect with date params
		#None: In this scenairo, you simply need to not do anything
	if(params[:titleOrder] != nil) 
		#title order was the last to run. This only needs to be set when there are params
		session[:titleSortLastToRun] = true
		session[:titleOrder] = params[:titleOrder]
		
		#set the titleSortOrder to whatever the params had
		@titleSortOrder = params[:titleOrder]
		
		#Delete the params for the other and it's session data
		session.delete(:releaseDateOrder)
		params.delete(:releaseDateOrder)
		
		#I'm not sure why this is here. The ratings checked shouldn't need to be set here....what's up?
		if(session[:ratingsChecked] != nil)
			@ratingsChecked = session[:ratingsChecked]
		end
		if(session[:ratingsFiltered] != nil)
			@ratingsFiltered = session[:ratingsFiltered]
		end	
	#No params for title so it's date's turn to try	
	elsif(params[:releaseDateOrder] != nil) 	
		session[:titleSortLastToRun] = false
		session[:releaseDateOrder] = params[:releaseDateOrder]
		
		#set the releaseDateSortOrder
		@releaseDateSortOrder = params[:releaseDateOrder]
		
		session.delete(:titleOrder)
		params.delete(:titleOrder)
		
		#I'm not sure why this is here. The ratings checked shouldn't need to be set here....what's up?
		if(session[:ratingsChecked] != nil)
			@ratingsChecked = session[:ratingsChecked]
		end
		if(session[:ratingsFiltered] != nil)
			@ratingsFiltered = session[:ratingsFiltered]
		end
	#ok, we're at the session checks. Make sure there's something in session first though, duh	
	elsif(params[:releaseDateOrder] == nil && session[:releaseDateOrder] != nil) 
		@releaseDateSortOrder = session[:releaseDateOrder]	
		@redirectTitle = false
		@redirectDate = true
		@redirectRating = true
	#the next to last one, check the session too before proceeding
	elsif(params[:titleOrder] == nil && session[:titleOrder] != nil) 
		@titleSortOrder = session[:titleOrder]	
		@redirectTitle = true
		@redirectDate = false
		@redirectRating = true
	else
	
		#in theory these delete's aren't necessary but we're doing them anyway
		session.delete(:releaseDateOrder)
		params.delete(:releaseDateOrder)
		session.delete(:titleOrder)
		params.delete(:titleOrder)
	
		#an extra precaution to make sure we don't redirect to either of these
		@redirectTitle = false
		@redirectDate = false	
	end
		
	
	
	if(@ratingsFiltered == nil)
		@movies = Movie.all
	else
		@movies = Movie.where("rating IN (?)", @ratingsFiltered).to_a
	end
	
	#These are now mutually exclusive sorts
	if((params[:titleOrder] == "none" || params[:titleOrder] == "asc" || params[:titleOrder] == "desc")) 
		sort_movies_by_title
	elsif((params[:releaseDateOrder] == "none" || params[:releaseDateOrder] == "asc" || params[:releaseDateOrder] == "desc")) 
		sort_movies_by_release_date
	end		
			
	if(@redirectRating)
		if(@redirectTitle)
			redirect_to movies_path({:titleOrder => session[:titleOrder], :ratings => session[:ratings]})
		elsif(@redirectDate)
			redirect_to movies_path({:releaseDateOrder => session[:releaseDateOrder], :ratings => session[:ratings]})
		else
			redirect_to movies_path({:ratings => session[:ratings]})
		end
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
