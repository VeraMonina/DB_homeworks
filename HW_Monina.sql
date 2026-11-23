USE sakila;

SHOW TABLES;

# Задание 1. 
# Найдите все фильмы, которые были арендованы менее пяти раз. 
# Выведите: название фильма; рейтинг; продолжительность; стоимость аренды. 
# Отсортируйте фильмы по убыванию стоимости аренды.

DESCRIBE film;
DESCRIBE inventory;
DESCRIBE rental;
# rental_rate: The cost to rent the film for the period specified in the rental_duration column.\
# rental_duration: The length of the rental period, in days.
# The inventory table contains one row for each copy of a given film in a given store.
# The rental table contains one row for each rental of each inventory item with information about who rented what item, 
# when it was rented, and when it was returned.
SELECT title, rating, length, rental_rate FROM film AS f
      WHERE ( SELECT COUNT(r.rental_id)
      FROM inventory AS i
      JOIN rental AS r ON i.inventory_id = r.inventory_id
      WHERE i.film_id = f.film_id) < 5
      ORDER BY rental_rate DESC;


# Задание 2
# Для каждого клиента определите количество аренд. Выведите имя и фамилию клиента; количество аренд. 
# Оставьте только клиентов, которые брали фильмы напрокат более 10 раз. Отсортируйте результат по количеству аренд от большего к меньшему.

DESCRIBE customer;

SELECT c.first_name, c.last_name, COUNT(r.rental_id) AS number_of_rental 
       FROM customer AS c
       JOIN rental AS r ON c.customer_id = r.customer_id
       GROUP BY c.first_name, c.last_name,  c.customer_id
       HAVING COUNT(r.rental_id) > 10
       ORDER BY number_of_rental DESC;


# Задание 3
# Для каждого магазина определите суммарную выручку от аренды фильмов. 
# Выведите номер магазина; общую выручку. Отсортируйте магазины по выручке от большей к меньшей.

DESCRIBE store;
DESCRIBE rental;
DESCRIBE staff;
DESCRIBE payment;
SELECT * FROM staff;

SELECT s.store_id, SUM(p.amount) AS total_sum
       FROM staff AS s
       JOIN payment AS p ON s.staff_id = p.staff_id
       GROUP BY s.store_id 
       ORDER BY total_sum DESC;

 
# Задание 4
# Найдите фильмы, количество аренд которых выше среднего количества аренд одного фильма. 
# Выведите название фильма; количество аренд. Отсортируйте результат по убыванию количества аренд.

# Вариант 1 : дополнительная таблица для подсчеа аренды для каждого фильма
CREATE TABLE film_rentals AS 
       SELECT f.film_id, f.title, COUNT(r.rental_id) AS rental_count
       FROM film  AS f
       JOIN inventory AS i ON f.film_id = i.film_id
       JOIN rental AS r ON i.inventory_id = r.inventory_id
       GROUP BY f.film_id, f.title;

# я нагуглила еще, что чтобы не засорять БД дублирующимися данными, можно создавать временную таблицу
# на результат этого задания это не влияет, но приведу ниже 
# Вариант 2: через дополнительную таблицу
# CREATE TEMPORARY TABLE film_rentals AS 
#       SELECT f.film_id, f.title, COUNT(r.rental_id) AS rental_count
#       FROM film  AS f
#       JOIN inventory AS i ON f.film_id = i.film_id
#       JOIN rental AS r ON i.inventory_id = r.inventory_id
#       GROUP BY f.film_id, f.title;

SELECT * FROM film_rentals;

# дальше я создам отдельную переменную с AVG, потому что у меня не получается 2 раза открыть эту таблицу
SET @avg_rentals = (SELECT AVG(rental_count) FROM film_rentals);
SELECT @avg_rentals; #16,7

# доделываем задание по новой таблице
SELECT title, rental_count FROM film_rentals
       WHERE rental_count > @avg_rentals
       ORDER BY rental_count DESC;


##################
# Вариант 3 после последнего сема
WITH film_rentals AS (
    SELECT f.film_id, f.title, COUNT(r.rental_id) AS rental_count
    FROM film AS f
    JOIN inventory AS i ON f.film_id = i.film_id
    JOIN rental AS r ON i.inventory_id = r.inventory_id
    GROUP BY f.film_id, f.title)
