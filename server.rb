require "sinatra"
require "json"
set :public_folder => '.'

get "/test" do
  data = []
  100.times do |i|
    data << { 
      :check_column => (i % 2 == 0 ? true : false),
      :text_column => "text column",
      :number_column => i,
      :string_column => "string column",
      :date_column => "2014-01-01",
      :boolean_column => true
    }
  end

  { :total => 100, :data => data, :success => true }.to_json
end
