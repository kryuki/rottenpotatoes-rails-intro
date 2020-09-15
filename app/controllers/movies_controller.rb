class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # if params[:ratings].nil? 
    #   hash = {}
    #   Movie.all_ratings.each do |rating|
    #     hash[rating] = 1
    #   end
    #   params[:ratings] = hash
    # end
    if (params[:filter] == nil and params[:ratings] == nil and params[:sort] == nil and 
              (session[:filter] != nil or session[:ratings] != nil or session[:sort] != nil))
      if (params[:filter] == nil and session[:filter] != nil)
        params[:filter] = session[:filter]
      end
      if (params[:sort] == nil and session[:sort] != nil)
        params[:sort] = session[:sort]
      end
      redirect_to movies_path(:filter => params[:filter], :sort => params[:sort], :ratings => params[:ratings]) 
    else
      if (params[:filter] != nil and params[:filter] != "[]")
        @filtered_ratings = params[:filter].scan(/[\w-]+/)
        session[:filter] = params[:filter]
      else
        @filtered_ratings = params[:ratings] ? params[:ratings].keys : []
        session[:filter] = params[:ratings] ? params[:ratings].keys.to_s : nil
      end
    
      session[:sort] = params[:sort]
      session[:ratings] = params[:ratings]
    
      if params[:ratings].nil? 
        hash = {}
        Movie.all_ratings.each do |rating|
          hash[rating] = 1
        end
        params[:ratings] = hash
      end
      #@movies = Movie.all
      @all_ratings = Movie.all_ratings
      @movies = Movie.all if @movies.nil?
    
      if (params[:sort] == "title") # Sort by titles
        @movies = @movies.order(:title)
      elsif (params[:sort] == "release_date") # Sort by release_date
        @movies = @movies.order(:release_date)
      end
    
      if (params[:ratings] or params[:filter])
        if @filtered_ratings.blank?
          @movies = @movies.where(:rating => @all_ratings)
        else
          @movies = @movies.where(:rating => @filtered_ratings)
        end
      end
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
