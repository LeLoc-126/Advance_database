USE sakila;

# 1 Find the 10 most rented movies in February 2006
SELECT f.title, COUNT(r.rental_id) AS rental_count
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE DATE_FORMAT(r.rental_date, '%Y-%m') = '2006-02'
GROUP BY f.title
ORDER BY rental_count DESC
LIMIT 10;

#. 2 Provide a list of stores and the total number of rented movie discs of each store 
# in February 2006, the list is arranged in descending order
SELECT s.store_id, COUNT(r.rental_id) AS total_rentals
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN store s ON i.store_id = s.store_id
WHERE DATE_FORMAT(r.rental_date, '%Y-%m') = '2006-02'
GROUP BY s.store_id
ORDER BY total_rentals DESC;

# 3 Find movies whose title contains the word 'dinosaur' at the store with ID 1.
SELECT f.title
FROM film f
JOIN inventory i ON f.film_id = i.film_id
WHERE i.store_id = 1
  AND f.title LIKE '%dinosaur%';

# 4 Provide a list of movies where the words 'drama' and 'teacher' appear in the
# description using FTS
ALTER TABLE film ADD FULLTEXT(description);
SELECT title, description
FROM film
WHERE MATCH(description) AGAINST('+drama +teacher' IN BOOLEAN MODE);

# 5 Add to the inventory table the is_available column of type Boolean or
# tinyint(1):
#Creating a trigger on the rental table does the following:
# When the disc is rented, the is_available value is updated to false
# When the disc is returned, the is_available value is updated to true.
ALTER TABLE inventory ADD is_available TINYINT(1);
DELIMITER //

CREATE TRIGGER after_rental_insert
AFTER INSERT ON rental
FOR EACH ROW
BEGIN
    UPDATE inventory
    SET is_available = FALSE
    WHERE inventory_id = NEW.inventory_id;
END; //

DELIMITER ;

DELIMITER //

CREATE TRIGGER after_rental_delete
AFTER DELETE ON rental
FOR EACH ROW
BEGIN
    UPDATE inventory
    SET is_available = TRUE
    WHERE inventory_id = OLD.inventory_id;
END; //

DELIMITER ;

INSERT INTO rental (rental_date, inventory_id, customer_id, staff_id)
VALUES (NOW(), 1, 1, 1);

SELECT inventory_id, is_available FROM inventory WHERE inventory_id = 1;
DELETE FROM rental WHERE inventory_id = 1 AND customer_id = 1;
SELECT inventory_id, is_available FROM inventory WHERE inventory_id = 1;

# 6  a view named actor_list with an additional field to store participated
# films using the group_concat function
CREATE VIEW actor_list AS
SELECT 
    a.actor_id,
    a.first_name,
    a.last_name,
    GROUP_CONCAT(f.title ORDER BY f.title SEPARATOR ', ') AS participated_films
FROM 
    actor a
JOIN 
    film_actor fa ON a.actor_id = fa.actor_id
JOIN 
    film f ON fa.film_id = f.film_id
GROUP BY 
    a.actor_id;


SELECT * FROM actor_list;
