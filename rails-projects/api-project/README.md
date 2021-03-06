**Table of Contents**

[TOC]

### Requirements
installed posgresql
https://www.postgresql.org/download/


### Step 1
`$ rails new api-project --api --no-sprockets -d postgresql`
> Create API project with "api-project" name, NO Asset Pipeline, use Postgresql instead of sqlite.

### Step 2
`$ rails (generate/g) model contact`
> It will generate "contact.rb" in app/models folder and migration file in db/migrate folder
![](https://github.com/Nemrosim88/learn-ruby-projects/raw/master/rails-projects/api-project/read-me-images/2019-08-31_14-04-30.jpg)

### Step 3
> Add three new field to migration file with type string

```ruby
class CreateContacts < ActiveRecord::Migration[6.0]
  def change
    create_table :contacts do |t|
      t.string :first_name
      t.string :last_name
      t.string :email

      t.timestamps
    end
  end
end
```
![](https://github.com/Nemrosim88/learn-ruby-projects/raw/master/rails-projects/api-project/read-me-images/2019-08-31_14-20-14.jpg)

### Step 4
> If there is not installed and started postgresql servers - install and start it

### Step 5
> In pgAdmin create new database - api_project_development
![](https://github.com/Nemrosim88/learn-ruby-projects/raw/master/rails-projects/api-project/read-me-images/ps-bd-create.jpg)
![](https://github.com/Nemrosim88/learn-ruby-projects/raw/master/rails-projects/api-project/read-me-images/ps-db-create-save.jpg)

### Step 6
> Add username and password to "database.yml" file in /config folder

```ruby
development:
  <<: *default
  database: api_project_development
  username: postgres
  password: admin
```

### Step 7
`$ rails db.migrate`
> It will create "contacts" table in "api_project_development" database
![](https://github.com/Nemrosim88/learn-ruby-projects/raw/master/rails-projects/api-project/read-me-images/ps-created-db.jpg)

> And will change "db/schema.rb" file:

```ruby
ActiveRecord::Schema.define(version: 2019_08_31_104724) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contacts", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
```

### Step 8 VALIDATIONS
> Add validations to "contact.rb" file

```ruby
class Contact < ApplicationRecord
  validates :first_name, presence: true, length: { minimum: 3, maximum: 15 }
  validates :last_name, presence: true, length: { minimum: 3, maximum: 15 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
```

### Step 8 VALIDATIONS ERROR MESSAGES
> Add custom error messages for validations to "en.yml" file

```ruby
en:
  activerecord:
    attributes:
      contact:
        first_name: "First name"
        last_name: "Last name"
        email: "E-mail address"
    errors:
      models:
        contact:
          attributes:
            email:
              blank: "Email can't be black"
              invalid: "Please, enter valid email"
            first_name:
              blank: "First name can't be black"
              too_short: "The first name must have at least %{count} characters."
              too_long: "The first name must have no more than %{count} characters."
            last_name:
              blank: "Last name can't be black"
              too_short: "The last name must have at least %{count} characters."
              too_long: "The last name must have no more than %{count} characters."
```

### Step 8
`$ rails g controller v1/contacts`
> It will generate "app/controllers/v1/contacts_controller.rb" file with V1::ContactsController class in it.

```ruby
class V1::ContactsController < ApplicationController
end
```

### Step 9
> Add index method to \controllers\v1\contacts_controller.rb file.

```ruby
class V1::ContactsController < ApplicationController
  def index
    @contacts = Contact.all
    
    # It will return "contacts" in json format
    # RAILS STATUS CODES http://billpatrianakos.me/blog/2013/10/13/list-of-rails-status-code-symbols/
    render json: @contacts, status: :ok
    # OR same line
    # render json: { data: @contacts, status: 200 }
  end
end
```

### Step 10
> Add lines config/routes.rb:

```ruby
Rails.application.routes.draw do
  # This means that our endpoints will start from /v1/...
  # Example: http://localhost:3000/v1/contacts
  namespace :v1 do
    resources :contacts
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
```

### Step 11
`$ rails routes | grep contacts`
> Will show routes (end-points) to contacts. Example:

 v1_contacts
 
    | method            route                               controller#method
    | GET         /v1/contacts(.:format)                 v1/contacts#index
    | POST       /v1/contacts(.:format)                 v1/contacts#create
    | GET         /v1/contacts/:id(.:format)            v1/contacts#show
    | PATCH    /v1/contacts/:id(.:format)            v1/contacts#update
    | PUT         /v1/contacts/:id(.:format)            v1/contacts#update
    | DELETE    /v1/contacts/:id(.:format)            v1/contacts#destroy

    
### Step 12
`$ rails server`
or
`$ rails s`
> Will start the rails application

### Step 13
> If you type in browser url http://localhost:3000/v1/contacts, you show see an empty array [] if everything works properly.

### Step 14. Adding admin page using rails_admin gem

#### Step 1
> Add to gemfile:

```ruby
group :development do
  gem 'rails_admin', '~> 2.0'
end
```

#### Step 2
`$ bundle install`

#### Step 3
`$ rails g rails_admin:install`

#### Step 4
> Type route name for admin page, for example "admin", so that if tou type in browser http://localhost:3000/admin
admin page generated by rails_admin will appear

#### Step 5
> Add configuration to "application.rb" file:


```ruby
module ApiProject
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # ADDED FOR rails_admin gem
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Flash
    config.middleware.use Rack::MethodOverride
    config.middleware.use ActionDispatch::Session::CookieStore, key: '_api_project_session'

    ...
```

### Step 15. Adding gem 'rack-cors'
> Add gem 'rack-cors' to Gemfile and configuration to "application.rb" file

```ruby
    # ADDED FOR rack-cors
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: %i[get post patch put delete options]
      end
    end
```

# ADDING USERS

## Step 1 Generate migration file
`$ rails g migration create_users`

`$ rails g migration add_user_id_to_contacts`

## Step 2 Code modifications
> 'contact' model

```ruby
   class Contact < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true
  validates :first_name, presence: true, length: { minimum: 3, maximum: 15 }
  validates :last_name, presence: true, length: { minimum: 3, maximum: 15 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
```

## Step 3 Code modifications
> User model

```ruby
   class User < ApplicationRecord
  
  has_many :contacts
  # Before saving convert email value to lowercase
  before_save { self.email = email.downcase }

  validates :name, presence: true, length: { minimum: 3, maximum: 25 }
  validates :surname, presence: true, length: { minimum: 3, maximum: 15 }
  validates :patronymic, presence: true, length: { minimum: 3, maximum: 15 }
  validates :nickname,
            presence: true,
            # "joe" and "Joe" can be created.
            # uniqueness: true,
            # Solution:
            uniqueness: { case_sensitive: false },
            length: { minimum: 3, maximum: 15 }
  validates :phone, presence: true, length: { minimum: 3, maximum: 15 }
  # VALID_EMAIL_REGEXP = /\A.....some regexp...z\/i
  validates :email,
            presence: true,
            length: { minimum: 3, maximum: 105 },
            format: { with: URI::MailTo::EMAIL_REGEXP },
            # You can add custom regexp
            # format: { with: VALID_EMAIL_REGEXP },
            uniqueness: { case_sensitive: false }
  # Will automatically convert password to hash
  has_secure_password
end
```

# ADDING BCRYPT

# ADDING JWT


