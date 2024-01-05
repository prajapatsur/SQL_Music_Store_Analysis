

Q1. Who is the senior most employee based on job title?
select first_name, title from employee order by hire_date limit 1
select first_name from employee where reports_to is null
select first_name from employee order by levels desc limit 1

Q2. Which county has the most invoices?
select billing_country, count(billing_country) as number 
from invoice 
group by billing_country 
order by number desc 
limit 1

Q3. What are top 3 values of total invoice?
select invoice_id, customer_id,total 
from invoice 
order by total 
desc limit 3

Q4. Which city has the best customers? We could like to throw a Promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals.
select billing_city, sum(total) as Total_Sales 
from invoice 
group by billing_city 
order by Total_Sales desc 
limit 1

Q5. Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money.
select c.customer_id, c.first_name,c.last_name, sum(i.total) as TotalSpent from invoice i,customer c where c.customer_id=i.customer_id group by c.customer_id order by TotalSpent desc
select c.customer_id, c.first_name, c.last_name, sum(i.total) as totalspent from customer c join invoice i on c.customer_id=i.customer_id group by c.customer_id order by totalspent desc
select i.customer_id, c.first_name,c.last_name, sum(i.total) as TotalSpent from invoice i,customer c where c.customer_id=i.customer_id group by i.customer_id, c.first_name, c.last_name order by TotalSpent desc 
select i.customer_id, c.first_name,c.last_name, sum(i.total) as TotalSpent from invoice i,customer c where c.customer_id=i.customer_id group by i.customer_id, c.customer_id order by TotalSpent desc 

Q6. Write query to return the eamil, first name, last name & Genre of all rock music listeners. Return your list ordered alphabetically by email starting with A.
select c.email, c.first_name, c.last_name 
from customer c 
join invoice i on c.customer_id=i.customer_id 
join invoice_line il on il.invoice_id=i.invoice_id 
join track t on t.track_id=il.track_id
join genre g on g.genre_id=t.genre_id
where g.name like 'Rock' and c.email like 'a%'
order by c.email

select c.email, c.first_name, c.last_name 
from customer c 
join invoice i on c.customer_id=i.customer_id 
join invoice_line il on il.invoice_id=i.invoice_id 
where track_id in(select track_id from track t join genre g on t.genre_id=g.genre_id where g.name='Rock') and c.email like 'a%'
order by c.email

Q7. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the artist name and total track count of the top 10 rock bands.'
select a.artist_id,a.name, count(t.track_id) as Songs 
from artist a 
join album al on al.artist_id=a.artist_id 
join track t on t.album_id=al.album_id 
join genre g on g.genre_id=t.genre_id 
where g.name='Rock' 
group by a.artist_id 
order by songs desc 
limit 10

Q8. Return all the track names that have a song length longer than the average song length . Return the name and milliseconds for each track. Order by the song length with the longest songs listed first.
select name, milliseconds from track where milliseconds > (select avg(milliseconds) from track) order by milliseconds desc

Q9. Find how much amount spent by each customer on artists? Wrtie a query to return customer name, artist name and total spent.
with artist_invoice as (
	select a.artist_id as Artist_id, a.name as artist_name, sum(il.unit_price*il.quantity) as total_sum
	from invoice_line il 
	join track t on t.track_id=il.track_id
	join album al on al.album_id=t.album_id
	join artist a on a.artist_id=al.artist_id
	group by 1
	order by 3 desc
	limit 1
)
select c.customer_id, c.first_name, c.last_name, ai.artist_id, ai.artist_name, sum(il.unit_price*il.quantity) as total_spent
from customer c
join invoice i on i.customer_id=c.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on t.track_id=il.track_id
join album al on al.album_id=t.album_id 
join artist a on a.artist_id=al.artist_id
join artist_invoice ai on ai.artist_id=a.artist_id
group by 1,2,3,4,5
order by 6 desc

Q10. We want to find the most popular music genre of the country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top genre. For countries where the maximum number of purchases is shared return all genres.
with CTE as(select i.billing_country as country, g.name as genre_name, count(i.invoice_id) as No_of_purchases,
	row_number()over(partition by i.billing_country order by count(i.invoice_id) desc) as RowNo
	from invoice i
	join invoice_line il on il.invoice_id=i.invoice_id
	join track t on t.track_id=il.track_id
	join genre g on g.genre_id=t.genre_id
	group by 1,2
	order by 1,3 desc)
select * from CTE where rowno<=1

Q11: Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount.
with CTE as(
	select c.customer_id, c.first_name, c.last_name, billing_country, sum(total) as TotalSpending,
	row_number()over(partition by billing_country order by sum(total) desc) as rowno
	from invoice i
	join customer c on c.customer_id=i.customer_id
	group by 1,2,3,4
	order by 4 asc, 5 desc
)
select * from CTE where rowno<=1
