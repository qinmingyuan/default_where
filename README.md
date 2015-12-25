## DefaultWhere

This Library set default params process for where query in ActiveRecord

## Features and Usage

### Normal equal params

- Params:
```ruby
{ "role_id" => "1", "age" => "20" }
```
- Before use default_where:
```ruby
User.where(role_id: params['role_id'], age: params['age'])
```
- after Use default_where:
```ruby
User.default_where(params)
```

### Equal params with association

- params
```ruby
{ 'role_id' => 1, 'student-teacher_id' => 2 }
```
- Before use `default_where`
```ruby
User.includes(:student).where(role_id: params['role_id'], student: {teacher_id: params['student-teacher_id']})
```
- After Use `default_where`
```ruby
User.default_where(params)
```

### Range params
- params
```ruby
{ 'role_id-lte': 2 }
```
- Before use `default_where`
```ruby
User.where('role_id >= ?', 2)
```
- After use `default_where`
```ruby
User.default_where(params)
```

### Auto remove blank params by default, no need write query with `if else`
- Before use `default_where`
```ruby
users = User.where(role_id: params['role_id'])
users = users.where(age: params['age']) if params['age']
```
- After use `default_where`
```ruby
User.default_where(params)
```

### Order params
- Params
```ruby
{ 'role_id': 1, 'o1': 'age+asc', 'o2': 'last_login_at+asc' }
```
- Before use `default_where`
```ruby
User.where(role_id: params['role_id']).order(age: :asc, last_login_at: :asc)
```
- After use `default_where`
```ruby
User.default_where(params)
```

## A sample with all params above
- Params
```ruby
{ 'role_id' => 1, 'student-teacher_id' => 2, 'role_id-lte': 2, 'o1': 'age+asc', 'o2': 'last_login_at+asc' }
```
- Before use `default_where`
```ruby
User.includes(:student).where(role_id: params['role_id'], student: {teacher_id: params['student-teacher_id']}).order(age: :asc, last_login_at: :asc)
```
- After use `default_where`
```ruby
User.default_where(params)
```

It will generate the query scope to above
params must use string key
