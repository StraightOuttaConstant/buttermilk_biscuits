require "buttermilk_biscuits/version"
require 'unirest'

module ButtermilkBiscuits
  module RecipesController
    def recipes_index_action
      recipe_hashs = get_request("/recipes")
      recipes = Recipe.convert_hashs(recipe_hashs)
      recipes_index_view(recipes)
    end

    def recipes_show_action
      input_id = recipes_id_form
      recipe_hash = get_request("/recipes/#{input_id}")
      recipe = Recipe.new(recipe_hash)

      recipes_show_view(recipe)
    end

    def recipes_create_action
      client_params = recipes_new_form
      json_data = post_request("/recipes", client_params)

      if !json_data["errors"]
        recipe = Recipe.new(json_data)
        recipes_show_view(recipe)
      else
        errors = json_data["errors"]
        recipes_errors_view(errors)
      end
    end

    def recipes_update_action
      input_id = recipes_id_form
      recipe_hash = get_request("/recipes/#{input_id}")
      recipe = Recipe.new(recipe_hash)

      client_params = recipes_update_form(recipe)
      json_data = patch_request("/recipes/#{input_id}", client_params)

      if !json_data["errors"]
        recipe = Recipe.new(json_data)
        recipes_show_view(recipe)
      else
        errors = json_data["errors"]
        recipes_errors_view(errors)
      end
    end

    def recipes_destroy_action
      input_id = recipes_id_form
      json_data = delete_request("/recipes/#{input_id}")
      puts json_data["message"]
    end
  end

  module RecipesViews
    def recipes_index_view(recipes)
      puts "*" * 70
      recipes.each do |recipe|
        recipes_show_view(recipe)
        puts "*" * 70
      end
    end

    def recipes_show_view(recipe)
      puts 
      puts recipe.title.upcase
      puts "=" * 70
      puts "by: #{recipe.chef}".ljust(35) + "prep: #{recipe.formatted_prep_time}".rjust(35)
      puts
      puts "Ingredients"
      puts "-" * 70
      recipe.formatted_ingredients.each do |ingredient|
        puts "    • #{ingredient}"
      end
      puts
      puts "Directions"
      puts "-" * 70
      recipe.formatted_directions.each_with_index do |direction, index|
        puts "    #{index + 1}. #{direction}"
      end
      puts
    end

    def recipes_id_form
      print "Enter recipe id: "
      gets.chomp
    end

    def recipes_new_form
      client_params = {}

      print "Title: "
      client_params[:title] = gets.chomp

      print "Ingredients: "
      client_params[:ingredients] = gets.chomp

      print "Directions: "
      client_params[:directions] = gets.chomp

      print "Prep Time: "
      client_params[:prep_time] = gets.chomp

      client_params
    end

    def recipes_update_form(recipe)
      client_params = {}

      print "Title (#{recipe.title}): "
      client_params[:title] = gets.chomp

      print "Chef (#{recipe.chef}): "
      client_params[:chef] = gets.chomp

      print "Ingredients (#{recipe.ingredients}): "
      client_params[:ingredients] = gets.chomp

      print "Directions (#{recipe.directions}): "
      client_params[:directions] = gets.chomp

      print "Prep Time (#{recipe.prep_time}): "
      client_params[:prep_time] = gets.chomp

      client_params.delete_if { |key, value| value.empty? }
      client_params
    end
  end

  class Recipe
    attr_accessor :id, :title, :chef, :ingredients, :directions, :created_at, :prep_time, :formatted_ingredients, :formatted_directions, :formatted_prep_time
    def initialize(input_options)
        @id = input_options["id"]
        @title = input_options["title"]
        @chef = input_options["chef"]
        @ingredients = input_options["ingredients"]
        @directions = input_options["directions"]
        @created_at = input_options["created_at"]
        @prep_time = input_options["prep_time"]
        @formatted_ingredients = input_options["formatted"]["ingredients"]
        @formatted_directions = input_options["formatted"]["directions"]
        @formatted_prep_time = input_options["formatted"]["prep_time"]
    end

    def self.convert_hashs(recipe_hashs)
      collection = []

      recipe_hashs.each do |recipe_hash|
        collection << Recipe.new(recipe_hash)
      end

      collection
    end
  end

  class Frontend
    include RecipesController
    include RecipesViews

    def run
      while true
        system "clear"

        puts "Welcome to my Cookbook App"
        puts "make a selection"
        puts "    [1] See all recipes"
        puts "        [1.1] Search all recipes"
        puts "        [1.2] Sort recipes by chef"
        puts "        [1.3] Sort recipes by prep time"
        puts "    [2] See one recipe"
        puts "    [3] Create a new recipe"
        puts "    [4] Update a recipe"
        puts "    [5] Destroy a recipe"
        puts ""
        puts "    [signup] Signup (create a user)"
        puts "    [login]  Login (create a JSON web token)"
        puts "    [logout] Logout (erase the JSON web token)"
        puts "    [q] Quit"

        input_option = gets.chomp

        if input_option == "1"
          recipes_index_action

        elsif input_option == "1.1"
          print "Enter a search term: "
          search_term = gets.chomp

          response = Unirest.get("https://enigmatic-shore-27070.herokuapp.com/recipes?search=#{search_term}")
          products = response.body
          puts JSON.pretty_generate(products)  

        elsif input_option == "1.2"
          response = Unirest.get("https://enigmatic-shore-27070.herokuapp.com/recipes?sort=chef")
          products = response.body
          puts JSON.pretty_generate(products) 
        elsif input_option == "1.3"
          response = Unirest.get("https://enigmatic-shore-27070.herokuapp.com/recipes?sort=prep_time")
          products = response.body
          puts JSON.pretty_generate(products) 
        elsif input_option == "2"
          recipes_show_action
        elsif input_option == "3"
          recipes_create_action
        elsif input_option == "4"
          recipes_update_action
        elsif input_option == "5"
          recipes_destroy_action
        elsif input_option == "signup"
          puts "Signup for a new account"
          puts
          client_params = {}

          print "Name: "
          client_params[:name] = gets.chomp

          print "Email: "
          client_params[:email] = gets.chomp

          print "Password: "
          client_params[:password] = gets.chomp

          print "Password Confirmation: "
          client_params[:password_confirmation] = gets.chomp

          json_data = post_request("/users", client_params) 
          puts JSON.pretty_generate(json_data)
        elsif input_option == "login"
          puts "Login"
          puts
          print "Email: "
          input_email = gets.chomp

          print "Password: "
          input_password = gets.chomp

          response = Unirest.post(
                                  "https://enigmatic-shore-27070.herokuapp.com/user_token",
                                  parameters: {
                                                auth: {
                                                      email: input_email,
                                                      password: input_password
                                                      }
                                              }
                                  )
          puts JSON.pretty_generate(response.body)
          jwt = response.body["jwt"]
          Unirest.default_header("Authorization", "Bearer #{jwt}")
        elsif input_option == "logout"
          jwt = ""
          Unirest.clear_default_headers
        elsif input_option == "q"
          puts "Thank you for using Josh's Cookbook"
          exit
        end
        gets.chomp
      end
    end

  private
    def get_request(url, client_params={})
      Unirest.get("https://enigmatic-shore-27070.herokuapp.com#{url}", parameters: client_params).body
    end

    def post_request(url, client_params={})
      Unirest.post("https://enigmatic-shore-27070.herokuapp.com#{url}", parameters: client_params).body
    end

    def patch_request(url, client_params={})
      Unirest.patch("https://enigmatic-shore-27070.herokuapp.com#{url}", parameters: client_params).body
    end

    def delete_request(url, client_params={})
      Unirest.delete("https://enigmatic-shore-27070.herokuapp.com#{url}", parameters: client_params).body
    end
  end
end
