DELIMITER //

CREATE PROCEDURE customer_rental_report(IN p_customer_id INT)
BEGIN
    SELECT c.first_name,
           c.last_name,
           COUNT(DISTINCT r.rental_id) AS rental_count,
           COUNT(DISTINCT fc.category_id) AS category_count
    FROM customer AS c
    LEFT JOIN rental AS r ON c.customer_id = r.customer_id
    LEFT JOIN inventory AS i ON r.inventory_id = i.inventory_id
    LEFT JOIN film AS f ON i.film_id = f.film_id
    LEFT JOIN film_category AS fc ON f.film_id = fc.film_id
    WHERE c.customer_id = p_customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name;
END //

DELIMITER ;