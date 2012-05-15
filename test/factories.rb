FactoryGirl.define do
  sequence :name do |n|
    "name_#{n}"
  end

  sequence :uid do |n|
    "11#{n}"
  end

  factory :user do
    username { Factory.next :name }
  end

  factory :role do
    name { Factory.next :name }
  end
end
