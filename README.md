### Currently Limited Functionality

Available here: [Deploy Vapor Dammit](https://deployvapordammit.herokuapp.com/)

Only accepts `POST` requests to `/catDB/create` with a `JSON` body that matches: 

```
{
   "cat_id": <int value>,
   "cat_name": <string value>,
   "cat_breed": <string value>
}
```

`cat_id` does not autoincrement/generate and is the DB's primary key. You may get an error if attempting to use a low int value. 

### TODO:

- Instructions of how this was setup along w/ links to resources used
