require 'rubygems'
require 'httparty'

class ReDI
  class API
    # This really is just a convenience method to make
    # the API nicer to configure... You could just
    # as well use the ReDI::Project.configure, but
    # well... then it looks less like an API...
    def self.configure options = {}
      ReDI::Project.configure options
      :ok
    end
  end

  class Project
    attr_accessor :name, :description
    attr_reader :votes, :creator, :server_id, :error

    def self.configure options = {}
      @@auth = options.delete(:auth)
      raise "Please provide an auth token" unless @@auth
      @@url = options.delete(:url) || "http://redi-projects.probsteide.com"
    end

    def self.all
      response = HTTParty.get(url("projects.json"))
      project_jsons = JSON.parse(response.body)
      self.setup_from_json project_jsons
    end

    def self.mine
      response = HTTParty.get(url("projects/mine.json"), headers: {"Auth-Token" => @@auth})
      project_jsons = JSON.parse(response.body)
      self.setup_from_json project_jsons
    end

    def initialize values = {}
      @name = values.delete(:name)
      @description = values.delete(:description)
    end

    def self.create values = {}
      p = Project.new(values)
      p.save
      p
    end

    def save
      body = {
        description: @description,
        name: @name
      }
      if @server_id
        # This is an existing object, let's update it
        response = HTTParty.put(
          Project.url("project/#{@server_id}.json"),
          body: body.to_json,
          headers: {"Auth-Token" => @@auth}
        )
        digest_response(response)
      else
        # This seems to be a new object, create it
        # This is an existing object, let's update it
        response = HTTParty.post(
          Project.url("project.json"),
          body: body.to_json,
          headers: {"Auth-Token" => @@auth}
        )
        digest_response(response) do |json|
          @server_id = json["id"]
        end
      end
    end

    def destroy
      if @server_id
        # This is an existing object, let's update it
        response = HTTParty.delete(Project.url("project/#{@server_id}.json"), headers: {"Auth-Token" => @@auth})
        digest_response(response) do
          # If this project has been destroyed,
          # then we need to remove the server ID.
          # Saving it should create a new object.
          @server_id = nil
        end
      else
        raise "Cannot destroy project which hasn't been created"
      end
    end

    def vote
      if @server_id
        response = HTTParty.put(Project.url("project/#{@server_id}/vote.json"), headers: {"Auth-Token" => @@auth})
        digest_response(response)
      else
        raise "Cannot vote on a project which hasn't been created"
      end
    end

    def unvote
      if @server_id
        response = HTTParty.put(Project.url("project/#{@server_id}/unvote.json"), headers: {"Auth-Token" => @@auth})
        digest_response(response)
      else
        raise "Cannot vote on a project which hasn't been created"
      end
    end

    def setup_internal json
      @server_id = json["id"]
      @votes = json["votes"]
      @creator = json["creator"]
    end

  private
    def digest_response response
      response_json = JSON.parse(response.body)
      if response_json["success"] == true
        yield response_json if block_given?
        true
      else
        @error = response_json["description"]
        false
      end
    end

  protected
    def self.setup_from_json project_jsons
      project_jsons.each.map do |json|
        project = Project.new(name: json["name"], description: json["description"])
        project.setup_internal json
        project
      end
    end

    def self.url path
      @@url + "/" + path
    end
  end
end
