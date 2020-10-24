CREATE TABLE store(
	sname VARCHAR(20) PRIMARY KEY,
	sarea VARCHAR(20),
	sphone NUMERIC
);

CREATE TABLE pizza(
	pcode NUMERIC PRIMARY KEY,
	pname VARCHAR(20),
	psize NUMERIC
);

CREATE TABLE sells(
	sname VARCHAR(20),
	pcode NUMERIC,
	sprice NUMERIC,
	PRIMARY KEY(sname, pcode),
	FOREIGN KEY(sname) REFERENCES store(sname),
	FOREIGN KEY(pcode) REFERENCES pizza(pcode)
);

------------------------------------------------------------------------------------------------------------------------

UPDATE pizza
SET pname = 'pepperoni'
WHERE pname = 'peproni';

INSERT INTO pizza(pcode, pname, psize) VALUES (1, 'peproni', 10);
INSERT INTO pizza(pcode, pname, psize) VALUES (2, 'peproni', 12);
INSERT INTO pizza(pcode, pname, psize) VALUES (3, 'peproni', 15);

INSERT INTO pizza(pcode, pname, psize) VALUES (4, 'cheesy', 12);
INSERT INTO pizza(pcode, pname, psize) VALUES (5, 'cheesy', 15);

INSERT INTO pizza(pcode, pname, psize) VALUES (6, 'spicy', 15);

------------------------------------------------------------------------------------------------------------------------

INSERT INTO store(sname, sarea, sphone) VALUES ('pizzahub', 'bukit panjang', 999);

INSERT INTO sells(sname, pcode, sprice) VALUES ('pizzahub', 1, 11);
INSERT INTO sells(sname, pcode, sprice) VALUES ('pizzahub', 2, 23);
INSERT INTO sells(sname, pcode, sprice) VALUES ('pizzahub', 4, 11);

INSERT INTO sells(sname, pcode, sprice) VALUES ('pizzahub', 5, 50);

INSERT INTO sells(sname, pcode, sprice) VALUES ('pizzahub', 6, 30);

-------------------------------------------------

INSERT INTO store(sname, sarea, sphone) VALUES ('dang', 'Tuas', 119);

INSERT INTO sells(sname, pcode, sprice) VALUES ('dang', 1, 11);
INSERT INTO sells(sname, pcode, sprice) VALUES ('dang', 2, 23);
INSERT INTO sells(sname, pcode, sprice) VALUES ('dang', 4, 11);

INSERT INTO sells(sname, pcode, sprice) VALUES ('dang', 5, 50);

INSERT INTO sells(sname, pcode, sprice) VALUES ('dang', 6, 30);

-------------------------------------------------

INSERT INTO store(sname, sarea, sphone) VALUES ('huatlag', 'Pioneer', 119);

INSERT INTO sells(sname, pcode, sprice) VALUES ('huatlag', 1, 11);
INSERT INTO sells(sname, pcode, sprice) VALUES ('huatlag', 2, 23);

INSERT INTO sells(sname, pcode, sprice) VALUES ('huatlag', 3, 50);

INSERT INTO sells(sname, pcode, sprice) VALUES ('huatlag', 4, 11);

INSERT INTO sells(sname, pcode, sprice) VALUES ('huatlag', 5, 45);

INSERT INTO sells(sname, pcode, sprice) VALUES ('huatlag', 6, 30);

-------------------------------------------------


INSERT INTO store(sname, sarea, sphone) VALUES ('johns place', 'lot1', 995);

INSERT INTO sells(sname, pcode, sprice) VALUES ('johns place', 1, 11);
INSERT INTO sells(sname, pcode, sprice) VALUES ('johns place', 2, 50);

-------------------------------------------------

INSERT INTO store(sname, sarea, sphone) VALUES ('merrys', 'lot1', 911);

INSERT INTO sells(sname, pcode, sprice) VALUES ('merrys', 1, 23);





CREATE TABLE pizzas(
	pcode NUMERIC PRIMARY KEY,
	pprice NUMERIC
);

INSERT INTO pizzas(pcode, pprice) VALUES (1, 2);
INSERT INTO pizzas(pcode, pprice) VALUES (2, 3);
INSERT INTO pizzas(pcode, pprice) VALUES (4, 4);
INSERT INTO pizzas(pcode, pprice) VALUES (5, 20);
INSERT INTO pizzas(pcode, pprice) VALUES (6, 20);
INSERT INTO pizzas(pcode, pprice) VALUES (7, 20);





