/******************************************************************************/
/* Credit Cards (Aggregate, Algebraic and Nested Queries)                     */
/* Indicate your student number here: A0183798E                               */
/******************************************************************************/
/******************************************************************************/
/* Answer Question 1.2.3.1 below                                              */
/******************************************************************************/
-- customer SSN & no. of credit cards

SELECT cc.ssn, COUNT(DISTINCT cc.number)
FROM credit_cards cc
GROUP BY ssn;

/******************************************************************************/
/* Answer Question 1.2.3.2 below                                              */
/******************************************************************************/
-- for each singaporean, find his first, last name, and total spending
-- group by ssn to avoid replicated first, last name

SELECT cus.first_name, cus.last_name, SUM(tran.amount)
FROM credit_cards cc, customers cus, transactions tran
WHERE
	cc.ssn = cus.ssn AND
	cc.number = tran.number AND
	cus.country = 'Singapore'
GROUP BY cus.ssn, cus.first_name, cus.last_name;

/******************************************************************************/
/* Answer Question 1.2.3.3 below                                              */
/******************************************************************************/
-- for each credit card type, the transactions with the largest amount 
-- with this type of card, print the type and the larger amount

SELECT cc.type, MAX(trans.amount) max_trans
FROM credit_cards cc, transactions trans
WHERE
	cc.number = trans.number
GROUP BY cc.type;


/******************************************************************************/
/* Answer Question 1.2.4.1 below                                              */
/******************************************************************************/
-- print identifiers of the transactions with largest amount among all trans using 
-- the same type of credit card, 
-- use an agg query  

SELECT trans.identifier
FROM transactions trans, credit_cards cc
WHERE
	trans.number = cc.number
GROUP BY
	cc.type, trans.amount, trans.identifier
HAVING 
	trans.amount >= ALL (
		SELECT trans2.amount
		FROM credit_cards cc2, transactions trans2
		WHERE
			cc.type = cc2.type AND
			cc2.number = trans2.number
	)
ORDER BY trans.identifier; 


/******************************************************************************/
/* Answer Question 1.2.4.2 below                                              */
/******************************************************************************/
-- same question, dont use an agg

SELECT trans.identifier
FROM transactions trans, credit_cards cc
WHERE
	trans.number = cc.number AND
	trans.amount >= ALL (
		-- for each transaction
		-- check if the amt is greater than all trans with the same type
		SELECT trans2.amount
		FROM credit_cards cc2, transactions trans2
		WHERE
			cc.type = cc2.type AND
			cc2.number = trans2.number
);


/******************************************************************************/
/* Answer Question 1.2.4.3 below                                              */
/******************************************************************************/
-- find code & name of merchants
-- who does not have transactions with any credit card
-- use agg 

SELECT mer.code, mer.name
FROM merchants mer, transactions trans, credit_cards cc
WHERE
	mer.code = trans.code AND
	trans.number = cc.number
GROUP BY mer.code, mer.name
HAVING 
	COUNT(DISTINCT(cc.type)) <> ANY (
		SELECT COUNT(DISTINCT(cc2.type))
		FROM credit_cards cc2
	)
ORDER BY mer.code;

/******************************************************************************/
/* Answer Question 1.2.4.4 below                                              */
/******************************************************************************/

SELECT mer.code, mer.name
FROM merchants mer
WHERE
	EXISTS(
		SELECT *
		FROM credit_cards cc
		WHERE 
			NOT EXISTS(
				SELECT * 
				FROM transactions trans, credit_cards cc2
				WHERE 
					trans.code = mer.code AND
					trans.number = cc2.number AND
					cc.type = cc2.type
			)
	)
ORDER BY mer.code;