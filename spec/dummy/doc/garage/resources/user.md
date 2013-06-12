## GET /users
Returns users

```
GET /users
```

### response
```
Status: 200
response: 
[
  {
    "created_at" => "2013-06-11T17:48:09Z",
            "id" => 1077,
          "name" => "name 15",
    "properties" => {},
    "updated_at" => "2013-06-11T17:48:09Z"
  }
]
```


## GET /users/:id
Returns the user

```
GET /users/1078
```

### response
```
Status: 200
response: 
{
  "created_at" => "2013-06-11T17:48:09Z",
          "id" => 1078,
        "name" => "name 16",
  "properties" => {},
  "updated_at" => "2013-06-11T17:48:09Z"
}
```


## POST /users
Creates a new user

```
POST /users
```

### parameters
* `name` string (required)


### response
```
Status: 201
location: http://www.example.com/users/1079
response: 
{
  "created_at" => "2013-06-11T17:48:09Z",
          "id" => 1079,
        "name" => "name",
  "properties" => {
    "description" => "description"
  },
  "updated_at" => "2013-06-11T17:48:09Z"
}
```


## PUT /users/:id
Updates the user

```
PUT /users/1080
```

### parameters
* `name` string


### response
```
Status: 204
response: 
```


