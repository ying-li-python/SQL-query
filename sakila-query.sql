-- Using the sakila database from MySQL, let's query some data! 

-- Display the first and last names of each actor from table actor
SELECT 
    first_name, last_name
FROM
    actor; 

-- Display the first and last names of each actor in a single column called "Actor Name"
SELECT 
    CONCAT(first_name, ' ', last_name) AS 'Actor Name'
FROM
    sakila.actor;
    
-- Display the actor whose first name is "Joe"
SELECT 
    *
FROM
    sakila.actor
WHERE
    first_name = 'Joe';
    
-- Find all actors whose last name contains the letters "GEN"
SELECT 
    *
FROM
    sakila.actor
WHERE
    last_name LIKE '%GEN%';
    
-- Find all actors who last names contain the letters "LI", ordered by last and first name 
SELECT 
    *
FROM
    sakila.actor
WHERE
    last_Name LIKE '%LI%'
ORDER BY last_name ASC;

-- Display the country_id and country columns for Afghanistan, Bangladesh, and China
SELECT 
    *
FROM
    sakila.country
WHERE
    country IN ('Afghanistan' , 'Bangladesh', 'China');
    
-- Create a column called description in actor table and fill data values as BLOB
ALTER TABLE sakila.actor ADD description BLOB NOT NULL; 

-- Delete description column from actor table
ALTER TABLE sakila.actor DROP description;

-- List the last names of actors and the number of actors who have the same last name 
SELECT 
    last_name, COUNT(last_name) AS 'Count'
FROM
    sakila.actor
GROUP BY last_name;

-- List last names of actors and number of actors who have the same last name, but for names that are shared by at least 2 actors
SELECT 
    last_name, COUNT(last_name) AS 'Count'
FROM
    sakila.actor
GROUP BY last_name
HAVING COUNT(last_name) >= 2;

-- Update actor from "HARPO WILLIAMS" TO "GROUCHO WILLIAMS" 
UPDATE sakila.actor 
SET 
    first_name = 'HARPO'
WHERE
    first_name = 'Groucho'
        AND last_name = 'Williams'; 
        
-- Undo change, change actor from "GROUCHO WILLIAMS" to "HARPO WILLIAMS"
UPDATE sakila.actor 
SET 
    first_name = 'GROUCHO'
WHERE
    first_name = 'HARPO'
        AND last_name = 'Williams';

-- Show the address table
SHOW CREATE TABLE address;

-- Display first name, last name, address of each staff member using JOIN 
SELECT 
    first_name, last_name, a.address
FROM
    sakila.staff s
        JOIN
    sakila.address a ON (s.address_id = a.address_id);

-- Display the total amount by each staff member in August 2005 using JOIN
SELECT 
    s.first_name, s.last_name, SUM(p.amount) AS 'Total Amount'
FROM
    sakila.payment p
        JOIN
    sakila.staff s ON s.staff_id = p.staff_id
WHERE
    p.payment_date LIKE '2005-08-%'
GROUP BY s.staff_id; 

-- List each film and number of actors of that film
    SELECT 
    f.title AS 'Film Name',
    COUNT(fa.actor_id) AS 'Number of Actors'
FROM
    sakila.film_actor fa
        INNER JOIN
    sakila.film f ON fa.film_id = f.film_id
GROUP BY f.film_id;    

-- List number of copies for the film, "Hunchback Impossible", from the inventory table 
SELECT 
    f.title AS 'Film Name',
    COUNT(i.inventory_id) AS 'Number of Copies'
FROM
    sakila.inventory i
        JOIN
    sakila.film f ON f.film_id = i.film_id
WHERE
    f.title = 'Hunchback Impossible';

-- List total paid by each customer, and order by last name alphabetically 
SELECT 
    c.first_name,
    c.last_name,
    SUM(p.amount) AS 'Total Amount Paid'
FROM
    sakila.payment p
        JOIN
    sakila.customer c ON p.customer_id = c.customer_id
