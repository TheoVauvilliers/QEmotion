class User < ApplicationRecord
    require 'bcrypt'
    has_many :url

    has_secure_password
end