SELECT title, rental_count
FROM film_rentals
WHERE rental_count > (SELECT AVG(rental_count) FROM film_rentals)
ORDER BY rental_count DESC;

# Задание 5
# Создайте процедуру customer_rental_report, которая принимает customer_id.
# Процедура должна выводить следующую информацию о клиенте:
# -- имя и фамилию;
# -- количество аренд;
# -- количество категорий фильмов, которые он арендовывал.
# Проверьте процедуру для нескольких клиентов.


# у меня так и не полуилось решить проблемы с тем, что у меня не выполняется
# код в этом же файле, поэтому я загружала его в отдельном sql файле (и для этого, и для следующего задания),
# запускала, после чего у меня возникает эта процедура в БД и я могу ее использовать тут для проверок
CALL customer_rental_report(1);
CALL customer_rental_report(2);
CALL customer_rental_report(310);

# Задание 6.
# Создайте процедуру get_popular_films, которая принимает два параметра: название категории; минимальное количество аренд. 
# Процедура должна выводить фильмы указанной категории, которые брали напрокат не менее заданного количества раз. 
# Выведите название фильма; количество аренд; суммарную выручку от его аренд. 
# Результат отсортируйте по количеству аренд от большего к меньшему.

# аналогичная проблема, что и в 5 задании
# тут только вызовы
CALL get_popular_films('Action', 20);
CALL get_popular_films('Horror', 10);


# Задание 7.
# Создайте триггер для таблицы film, который перед изменением записи автоматически обновляет дату и время изменения. 
# Проверьте работу триггера, изменив, например, рейтинг или стоимость аренды фильма.
CREATE TRIGGER film_before_update_last_update_2 BEFORE UPDATE ON film
       FOR EACH ROW
       SET NEW.last_update = NOW();

### 1) проверка
SELECT film_id, title, rating, last_update FROM film
      WHERE film_id = 3;

SELECT rating FROM film;

SELECT last_update FROM film;

UPDATE film SET rating = 'R' WHERE film_id = 3;

SELECT film_id, title, rating, last_update FROM film 
       WHERE film_id = 3;


### 2) проверка
SELECT film_id, title, replacement_cost, last_update FROM film
      WHERE film_id = 1;

UPDATE film SET replacement_cost = '57.0' WHERE film_id = 1;
SELECT film_id, title, replacement_cost, last_update FROM film
      WHERE film_id = 1;


# Задание 8.
# Создайте триггер для таблицы film, который срабатывает перед обновлением записи. 
# Если новая стоимость аренды (rental_rate) становится меньше 0, установите её значение равным 0. 
# Если новая стоимость становится больше 10, установите её значение равным 10.
CREATE TRIGGER film_before_update_rental_rate
       BEFORE UPDATE ON film
       FOR EACH ROW
       SET NEW.rental_rate = CASE
           WHEN NEW.rental_rate < 0 THEN 0
           WHEN NEW.rental_rate > 10 THEN 10
           ELSE NEW.rental_rate
        END;

## проверка 1
UPDATE film SET rental_rate = -5 
       WHERE film_id = 1;

SELECT film_id, title, rental_rate FROM film 
       WHERE film_id = 1; 


## проверка 2
UPDATE film SET rental_rate = 57 
       WHERE film_id = 3;

SELECT film_id, title, rental_rate FROM film 
       WHERE film_id = 3; 




# Задание 9.
# Найдите клиентов, чья общая сумма платежей выше средней общей суммы платежей клиентов. 
# Выведите имя и фамилию; общую сумму платежей. Отсортируйте клиентов по убыванию общей суммы платежей.

# Вариант 1
# решавем по той же логике, что и в 4 задании, то есть сначала создаю отдельную переменную 
# со средней общей суммой платежей клиентов 
 
SET @avg_amount = (
    SELECT AVG(total_amount) FROM (
        SELECT SUM(p.amount) AS total_amount
        FROM customer AS c 
        JOIN payment AS p ON c.customer_id = p.customer_id
        GROUP BY c.customer_id) AS t);