GROUP BY p.customer_id
ORDER BY last_name ASC;

-- Display titles of movies starting with the letters K and Q, whose language is English, using subquery
SELECT 
    title, language_id
FROM
    sakila.film
WHERE
    language_id IN (SELECT 
            language_id
        FROM
            sakila.language
        WHERE
            name = 'English')
        AND title LIKE 'K%'
        OR title LIKE 'Q%';

-- Display all actors in the film, "Alone Trip", using subqueries
SELECT 
    actor_id, first_name, last_name
FROM
    sakila.actor
WHERE
    actor_id IN (SELECT 
            actor_id
        FROM
            sakila.film_actor
        WHERE
            film_id IN (SELECT 
                    film_id
                FROM
                    sakila.film
                WHERE
                    title = 'Alone Trip'));

-- List names and email address of all Canadian customers
SELECT 
    cu.first_name, cu.last_name, cu.email, co.country
FROM
    sakila.customer cu
        JOIN
    sakila.address a ON (cu.address_id = a.address_id)
        JOIN
    sakila.city ci ON (ci.city_id = a.city_id)
        JOIN
    sakila.country co ON (co.country_id = ci.country_id)
WHERE
    co.country = 'Canada';

-- Display all movies categorized as Family films
SELECT 
    fca.film_id AS 'Family Film ID', f.title
FROM
    sakila.film f
        JOIN
    sakila.film_category fca ON (f.film_id = fca.film_id)
        JOIN
    sakila.category ca ON (ca.category_id = fca.category_id)
WHERE
    name = 'Family';

-- Display most frequently rented movies in descending order
SELECT 
    f.title, COUNT(r.rental_id) AS 'Movie_Rentals'
FROM
    film f
        JOIN
    sakila.inventory i ON (i.film_id = f.film_id)
        JOIN
    sakila.rental r ON (r.inventory_id = i.inventory_id)
GROUP BY f.title
ORDER BY Movie_Rentals DESC; 

-- Display total amount that each store brought in 
SELECT 
    s.store_id, SUM(p.amount) AS 'Total Business ($)'
FROM
    sakila.payment p
        JOIN
    sakila.staff s ON (p.staff_id = s.staff_id)
GROUP BY s.store_id;

-- Display each store's ID, city, and country
SELECT 
    s.store_id, ci.city, co.country
FROM
    sakila.store s
        JOIN
    sakila.address a ON (a.address_id = s.address_id)
        JOIN
    sakila.city ci ON (a.city_id = ci.city_id)
        JOIN
    sakila.country co ON (ci.country_id = co.country_id);

-- List top 5 genres by gross revenue in descending order
SELECT 
    ca.name, SUM(p.amount) AS 'Gross_Revenue'
FROM
    sakila.category ca
        JOIN
    sakila.film_category fca ON (ca.category_id = fca.category_id)
        JOIN
    sakila.inventory i ON (i.film_id = fca.film_id)
        JOIN
    sakila.rental r ON (r.inventory_id = i.inventory_id)
        JOIN
    sakila.payment p ON (r.rental_id = p.rental_id)
GROUP BY ca.name
ORDER BY Gross_Revenue DESC
LIMIT 5;

-- Create a view for top 5 genres by gross revenue 
CREATE VIEW top_5_genres AS
    SELECT 
        ca.name, SUM(p.amount) AS 'Gross_Revenue'
    FROM
        sakila.category ca
            JOIN
        sakila.film_category fca ON (ca.category_id = fca.category_id)
            JOIN
        sakila.inventory i ON (i.film_id = fca.film_id)
            JOIN
        sakila.rental r ON (r.inventory_id = i.inventory_id)
            JOIN
        sakila.payment p ON (r.rental_id = p.rental_id)
    GROUP BY ca.name
    ORDER BY Gross_Revenue DESC
    LIMIT 5;

-- Display the view
SELECT * FROM top_5_genres;

-- Delete the view
DROP VIEW top_5_genres;