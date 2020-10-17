/******************************************************************************/
/* Credit Cards (Simple Queries)                                              */
/* Indicate your student number here: A0xxxxxxx                               */
/******************************************************************************/
/******************************************************************************/
/* Answer Question 1.2.2.1 below                                              */
/******************************************************************************/

SELECT c.first_name, c.last_name
FROM customers c, credit_cards cc
WHERE 
	c.ssn = cc.ssn AND
	cc.type = 'visa' AND
	c.country = 'Singapore';

/******************************************************************************/
/* Answer Question 1.2.2.2 below                                              */
/******************************************************************************/

SELECT DISTINCT c.ssn, c.first_name, c.last_name
FROM customers c, credit_cards cc, merchants m, transactions t
WHERE
	c.ssn = cc.ssn AND
	cc.number = t.number AND
	t.code = m.code AND
	c.country <> m.country;

/******************************************************************************/
/* Answer Question 1.2.2.3 below                                              */
/******************************************************************************/

SELECT DISTINCT c.ssn
FROM customers c, credit_cards cc, transactions t
WHERE
	c.ssn = cc.ssn AND
	cc.number = t.number AND
	cc.type = 'visa' AND
	DATE_PART('month', t.datetime) = 12 AND
	DATE_PART('day', t.datetime) = 25;



