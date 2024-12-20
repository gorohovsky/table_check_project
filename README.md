# Project Overview

This project was developed as a response to [the evaluation task from TableCheck](ASSIGNMENT.md).

It consists of several main components:

- **Products API**: allows importing products from a CSV file and displaying them.
- **Carts API**: allows adding products to carts and displaying their contents.
- **Orders API**: handles order placement and displaying orders.
- **Background jobs**: 
  - for checking competitor prices periodically.
  - for controlling product demand levels.

## Dynamic Pricing Engine Overview

- **_Demand and stock-based price adjustments_**

  There are two factors that impact a product's dynamic price: demand and stock level. The rules are:

  - Each time a product is _**added to a cart**_, its demand level increases by 1 point.

  - Each time a product is _**purchased**_, its demand level increases by 10 points, and its stock is reduced by the quantity of items purchased.

  - The higher the demand and the lower the stock, the higher the dynamic price. And vice versa.

- **_Demand assessment_**

  Once per hour, product demand is evaluated, and based on its level, the following adjustments are made:
    - High demand (10+ purchases/24 hours): No decay.
    - Medium demand (4-9 purchases/24 hours): Low decay (-2 demand points).
    - Low demand (1-3 purchases/24 hours): Medium decay (-5 demand points).
    - No demand (0 purchases/24 hours): High decay (-10 demand points).

- **_Competitor-based price adjustments_**

  Every 30 minutes the competitor's prices are checked and stored. The product dynamic price is based on the following rules:
    1. The price, calculated from demand and stock levels, should never exceed the competitor's price or the price cap, which is set as product's default price multiplied by 1.3.
    2. The price should never fall below the product's default price.
    3. If competitor's price is lower than product's default price, the second rule comes into play.

# Deployment

### Prerequisites

- Ruby 3.3.5
- Bundler 2.5.21
- Docker

### 1. Install gems

```bash
bundle install
```

### 2. Database setup

Generate a key for MongoDB:

```bash
openssl rand -base64 756 > mongo.key
chmod 400 mongo.key
chown 999:999 mongo.key
```

Run MongoDB and Redis:

```bash
docker compose up
```

Create databases for both the development and test environments:

```bash
rails db:setup
RAILS_ENV=test rails db:setup
```

### 3. Environment variables

Set them in the `.env` file (a [template](.env.template) is provided) or in the environment itself:

```bash
COMPETITOR_URL
REDIS_URL
```

### 4. Start Sidekiq

```bash
sidekiq
```

Now you should be all set to run the application using `rails s` or use RSpec.


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

>*Note: [Here](inventory.csv) is a CSV file with randomized product default prices and quantities for easier dynamic pricing testing.*

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
curl --location --request PUT 'localhost:3000/carts/add_product?product_id=674854ad5c0d64495811b3a2&quantity=30&cart_id=67485cb1000cd84fb22e6cfb'
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
