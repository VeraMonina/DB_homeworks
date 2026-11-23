DELIMITER //

CREATE PROCEDURE get_popular_films(
    IN p_category_name VARCHAR(25),
    IN p_min_rentals INT
)
BEGIN
    SELECT f.title,
           COUNT(DISTINCT r.rental_id) AS rental_count,
           SUM(p.amount) AS total_revenue
    FROM category AS cat
    JOIN film_category AS fc ON cat.category_id = fc.category_id
    JOIN film AS f ON fc.film_id = f.film_id
    JOIN inventory AS i ON f.film_id = i.film_id
    JOIN rental AS r ON i.inventory_id = r.inventory_id
    JOIN payment AS p ON r.rental_id = p.rental_id
    WHERE cat.name = p_category_name
    GROUP BY f.film_id, f.title
    HAVING COUNT(DISTINCT r.rental_id) >= p_min_rentals
    ORDER BY rental_count DESC;
END //

DELIMITER ;