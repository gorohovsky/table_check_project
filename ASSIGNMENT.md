# TableCheck Ruby Take-Home Test: Dynamic Pricing Engine
Take-home project for TableCheck's Ruby roles.

## Overview:
* Build a simple e-commerce platform with a dynamic pricing engine that adjusts product prices in real-time based on demand, inventory levels, and competitor prices. This assignment aims to evaluate your expertise in Ruby on Rails, database design, background processing, and API integration.

## Requirements:
### E-commerce Platform:
Create a basic e-commerce platform with the following features:
* Import products from CSV (name, category, qty, default price). The inventory CSV is [here](inventory.csv).
* Show product details (including the dynamic price).
* Place orders, where orders contain a list of products (ID, Qty, price per item). Successful order placements should decrease the inventory and fail if the inventory is low.
* A Dynamic Pricing Engine. Implement a pricing engine that adjusts product prices based on:
  * Demand: Increase price if the product is frequently added to carts or purchased.
  * Inventory Levels: Decrease price if inventory levels are high, and increase price if inventory levels are low.
  * Competitor Prices: Adjust prices based on competitor prices fetched from a separate service API, located at: https://sinatra-pricing-api.fly.dev/docs

This Competitor Price API (https://sinatra-pricing-api.fly.dev/docs) is a simulation of a realistic third party provider.

Write a clear and concise README documentation that includes:
* An overview of the E-commerce platform, and how the dynamic pricing works.
* All API endpoints, request/response formats, and examples of usage.
* A simple guide on how to set up and run the application locally.

## Technical Requirements:
### Backend:
* Use Ruby on Rails for the backend.
* Use MongoDB for the database.
* Implement background jobs (e.g., with Sidekiq) for updating prices periodically from the Competitor Price API, based on the pricing engine rules.
### Testing:
* Write unit and integration tests for key functionalities (RSpec or Minitest).
### Frontend:
* For the sake of simplicity, no UI is required, just the API.
### Evaluation Criteria:
1. Functionality: All required features are implemented and working correctly, and the Dynamic Pricing engine correctly adjusts prices based on the specified rules.
2. Code Quality: The code should be clean, well-organized, and follow best practices for Ruby on Rails development.
3. Testing: Comprehensive test coverage for key functionalities, quality, and clarity of test cases.
4. Performance: Efficient background processing for price updates.
5. Documentation: The documentation should be clear, concise, and informative, demonstrating the candidate's ability to communicate effectively with both internal and external stakeholders.

