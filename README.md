ReDI Project API client
=======================

This API client gem allows you to interact with the
ReDI projects sample project used in the ReDI school
class projects.

## To install

Add the `redi` gem to your Gemfile:

```Gemfile
gem 'redi', :git => 'git://github.com/refugeesonrails/redi-gem.git'
```

## Usage

Before you can use the gem, you need to configure the authentication.
You get your auth token from your instructor. In the following example,
I will assume your auth token is `XXXX` (it certainly won't be that in
real life!).

The following is a brief example showing some simple ways
in which the API client can be used:

```ruby
# The gem is automatically included in your rails project, but
# if you run a standalone ruby project, you need to require it:
require 'redi'

# Before using the client, you need to configure it with
# you auth token:
ReDI::API.configure(auth: "XXXX")

all_projects = ReDI::Project.all # All projects
my_projects = ReDI::Project.mine # Only projects created by you

project = my_projects.first
puts "My project is called #{project.name} and does the following: #{project.description}"
puts "On the main server my project has the following id: #{project.server_id}"

new_project = ReDI::Project.new(name: "My new project", description: "It does ...")
new_project.server_id # Returns nil, since the project hasn't been saved yet
new_project.save
new_project.server_id # Now returns an ID

other_project = ReDI::Project.create(name: "My other project")
puts other_project.error # Will have errors because we didn't provide a description
other_project.description = "The missing description"
other_project.save # Now works
other_project.destroy # Removes the project from the main project repository

# You can add and remove your vote on a project with `vote` and `unvote`
some_project = all_projects.sample
some_project.vote # Adds your vote
some_project.unvote # Removes your vote again
```
