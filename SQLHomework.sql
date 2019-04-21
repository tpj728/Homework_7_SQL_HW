use sakila;
-- 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select upper(concat(first_name," ", last_name)) as 'Actor Name'
from actor;

alter table actor
add column Actor_Name VarChar(100) null after last_name;
update actor set Actor_Name = concat(first_name," ",last_name);

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name from actor
where first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
select * 
from actor
where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select * 
from actor
where last_name like '%LI%'
order by last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country
from country
where country = 'Afghanistan' or country ='Bangladesh' or country ='China';

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

alter table actor
add column Description blob null after Actor_Name;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.

alter table actor
drop column Description;

-- 4a. List the last names of actors, as well as how many actors have that last name.

select last_name, count(*) from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

select last_name, count(*) as last_count from actor
group by last_name
having last_count > '1';

select * from address;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
select * from actor
where Actor_Name like '%william%';

update actor
set first_name = "HARPO"
where actor_id = "172";

update actor
set Actor_Name = "HARPO WILLIAMS"
where actor_id = "172";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

update actor
set first_name = "GROUCHO"
where actor_id = "172";

update actor
set Actor_Name = "GROUCHO WILLIAMS"
where actor_id = "172";

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html

show create table address;

CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

select staff.first_name, staff.last_name, address.address
from staff
inner join
address on staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

SELECT 
    staff.last_name, sum(payment.amount) as total_amount
FROM
    payment
        INNER JOIN
    staff USING (staff_id)
WHERE
	payment_date like '2005-08%'
GROUP BY last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT 
	film.film_id, film.title, count(actor_id) as actor_count
FROM 
	film
		INNER JOIN
	film_actor USING (film_id)
GROUP BY film_id, title;

-- Validation
-- select count(actor_id) from film_actor
-- where film_id = 1;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select count(film_id) as Hunchback_Impossible_Count from inventory	
    where film_id like
		(select film_id from film
		where title = 'Hunchback Impossible');

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select customer.last_name, customer.first_name, sum(payment.amount) as customer_payment
from customer
	left join
payment on customer.customer_id = payment.customer_id
group by customer.last_name, customer.first_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

select title from film
where title like 'k%' or  title like 'q%' and language_id =
		(
		select language_id from language
		where name ='English'
		)
    ;

select * from language;

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

select Actor_Name from actor
where actor_id in
(	
    select actor_id from film_actor
	where film_id like
		(select film_id
		from film
		where title = 'Alone Trip')
);
	
select * from actor;
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select first_name, last_name, email
from customer as c
left join address as a 
	on c.address_id = a.address_id
left join city as ci 
	on a.city_id = ci.city_id
left join country as cu
	on ci.country_id = cu.country_id
where country = 'Canada';

select * from country;
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select title from film
where film_id in
	(select film_id from film_category
	where category_id like
		(
		select category_id from category
		where name = 'Family'
		)
	)
;

-- 7e. Display the most frequently rented movies in descending order.

select title, count(title) as Rented
from rental as r
	left join inventory as i
    on i.inventory_id = r.inventory_id
    left join film as f
    on f.film_id = i.film_id
    group by title
    order by Rented DESC
    ;

select * from rental;
-- inventory_id
select * from inventory;
-- film_id
select * from film;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select store_id, sum(amount) 
from payment as p
	left join rental as r
    on r.rental_id = p.rental_id
	left join staff as s
    on s.staff_id = r.staff_id
group by store_id;

select * from payment;
-- rental_id
select * from rental;
-- staff_id
select * from staff;

-- 7g. Write a query to display for each store its store ID, city, and country.
select store_id, city, country from store as s
	left join address as a
	on s.address_id = a.address_id
    left join city as c
    on a.city_id = c.city_id
    left join country as co
    on co.country_id = c.country_id
    ;

select * from store;
-- address_id
select * from address;
-- city_id
select * from city;
-- country_id
select * from country;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select name, sum(amount) as gross_revenue from category as c
	left join film_category as f
    on c.category_id = f.category_id
    left join inventory as i
    on i.film_id = f.film_id
    left join rental as r
    on r.inventory_id = i.inventory_id
    left join payment as p
    on p.rental_id = r.rental_id
group by name
order by gross_revenue desc
limit 5;

select * from category; 
-- category_id
select * from film_category;
-- film_id
select * from inventory;
-- inventory_id
select * from rental;
-- rental_id
select * from payment;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view genre_revenue as
select name, sum(amount) as gross_revenue from category as c
	left join film_category as f
    on c.category_id = f.category_id
    left join inventory as i
    on i.film_id = f.film_id
    left join rental as r
    on r.inventory_id = i.inventory_id
    left join payment as p
    on p.rental_id = r.rental_id
group by name
order by gross_revenue desc
limit 5;

-- 8b. How would you display the view that you created in 8a?
select * from genre_revenue;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view genre_revenue;


