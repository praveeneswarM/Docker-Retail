-- Initialize the Capsule Retail Dashboard Database
-- This script will run when the MySQL container starts for the first time

-- Create the database if it doesn't exist
CREATE DATABASE IF NOT EXISTS capsule_db;
USE capsule_db;

-- Create the capsule_user with proper permissions
CREATE USER IF NOT EXISTS 'capsule_user'@'%' IDENTIFIED BY 'secure_password_123';
GRANT ALL PRIVILEGES ON capsule_db.* TO 'capsule_user'@'%';
FLUSH PRIVILEGES;

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  email VARCHAR(100),
  password VARCHAR(255) NOT NULL,
  role VARCHAR(20) DEFAULT 'user',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_login TIMESTAMP NULL,
  INDEX idx_username (username),
  INDEX idx_role (role)
);

-- Inventory table
CREATE TABLE IF NOT EXISTS inventory (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  quantity INT NOT NULL DEFAULT 0,
  price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  category VARCHAR(50),
  supplier VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_category (category),
  INDEX idx_supplier (supplier),
  INDEX idx_quantity (quantity)
);

-- User activity table for logging
CREATE TABLE IF NOT EXISTS user_activity (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  activity_type VARCHAR(50),
  activity_description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_activity (user_id, created_at),
  INDEX idx_activity_type (activity_type)
);

-- Inventory logs table
CREATE TABLE IF NOT EXISTS inventory_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  inventory_id INT,
  action_type VARCHAR(20),
  old_quantity INT,
  new_quantity INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (inventory_id) REFERENCES inventory(id) ON DELETE CASCADE,
  INDEX idx_inventory_logs (inventory_id, created_at),
  INDEX idx_action_type (action_type)
);

-- Insert default admin user
INSERT IGNORE INTO users (username, email, password, role) VALUES 
('admin', 'admin@retaildashboard.com', 'admin123', 'admin');

-- Insert sample users
INSERT IGNORE INTO users (username, email, password, role, created_at, last_login) VALUES 
('john_doe', 'john@example.com', 'password123', 'user', DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 2 HOUR)),
('jane_smith', 'jane@example.com', 'password123', 'user', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 1 HOUR)),
('demo_user', 'demo@example.com', 'demo123', 'user', DATE_SUB(NOW(), INTERVAL 1 DAY), NOW());

-- Insert sample inventory items
INSERT IGNORE INTO inventory (name, quantity, price, category, supplier) VALUES 
('Laptop Computers', 15, 999.99, 'Electronics', 'Tech Supplier Inc'),
('Office Chairs', 8, 199.50, 'Furniture', 'Office Depot'),
('Wireless Mice', 3, 25.99, 'Electronics', 'Tech Supplier Inc'),
('Desk Lamps', 25, 45.00, 'Furniture', 'Furniture World'),
('USB Keyboards', 12, 35.75, 'Electronics', 'Tech Supplier Inc'),
('Coffee Makers', 2, 89.99, 'Appliances', 'Home Essentials'),
('Printer Paper', 30, 15.99, 'Office Supplies', 'Paper Co'),
('Bluetooth Speakers', 7, 79.99, 'Electronics', 'Audio Tech'),
('Standing Desks', 4, 299.99, 'Furniture', 'Ergonomic Solutions'),
('Water Bottles', 50, 12.99, 'Office Supplies', 'Eco Products'),
('Tablets', 1, 599.99, 'Electronics', 'Tech Supplier Inc'),
('Monitor Stands', 20, 89.50, 'Furniture', 'Office Depot'),
('Webcams', 9, 149.99, 'Electronics', 'Audio Tech'),
('Desk Organizers', 35, 19.99, 'Office Supplies', 'Paper Co'),
('Phone Chargers', 4, 29.99, 'Electronics', 'Tech Supplier Inc');

-- Insert sample user activity
INSERT IGNORE INTO user_activity (user_id, activity_type, activity_description, created_at) 
SELECT 
    u.id, 
    'LOGIN',
    CONCAT('User ', u.username, ' logged in'),
    DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 24) HOUR)
FROM users u;

-- Insert some inventory activity
INSERT IGNORE INTO user_activity (user_id, activity_type, activity_description, created_at) 
SELECT 
    u.id, 
    'INVENTORY_ADD',
    'Added new inventory item',
    DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 48) HOUR)
FROM users u 
WHERE u.role = 'user'
LIMIT 5;

-- Print setup completion message
SELECT 'Database initialization completed successfully!' AS message;