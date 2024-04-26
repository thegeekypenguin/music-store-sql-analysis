/*	Query Set 1 */
/* Q1: Who is the senior most employee based on job title? */

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1;


/* Q2: Which countries have the most Invoices? */
SELECT * FROM INVOICE
SELECT COUNT(*) AS CT, BILLING_COUNTRY
FROM INVOICE
GROUP BY BILLING_COUNTRY
ORDER BY CT DESC;

/* Q3: What are top 3 values of total invoice? */
SELECT TOTAL FROM INVOICE
ORDER BY TOTAL DESC
LIMIT 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival 
in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals.Return both the city name & sum of all invoice totals */
SELECT SUM(TOTAL) AS INVOICE_TOTAL, BILLING_CITY 
FROM INVOICE
GROUP BY BILLING_CITY
ORDER BY INVOICE_TOTAL DESC
LIMIT 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared 
the best customer. Write a query that returns the person who has spent the most money.*/
SELECT * FROM CUSTOMER
SELECT * FROM INVOICE
SELECT C.CUSTOMER_ID, C.FIRST_NAME, C.LAST_NAME, SUM(I.TOTAL) AS total
FROM CUSTOMER C 
JOIN INVOICE I ON C.CUSTOMER_ID = I.CUSTOMER_ID
GROUP BY C.CUSTOMER_ID
ORDER BY TOTAL DESC
LIMIT 1;

/* Query Set 2 */
/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */
select distinct email, first_name, last_name
from customer 
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id IN(
		select track_id from track
		join genre on track.genre_id = genre.genre_id
		where genre.name like 'Rock'
)
order by email;

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */
select artist.artist_id, artist.name, count(artist.artist_id) as num_of_songs 
from track 
join album on track.album_id = album.album_id
join artist on artist. artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by num_of_songs desc
limit 10;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length 
with the longest songs listed first. */

select name, milliseconds
from track
where milliseconds > (select avg(milliseconds) as avg_length from track)
order by milliseconds


/* Query Set 3 */

/* Q1: Find how much amount spent by each customer on artists? 
Write a query to return customer name, artist name and total spent */
WITH BEST_SELLING_ARTIST AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, 
	sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
	from invoice_line
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	group by 1
	order by 3 desc
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name, 
sum(il.unit_price*il.quantity) as amount_spent
from invoice i 
join customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
group by 1, 2, 3, 4
order by 5 desc;


/* Q2: We want to find out the most popular music Genre for each country. We determine the most 
popular genre as the genre with the highest amount of purchases. Write a query that 
returns each country along with the top Genre. For countries where the maximum number of 
purchases is shared return all Genres. */

WITH popular_genre as (
	select count(invoice_line.quantity) as purchase, customer.country, 
	genre.name, genre.genre_id, row_number() over(partition by customer.country 
									order by count(invoice_line.quantity) desc) as RowNo
	from invoice_line
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id = invoice.customer_id
	join track on track.track_id = invoice_line.track_id
	join genre on genre.genre_id = track.genre_id
	group by 2, 3, 4
	order by 2 asc, 1 desc
)

select * from popular_genre where RowNo <=1

/* Q3: Write a query that determines the customer that has spent the most on music 
for each country. Write a query that returns the country along with the top customer and 
how much they spent. For countries where the top amount spent is shared, 
provide all customers who spent this amount. */

with customer_country as (
	select customer.customer_id, first_name, last_name, billing_country, 
	sum(total) as total_spending,
	row_number() over(partition by billing_country order by sum(total) desc) as RowNo
	from invoice 
	join customer on invoice.customer_id = customer.customer_id
	group by 1, 2, 3, 4
	order by 4 asc, 5 desc
)
select * from customer_country where RowNo<=1
