--1] Who is the senior most employee based on job title?

select first_name, last_name, levels from employee
order by 3 desc
limit 1;

--2] Which countries have the most Invoices?

select billing_country, count(invoice_id) as invoice_count from invoice
group by 1
order by invoice_count desc
limit 1;

--3] What are top 3 values of total invoice?

select total from invoice
order by total desc
limit 3;

--4] Which city has the best customers? 
--We would like to throw a promotional Music Festival in the city we made the most money. 
--Write a query that returns one city that has the highest sum of invoice totals. 
--Return both the city name & sum of all invoice totals

select billing_city, sum(total) as total_sum from invoice
group by 1
order by total_sum desc
limit 1;

--5] Who is the best customer? The customer who has spent the most money will be declared the best customer. 
--Write a query that returns the person who has spent the most money

select c.customer_id, c.first_name, c.last_name, sum(total) as total_sum from customer c
join invoice i
on c.customer_id = i.customer_id
group by 1,2
order by total_sum desc
limit 1;

--6] Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
--Return your list ordered alphabetically by email starting with A

select distinct c.email, c.first_name, c.last_name, g.name as genre from customer c
join invoice i
on c.customer_id = i.customer_id
join invoice_line il
on i.invoice_id = il.invoice_id
join track t
on il.track_id = t.track_id
join genre g
on t.genre_id = g.genre_id
where g.name = 'Rock'
order by c.email;

--7] Let's invite the artists who have written the most rock music in our dataset. 
--Write a query that returns the Artist name and total track count of the top 10 rock bands

select a.artist_id, a.name, count(t.track_id) as track_count from artist a
join album al
on a.artist_id = al.artist_id
join track t
on al.album_id = t.album_id
join genre g
on t.genre_id = g.genre_id
where g.name = 'Rock'
group by 1
order by track_count desc
limit 10;

--8] Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first

select name, milliseconds from track
where milliseconds > (select avg(milliseconds) as avg_length from track)
order by 2 desc;

--9] Find how much amount spent by each customer on artists? 
--Write a query to return customer name, artist name and total spent


--Method 1 - Using Joins
select c.first_name, c.last_name, ar.name as artist_name, 
sum((il.unit_price * il.quantity)) as total_spent from customer c
join invoice i 
on c.customer_id = i.customer_id
join invoice_line il
on i.invoice_id = il.invoice_id
join track t 
on il.track_id = t.track_id
join album a
on t.album_id = a.album_id
join artist ar
on a.artist_id = ar.artist_id
group by 1,2,3
order by total_spent desc;

--Method 2 - Using CTE
with best_selling_artist as (
select 	ar.artist_id, ar.name as artist_name, sum(il.unit_price * il.quantity) as total_sales from artist ar
join album al
on ar.artist_id = al.artist_id
join track t
on al.album_id = t.album_id
join invoice_line il
on t.track_id = il.track_id
group by 1,2
order by total_sales desc
limit 1
)

select c.customer_id, c.first_name, c.last_name, bsa.artist_name, sum(il.unit_price * il.quantity) as amount_spent
from invoice i
join customer c 
on c.customer_id = i.customer_id
join invoice_line il 
on il.invoice_id = i.invoice_id
join track t 
on t.track_id = il.track_id
join album al 
on al.album_id = t.album_id
join best_selling_artist bsa 
on bsa.artist_id = al.artist_id
group by 1,2,3,4
order by 5 desc;

--10] We want to find out the most popular music Genre for each country. 
--We determine the most popular genre as the genre with the highest amount of purchases. 
--Write a query that returns each country along with the top Genre. 
--For countries where the maximum number of purchases is shared return all Genres

with popular_genre as (
select count(il.quantity) as purchases, i.billing_country, g.name as genre_name, g.genre_id, 
row_number() over(partition by i.billing_country order by count(il.quantity) desc) from invoice i
join invoice_line il
on i.invoice_id = il.invoice_id
join track t
on il.track_id = t.track_id
join genre g
on t.genre_id = g.genre_id
group by 2,3,4
order by 2 asc, 1 desc 
)
select * from popular_genre where row_number <= 1;

--11] Write a query that determines the customer that has spent the most on music for each country. 
--Write a query that returns the country along with the top customer and how much they spent. 
--For countries where the top amount spent is shared, provide all customers who spent this amount

with customer_with_country as (
select c.customer_id, c.first_name, c.last_name, i.billing_country, sum(i.total) as total_spending, 
row_number() over(partition by i.billing_country order by sum(i.total) desc) from customer c
join invoice i
on c.customer_id = i.customer_id
group by 1,2,3,4
order by 4
)
select * from customer_with_country where row_number <= 1;