SELECT @avg_amount; #112,5318..

# дорешиваем с использованием этой переименной
SELECT c.first_name, c.last_name, SUM(p.amount) AS total_amount FROM customer AS c
       JOIN payment AS p ON c.customer_id = p.customer_id
       GROUP BY c.customer_id, c.first_name, c.last_name
       HAVING SUM(p.amount) > @avg_amount
       ORDER BY total_amount DESC;


####
# Вариант 2 
WITH customer_totals AS (
    SELECT c.customer_id, c.first_name, c.last_name,
           SUM(p.amount) AS total_amount,
           AVG(SUM(p.amount)) OVER () AS avg_total_amount
    FROM customer AS c
    JOIN payment AS p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name)
SELECT first_name, last_name, total_amount FROM customer_totals
WHERE total_amount > avg_total_amount
ORDER BY total_amount DESC;


# Задание 10*.
# Для каждого магазина определите:
# -- общее количество аренд;
# -- количество различных клиентов;
# -- общую выручку;
# -- категорию фильмов, принёсшую максимальную выручку.
# Выведите номер магазина и все перечисленные показатели. 
# Если несколько категорий имеют одинаковую максимальную выручку, покажите все такие категории.


# шаг 1: для каждого магазина (из двух!) выводим общее количество аренд, кол-во различных клиентов и общую выручку
# как добавить сюда еще 4 пункт, я не придумала, поэтому он будет дальше
SELECT * FROM rental;
SELECT * FROM inventory;
CREATE TEMPORARY TABLE store_totals AS
      SELECT i.store_id, COUNT(DISTINCT r.rental_id) AS total_rentals,
            COUNT(DISTINCT r.customer_id) AS distinct_customers, SUM(p.amount) AS total_revenue
                 FROM rental AS r
                 JOIN inventory AS i ON r.inventory_id = i.inventory_id
                 JOIN payment AS  p ON r.rental_id = p.rental_id
                 GROUP BY i.store_id;

SELECT * FROM store_totals;


# шаг 2: считаю выручку по каждой категории относительно магазигна (множество категорий к магазину)
CREATE TEMPORARY TABLE store_category_revenue AS
       SELECT i.store_id, cat.category_id, cat.name AS category_name,
       SUM(p.amount) AS category_revenue
       FROM rental AS r
            JOIN inventory AS i ON r.inventory_id = i.inventory_id
            JOIN film AS f  ON i.film_id = f.film_id
            JOIN film_category AS fc ON f.film_id = fc.film_id
            JOIN category AS cat ON fc.category_id = cat.category_id
            JOIN payment AS p ON r.rental_id = p.rental_id
            GROUP BY i.store_id, cat.category_id, cat.name;

SELECT * FROM store_category_revenue
        ORDER BY store_id, category_revenue DESC;


# шан 3: макс. выручка категории по магазину
CREATE TEMPORARY TABLE store_max_revenue2 AS
       SELECT store_id, MAX(category_revenue) AS max_revenue
       FROM store_category_revenue
       GROUP BY store_id;

SELECT * FROM store_max_revenue2;

# final
SELECT st.store_id,
       st.total_rentals,
       st.distinct_customers,
       st.total_revenue,
       scr.category_name,
       scr.category_revenue
       FROM store_totals AS st
            JOIN store_max_revenue2 AS smr ON st.store_id = smr.store_id
            JOIN store_category_revenue  AS scr ON st.store_id = scr.store_id
            AND scr.category_revenue = smr.max_revenue
            ORDER BY st.store_id, scr.category_name;
 


# я поняла, что возможно тут можно было всё решить через один длинный WITH, но переделать сил не хватило
# как и на 11 задание((


# Задание 11*.
# Для каждого фильма, который приносил выручку хотя бы в одном магазине, определите:
# -- название фильма;
# -- категорию;
# -- количество аренд;
# -- количество различных клиентов;
# -- суммарную выручку;
# -- магазин, в котором фильм принёс наибольшую выручку.
# Если фильм приносил одинаковую максимальную выручку в нескольких магазинах, покажите все такие магазины. 
# Результат отсортируйте по суммарной выручке фильма от большей к меньшей.


