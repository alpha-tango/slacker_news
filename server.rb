require 'sinatra'
require 'csv'
require 'pry'
require 'sinatra/flash'
enable :sessions

invalid_hash = {}

####################
# CSV
####################

before do    #calls before every single route the below variable
  @all_articles = []
  CSV.foreach('articles.csv', headers: true, header_converters: :symbol) do |row|
    @all_articles << row.to_hash
  end
end

##################
#METHODS SECTION
##################

def find_article(article_title)
  article_array = @all_articles.select {|article| article[:title] == article_title}
  article_hash = article_array[0]
end

def valid_submission?(params_hash)
  if params_hash.has_value?(nil)
    return false
  elsif params_hash[:description].length < 20
    return false
  elsif params_hash[:url][-4..-1] != ".com"
    return false
  else
    true
  end
end

#################
#ROUTING
##################

get '/' do
  erb :home
end

get '/article/:article_name' do
 @current_article = find_article(params[:article_name])
  erb :article
end

get '/newarticle' do
  @invalid_hash = invalid_hash
  erb :new_article
end

post '/newarticle' do
  if valid_submission?(params)
    CSV.open('articles.csv', 'a') do |row|
      row << [params[:title], params[:url], params[:description]]
      flash[:notice] = "Submission successful!"
      invalid_hash={}
      redirect '/'
    end
  else
    flash[:notice] = "Invalid submission - please try again."
    invalid_hash=params
   redirect '/newarticle'

  end
# redirect '/'
end



