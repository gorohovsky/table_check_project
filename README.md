# Project Overview

This project was developed as a response to [the evaluation task from TableCheck](ASSIGNMENT.md).

It consists of several main components:

- **Products API**: allows importing products from a CSV file and displaying them.
- **Carts API**: allows adding products to carts and displaying their contents.
- **Orders API**: handles order placement and displaying orders.
- **Background jobs**: 
  - for checking competitor prices periodically.
  - for controlling product demand levels.

## High-Level Dynamic Pricing Engine Overview

- **Demand and stock-based price adjustments**: 
  - Every time a product is added to a cart or purchased, its demand increases, causing its price to rise.
  - Purchases not only increase demand but also decrease stock. Both factors impact the price increase.

- **Competitor-based price adjustments**: 
  - Every 30 minutes the competitor's prices are checked.
  - Product prices are adjusted based on the following rules:
    1. Price, calculated from demand and stock levels, should never exceed the competitor's price or the price cap, which is set as product's default price multiplied by 1.3.
    2. Price should never fall below product default price.
    3. If competitor's price is lower than default product's price, the second rule comes into play.

- **Demand assessment**: 
  - Once per hour, product demand is evaluated. If demand declines, product price will be reduced.

# Deployment

### Prerequisites

- Ruby 3.3.5
- Bundler 2.5.21
- Docker

### 1. Pull the required Docker images for MongoDB and Redis

```bash
docker pull mongo:7.0.15
docker pull redis
```

### 2. Install gems

```bash
bundle install
```

### 3. Database setup

Generate a key for MongoDB:

```bash
openssl rand -base64 756 > mongo.key
chmod 400 mongo.key
chown 999:999 mongo.key
```

Run MongoDB:

```bash
docker run --rm \
  -p 27017:27017 \
  -v mongo_data:/data/db \
  -v ./mongo.key:/data/mongo.key:ro \
  -e MONGO_INITDB_ROOT_USERNAME=root \
  -e MONGO_INITDB_ROOT_PASSWORD=root \
  -e MONGO_REPLSET=rs0 \
  --name mongo mongo:7.0.15 \
  --replSet 'rs0' \
  --keyFile /data/mongo.key \
  --bind_ip_all
```

Once MongoDB is running, initialize a replica set (required for transactions to work):

```bash
docker exec -it mongo mongosh \
  -u root -p root \
  --authenticationDatabase admin \
  --eval 'rs.initiate({_id: "rs0", members: [{_id: 0, host: "localhost:27017"}]})'
```

Create databases for both the development and test environments:

```bash
rails db:setup
RAILS_ENV=test rails db:setup
```

### 4. Environment variables

Set them in the `.env` file (a template is provided) or in the environment itself:

```bash
COMPETITOR_URL
REDIS_URL
```

### 5. Run Redis for background job processing and caching competitor prices

```bash
docker run -p 6379:6379 --rm --name redis redis
```

### 6. Start Sidekiq

```bash
sidekiq
```

Now you should be all set to run the Rails server using `rails s` or use RSpec.


# cURL Samples

### Products API

>*Note: For testing convenience, the Products API also returns additional attributes.*

- **Get all products**

```bash
curl --location 'localhost:3000/products/'
```

Response (partial):

```json
[
  {
    "id": "6748830e4225901025d7be59",
    "name": "MC Hammer Pants",
    "category": "Footwear",
    "stock": 285,
    "default_price": "30.05",
    "competing_price": "30.05",
    "price": "30.05",
    "demand": 10
  },
  ...
]
```


- **Get a specific product**

```bash
curl --location 'localhost:3000/products/6748830e4225901025d7be59'
```

Response:

```json
{
  "id": "6748830e4225901025d7be59",
  "name": "MC Hammer Pants",
  "category": "Footwear",
  "stock": 195,
  "default_price": "30.05",
  "competing_price": "30.05",
  "price": "30.05",
  "demand": 90
}
```


- **Import products from CSV**

```bash
curl --location 'localhost:3000/products/import' \
--form 'csv=@"/table_check_engine/inventory.csv"'
```

Response (partial):

```json
[
  {
    "id": "6748830e4225901025d7be59",
    "name": "MC Hammer Pants",
    "category": "Footwear",
    "stock": 285,
    "default_price": "30.05"
  },
  ...
]
```


### Carts API

- **Get a specific cart**

```bash
curl --location 'localhost:3000/carts/67485cb1000cd84fb22e6cfb'
```

Response:

```json
{
  "id": "67485cb1000cd84fb22e6cfb",
  "products": [
    {
      "product_id": "674854ad5c0d64495811b3a3",
      "quantity": 10
    },
    {
      "product_id": "674854ad5c0d64495811b3a2",
      "quantity": 30
    }
  ],
  "total": "947.80"
}
```

- **Add a product to a cart**

>*Note: The "cart_id" parameter here is optional. If it's not provided, a new cart is created automatically.*

```bash
curl --location --request POST 'localhost:3000/carts/add_product?product_id=674854ad5c0d64495811b3a2&quantity=30&cart_id=67485cb1000cd84fb22e6cfb'
```

Response:

```json
{
   "id": "67485cb1000cd84fb22e6cfb",
   "products": [
       {
           "product_id": "674854ad5c0d64495811b3a3",
           "quantity": 10
       },
       {
           "product_id": "674854ad5c0d64495811b3a2",
           "quantity": 30
       }
   ],
   "total": "947.80"
}
```


### Orders API

- **Get all orders**

```bash
curl --location 'localhost:3000/orders'
```

Response (partial):

```json
[
  {
    "id": "6748f8fed438c78c39a62ef8",
    "products": [
      {
        "product_id": "6748830e4225901025d7be5b",
        "product_name": "Thriller Jacket",
        "quantity": 10,
        "price": "15.11"
      }
    ],
    "total": "151.10"
  },
  ...
]
```

- **Get a specific order**

```bash
curl --location 'localhost:3000/orders/6748f8fed438c78c39a62ef8'
```

Response:

```json
{
  "id": "6748f8fed438c78c39a62ef8",
  "products": [
    {
      "product_id": "6748830e4225901025d7be5b",
      "product_name": "Thriller Jacket",
      "quantity": 10,
      "price": "15.11"
    }
  ],
  "total": "151.10"
}
```

- **Create an order**

```bash
curl --location --globoff --request POST 'localhost:3000/orders?order[products][][id]=6748830e4225901025d7be59&order[products][][qty]=7&order[products][][id]=6748830e4225901025d7be60&order[products][][qty]=9'
```

Response:

```json
{
  "id": "674a2aa85a4abce3f100455b",
  "products": [
    {
      "product_id": "6748830e4225901025d7be59",
      "product_name": "MC Hammer Pants",
      "quantity": 7,
      "price": "36.06"
    },
    {
      "product_id": "6748830e4225901025d7be60",
      "product_name": "Care Bears Sweater",
      "quantity": 9,
      "price": "42.45"
    }
  ],
  "total": "634.47"
}
```
