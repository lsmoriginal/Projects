/******************************************************************************/
/* Majong's Pizza                                                             */
/* Indicate your student number here: A0183798E                               */
/******************************************************************************/
/******************************************************************************/
/* Answer Question 2.1.4.2 below (1)                                          */
/******************************************************************************/

SELECT DISTINCT piz.pname
FROM pizza piz
WHERE 
	piz.psize = 10 OR
	piz.psize = 12;

/******************************************************************************/
/* Answer Question 2.1.4.2 below (2)                                          */
/******************************************************************************/

SELECT piz.pname
FROM pizza piz
WHERE 
	piz.psize = 10
UNION
SELECT piz2.pname
FROM pizza piz2
WHERE 
	piz2.psize = 12;

/******************************************************************************/
/* Answer Question 2.1.4.3 below (1)                                          */
/******************************************************************************/

SELECT piz.pname
FROM pizza piz
WHERE 
	piz.psize = 10 AND
	piz.pname IN (
		SELECT piz2.pname
		FROM pizza piz2
		WHERE 
			piz2.psize = 12 AND
			piz2.pname = piz.pname
	);

/******************************************************************************/
/* Answer Question 2.1.4.3 below (2)                                          */
/******************************************************************************/


SELECT piz.pname
FROM pizza piz
WHERE 
	piz.psize = 10
INTERSECT
SELECT piz2.pname
FROM pizza piz2
WHERE 
	piz2.psize = 12;


/******************************************************************************/
/* Answer Question 2.1.4.4 below (1)                                          */
/******************************************************************************/

SELECT s.sname, s.sphone
FROM store s, pizza p, sells e
WHERE 
	s.sname = e.sname AND
	e.pcode = p.pcode AND
	(s.sarea = 'Pioneer' OR s.sarea = 'Tuas') AND
	p.psize = 10 AND
	p.pname = 'pepperoni' AND
	sprice < 22;

/******************************************************************************/
/* Answer Question 2.1.4.4 below (2)                                          */
/******************************************************************************/

SELECT s.sname, s.sphone
FROM store s, pizza p, sells e
WHERE 
	s.sname = e.sname AND
	e.pcode = p.pcode AND
	s.sarea = 'Pioneer' AND
	p.psize = 10 AND
	p.pname = 'pepperoni' AND
	sprice < 22
UNION
SELECT s.sname, s.sphone
FROM store s, pizza p, sells e
WHERE 
	s.sname = e.sname AND
	e.pcode = p.pcode AND
	s.sarea = 'Tuas' AND
	p.psize = 10 AND
	p.pname = 'pepperoni' AND
	sprice < 22;


/******************************************************************************/
/* Answer Question 2.1.4.5 below (1)                                          */
/******************************************************************************/

SELECT p.pcode
FROM pizza p
WHERE
	p.pprice >= ALL(
		SELECT p2.pprice
		FROM pizza p2
	);

/******************************************************************************/
/* Answer Question 2.1.4.5 below (2)                                          */
/******************************************************************************/

SELECT p1.pcode
FROM pizza p1, pizza p2
GROUP BY p1.pcode
HAVING MIN(p1.pprice - p2.pprice) >= 0;

/******************************************************************************/
/* Answer Question 2.1.4.6 below (1)                                          */
/******************************************************************************/

SELECT s.sname
FROM store s
WHERE NOT EXISTS(
		SELECT * 
		FROM pizza p
		WHERE NOT EXISTS(
			SELECT *
			FROM sells e
			WHERE 
				s.sname = e.sname AND
				e.pcode = p.pcode
		)
	);

/******************************************************************************/
/* Answer Question 2.1.4.6 below (2)                                          */
/******************************************************************************/

SELECT s.sname
FROM store s, pizza p, sells e
WHERE 
	s.sname = e.sname AND
	e.pcode = p.pcode
GROUP BY s.sname
HAVING COUNT(*) >= ALL(
	SELECT COUNT(p2.pcode)
	FROM pizza p2
);



