USE sakila;

#1: Create a compound index on the last_name and first_name columns in the actor
# table. Perform some queries and check with explain select commands

CREATE INDEX idx_actor_name ON actor(last_name, first_name);

SELECT actor_id, first_name, last_name 
FROM actor 
WHERE last_name = 'WAHLBERG';

SELECT actor_id, first_name, last_name 
FROM actor 
WHERE last_name = 'WAHLBERG' AND first_name = 'MARK';

EXPLAIN SELECT actor_id, first_name, last_name 
FROM actor 
WHERE last_name = 'WAHLBERG';

EXPLAIN SELECT actor_id, first_name, last_name 
FROM actor 
WHERE last_name = 'WAHLBERG' AND first_name = 'MARK';

#2  Find movies rented in February 2006. Use explain select to check if the query is
# optimized and find a way to optimize it.
SELECT film.title, rental.rental_date
FROM rental
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film ON inventory.film_id = film.film_id
WHERE rental.rental_date BETWEEN '2006-02-01' AND '2006-02-28';

EXPLAIN SELECT film.title, rental.rental_date
FROM rental
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film ON inventory.film_id = film.film_id
WHERE rental.rental_date BETWEEN '2006-02-01' AND '2006-02-28';

CREATE INDEX idx_rental_date ON rental(rental_date);

#3 Full Text Search
# a. Find movies where the word 'drama' appears but the word 'teacher' doesn’t
# appear in descriptions

SELECT title, description
FROM film
WHERE MATCH(description) AGAINST('+drama -teacher' IN BOOLEAN MODE);

# b. Find movies where the phrase ‘Emotional Drama’ appears in descriptions.

SELECT title, description
FROM film
WHERE MATCH(description) AGAINST('"Emotional Drama"' IN BOOLEAN MODE);

#4 Partitioning the customer table into 5 partitions using the hash type on the
#customer_id. Check the partitioning information from the
# INFORMATION_SCHEMA.PARTITIONS table.

CREATE TABLE customer_new
PARTITION BY HASH(customer_id)
PARTITIONS 5
AS
SELECT * FROM customer;

SELECT PARTITION_NAME, TABLE_NAME, PARTITION_METHOD, PARTITION_ORDINAL_POSITION, TABLE_ROWS
FROM INFORMATION_SCHEMA.PARTITIONS
WHERE TABLE_SCHEMA = 'sakila' AND TABLE_NAME = 'customer_new';

#5 Partitioning the rental table based on the year of rental_date. Find rentals in 2007
# and check this query using explain select.
CREATE TABLE rental_new (
    rental_id INT NOT NULL AUTO_INCREMENT,
    rental_date DATETIME NOT NULL,
    inventory_id INT NOT NULL,
    customer_id INT NOT NULL,
    return_date DATETIME DEFAULT NULL,
    staff_id INT NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (rental_id, rental_date),  -- Sửa: thêm rental_date vào PRIMARY KEY
    INDEX idx_fk_inventory_id (inventory_id),
    INDEX idx_fk_customer_id (customer_id),
    INDEX idx_fk_staff_id (staff_id)
)
PARTITION BY RANGE (YEAR(rental_date)) (
    PARTITION p_2007 VALUES LESS THAN (2008),
    PARTITION p_2008 VALUES LESS THAN (2009),
    PARTITION p_2009 VALUES LESS THAN (2010),
    PARTITION p_2010 VALUES LESS THAN (2011)
);
INSERT INTO rental_new (rental_id, rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
SELECT rental_id, rental_date, inventory_id, customer_id, return_date, staff_id, last_update
FROM rental;
SELECT * FROM rental_new
WHERE YEAR(rental_date) = 2007;
EXPLAIN SELECT * FROM rental_new
WHERE YEAR(rental_date) = 2007;
ALTER TABLE rental_new
    ADD PARTITION (PARTITION p_2012 VALUES LESS THAN (2013));
    
SELECT PARTITION_NAME, TABLE_NAME, PARTITION_METHOD, SUBPARTITION_METHOD, PARTITION_ORDINAL_POSITION, TABLE_ROWS
FROM INFORMATION_SCHEMA.PARTITIONS
WHERE TABLE_SCHEMA = 'sakila' AND TABLE_NAME = 'rental_new';


INSERT INTO rental_new (rental_date, inventory_id, customer_id, return_date, staff_id, last_update)
VALUES
('2012-01-15 10:30:00', 1, 1, '2012-01-15 12:30:00', 1, CURRENT_TIMESTAMP),
('2012-05-20 14:00:00', 2, 2, '2012-05-20 16:00:00', 2, CURRENT_TIMESTAMP),
('2012-09-10 09:45:00', 3, 3, '2012-09-10 11:45:00', 1, CURRENT_TIMESTAMP);

SELECT * FROM rental_new
WHERE YEAR(rental_date) = 2012;


select distinct year(rental_date) from rental;







