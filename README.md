## DefaultWhere

This Library set default params process for where query in ActiveRecord

## Usage

- Before use default_where

```ruby
#  Parameters: {"role_id"=>"1", "age"=>"20", "teacher_id"=> "2"}
User.includes(:student).where(role_id: params[:role_id], age: params[:age], student: {teacher_id: params[:teacher_id]})

```

- after Use default_where

params must use string key

```ruby
User.default_where(params, student: :teacher_id)

# It will generate the query scope to above
```

## Features
- remove blank where query, need not write where query like this

```ruby
# if not remove blank query params
users = Users.where(role_id: params[:role_id])
users = users.where(age: params[:age]) if params[:age]
```


