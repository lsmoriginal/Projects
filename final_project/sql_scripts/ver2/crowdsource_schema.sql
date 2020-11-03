--========================================================================================================================
--===== Schema
--========================================================================================================================

CREATE TABLE users(
	uid VARCHAR(20) PRIMARY KEY,
	uname VARCHAR(30) NOT NULL,
	upassword VARCHAR(20) NOT NULL,
	upicurl VARCHAR(500),
	ucash NUMERIC CHECK(ucash >= 0)
);

CREATE TABLE projects(
	pid VARCHAR(20) PRIMARY KEY,
	uid VARCHAR(20),
	ptarget NUMERIC NOT NULL CHECK(ptarget > 0),
	pstartdate TIMESTAMP NOT NULL,
	pduration NUMERIC NOT NULL CHECK(
		pduration > 0 AND
		pduration <= 60),
	keywords VARCHAR(60),
	pdesc VARCHAR(500),
	ppicurl VARCHAR(500),
	FOREIGN KEY(uid) REFERENCES users(uid) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE donates(
	uid VARCHAR(20),
	pid VARCHAR(20),
	dtime TIMESTAMP,
	damt NUMERIC NOT NULL CHECK(damt > 0),
	CONSTRAINT d_keys PRIMARY KEY(
		uid, pid, dtime
	),
	FOREIGN KEY(uid) REFERENCES users(uid) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY(pid) REFERENCES projects(pid) ON DELETE CASCADE ON UPDATE CASCADE
);


--========================================================================================================================
--===== Procedures & Function
--========================================================================================================================

-- procedure donate
CREATE OR REPLACE PROCEDURE donate_to(
   sender VARCHAR,
   receiver VARCHAR,
   amount NUMERIC
)
language plpgsql    
as $$
begin
    -- subtracting the amount from the sender's account 
    update users 
    set ucash = ucash - amount 
    where uid = sender;
	-- if there is not enough money, an error should be raised now

    -- adding the transactionn record to the donate table
	INSERT INTO donates(uid, pid, dtime, damt) VALUES
	(sender, receiver, NOW(), amount);
    commit;
end;$$
;

-- function select users
-- WORKING FUNCTION
CREATE OR REPLACE FUNCTION get_users(access VARCHAR)
RETURNS TABLE(users_uid VARCHAR) AS $$
BEGIN
 
  IF access = 'admin' THEN
  	RETURN query SELECT users.uid FROM users;
  ELSE
  RETURN query
  	SELECT users.uid FROM users
  	WHERE users.uid = access;
	END IF;
END
$$ LANGUAGE plpgsql;



-- function select projects
-- WORKING FUNCTION
CREATE OR REPLACE FUNCTION get_projects(access VARCHAR)
RETURNS TABLE(projects_pid VARCHAR) AS $$
BEGIN
IF access = 'admin' THEN
  RETURN QUERY 
  	SELECT projects.pid FROM projects;
ELSE RETURN QUERY
	SELECT projects.pid FROM projects
	WHERE projects.uid = access;
END IF;
END
$$ LANGUAGE plpgsql;


-- function select donates
-- WORKING FUNCTION
CREATE OR REPLACE FUNCTION get_donates(access VARCHAR)
RETURNS SETOF donates AS $$
BEGIN
IF access = 'admin' THEN
RETURN QUERY 
SELECT *  FROM donates; 
ELSE RETURN QUERY 
SELECT * FROM donates WHERE donates.uid = access; 
END IF;
END
$$ LANGUAGE plpgsql;



-- Trigger to refund before deleting a transaction
CREATE OR REPLACE FUNCTION refund_donate() RETURNs TRIGGER
language plpgsql    
as $$
begin
    -- add the money back to the donor's account
    update users 
    set ucash = ucash + OLD.damt 
    where uid = OLD.uid;
RETURN OLD;
end;$$
;

DROP TRIGGER delete_donate ON donates;

CREATE TRIGGER delete_donate
BEFORE DELETE ON donates
FOR EACH ROW
EXECUTE PROCEDURE refund_donate();
---

-- WORKING FUNCTION
CREATE OR REPLACE FUNCTION is_donable(proj VARCHAR)
RETURNS TABLE(donable BOOLEAN) AS $$
BEGIN
  RETURN QUERY 
  	SELECT projects.pstartdate + (projects.pduration * INTERVAL '1 day') > NOW()
	FROM projects
	WHERE pid = proj;
END
$$ LANGUAGE plpgsql;


-- gen_searchome get ongoingproject
CREATE OR REPLACE FUNCTION search_all_going_proj()
RETURNS TABLE(
	pid VARCHAR, 
	uid VARCHAR, 
	target MONEY, 
	total_sum MONEY, 
    percent_raised TEXT
) AS $$
BEGIN
  RETURN QUERY 
    SELECT new_view.pid, new_view.uid, 
        CAST(new_view.ptarget AS MONEY), 
	    CAST(SUM(new_view.damt) AS MONEY), 
    	to_char(SUM(new_view.damt)/new_view.ptarget * 100, '999999D99%')
    FROM
    	(SELECT users.uid, projects.pid, projects.ptarget, COALESCE(donates.damt,0) AS damt
        	FROM projects 
			LEFT JOIN donates ON projects.pid = donates.pid
    		LEFT JOIN users ON projects.uid = users.uid
    		WHERE
    			projects.pstartdate + (projects.pduration * INTERVAL '1 day') > NOW()) AS new_view
    		GROUP BY new_view.uid, new_view.pid, new_view.ptarget
    		ORDER BY SUM(new_view.damt)/new_view.ptarget DESC
    		LIMIT 10;
END
$$ LANGUAGE plpgsql;

-- gen_searchome get funded project
CREATE OR REPLACE FUNCTION search_all_funded_proj()
RETURNS TABLE(
	pid VARCHAR,
	uid VARCHAR, 
	target MONEY, 
	total_sum MONEY 
) AS $$
BEGIN
  RETURN QUERY 
        SELECT projects.pid, users.uid, 
        CAST(projects.ptarget AS MONEY), 
        CAST(SUM(COALESCE(donates.damt,0)) AS MONEY)
        FROM 
        	projects 
        	LEFT JOIN donates ON projects.pid = donates.pid
        	LEFT JOIN users ON projects.uid = users.uid
        WHERE
            projects.pstartdate + (projects.pduration * INTERVAL '1 day') <= NOW()
        GROUP BY users.uid, projects.pid, projects.ptarget
        HAVING SUM(COALESCE(donates.damt,0)) >= projects.ptarget;
END
$$ LANGUAGE plpgsql;

-- gen_searchome get failed projects
CREATE OR REPLACE FUNCTION search_all_failed_proj()
RETURNS TABLE(
	pid VARCHAR,
	uid VARCHAR, 
	target MONEY, 
	total_sum MONEY 
) AS $$
BEGIN
  RETURN QUERY 
    	SELECT projects.pid, users.uid, 
    	CAST(projects.ptarget AS MONEY), 
    	CAST(SUM(COALESCE(donates.damt,0)) AS MONEY)
    	FROM 
			projects 
			LEFT JOIN donates ON projects.pid = donates.pid
    		LEFT JOIN users ON projects.uid = users.uid
    	WHERE
        	projects.pstartdate + (projects.pduration * INTERVAL '1 day') <= NOW()
    	GROUP BY users.uid, projects.pid, projects.ptarget
    	HAVING SUM(COALESCE(donates.damt,0)) < projects.ptarget;
END
$$ LANGUAGE plpgsql;

--========================================================================================================================
--===== Users
--========================================================================================================================

INSERT INTO users (uid, uname, upassword, upicurl, ucash) VALUES
('admin', 'ShaoMin Liu', '123', 'https://github.com/lsmoriginal/Projects/blob/master/first_website/image.jpg?raw=true', 999999999);

INSERT INTO users (uid, uname, upassword, upicurl, ucash) VALUES
('jane', 'Jammie', '123', 'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQFCWqpkaxf4mbC4oKdOGFv-0EN5GUOQBlz5w&usqp=CAU', 1234);

INSERT INTO users (uid, uname, upassword, upicurl, ucash) VALUES
('linda', 'Linda Mei', '123', 'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQv7Vc_XK9HmxHKNiPkOgdIJIAiCVmnDVUZbw&usqp=CAU', 88888888);

INSERT INTO users (uid, uname, upassword, upicurl, ucash) VALUES
('kim', 'Shawn', '123', 'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSQEpUxVpO9xt29qafgromXbbSrdx21sApAbA&usqp=CAU', 0);

INSERT INTO users (uid, uname, upassword, upicurl, ucash) VALUES
('Shin', 'Danniel Lim', '123', 'https://pyxis.nymag.com/v1/imgs/507/f5c/b7aae56a0c081636d1f0916a48423dec28-26-django-sunglasses.rsquare.w700.jpgs', 0);

--========================================================================================================================
--===== Projects
--========================================================================================================================

-- Ongoing, 
INSERT INTO projects (pid, uid, ptarget, pstartdate, pduration, keywords, pdesc, ppicurl)
VALUES('Google','admin', 10000000, '2020-08-28', 300, 'tech', 'We want to build an awesome search engine that is ging to become the best in the world', 'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQvAQY5ekimW2JkufP9fo2ToTIGDYmr3714OA&usqp=CAU');

-- ongoing success
INSERT INTO projects (pid, uid, ptarget, pstartdate, pduration, keywords, pdesc, ppicurl)
VALUES('Facebook','admin', 20000, '2020-10-28', 300, 'communication', 'Let us be friends', 'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcS2_8RS1SG4aOcuctszQ7Sx33rNf-UTAB0P8w&usqp=CAU');

-- due, failed
INSERT INTO projects (pid, uid, ptarget, pstartdate, pduration, keywords, pdesc, ppicurl)
VALUES('Random Project','admin', 50000000, '2019-10-28', 100, 'nah', 'any how describe', 'https://i.pinimg.com/originals/3f/3d/d9/3f3dd9219f7bb1c9617cf4f154b70383.jpg');

-- due success
INSERT INTO projects (pid, uid, ptarget, pstartdate, pduration, keywords, pdesc, ppicurl)
VALUES('Apple Inc','admin', 990000000, '2019-10-28', 50, 'gadgets', 'Do we look like we are selling Apples?', 'https://yt3.ggpht.com/a/AATXAJxz6ehq4-Bd0bOUZInhfYHTRZ8mSlBSviJNSHVttg=s900-c-k-c0x00ffffff-no-rj');


-- ongoing
INSERT INTO projects (pid, uid, ptarget, pstartdate, pduration, keywords, pdesc, ppicurl)
VALUES('MAGA','jane', 12990000000, '2020-11-03', 50, 'election', 'Fake News! Fake News!', 'https://d279m997dpfwgl.cloudfront.net/wp/2019/08/AP_18311081887682.jpg');

-- ongoing success
INSERT INTO projects (pid, uid, ptarget, pstartdate, pduration, keywords, pdesc, ppicurl)
VALUES('Avengers','jane', 1299, '2020-07-03', 300, 'entertainment', 'Let us go watch this movie!', 'https://m.economictimes.com/thumb/msid-69058326,width-1200,height-900,resizemode-4,imgsize-623690/view-is-avengers-endgame-worth-waking-up-at-4-am-for.jpg');

-- due failed
INSERT INTO projects (pid, uid, ptarget, pstartdate, pduration, keywords, pdesc, ppicurl)
VALUES('Fantastic4','jane', 12990, '2019-07-03', 50, 'entertainment', 'Let us go watch this movie!', 'https://static.wikia.nocookie.net/headhuntersholosuite/images/3/38/Fantastic_Four_%282005%29.jpg/revision/latest/scale-to-width-down/340?cb=20160715131346');

-- due SUCCEEDS
INSERT INTO projects (pid, uid, ptarget, pstartdate, pduration, keywords, pdesc, ppicurl)
VALUES('IT2002','jane', 12990, '2020-07-03', 50, 'Tech', 'Im am going to make this project!!', 'https://www.enterprisedb.com/sites/default/files/django_1.png');



--========================================================================================================================
--===== Donatations
--========================================================================================================================

INSERT INTO donates (uid, pid, dtime, damt) VALUES
('admin', 'Google', '2020-08-29', 20000);

INSERT INTO donates (uid, pid, dtime, damt) VALUES
('linda', 'Google', '2020-08-29', 20000);

INSERT INTO donates (uid, pid, dtime, damt) VALUES
('kim', 'Google', '2020-08-29', 2000000);

----------------------------------------------------

INSERT INTO donates (uid, pid, dtime, damt) VALUES
('admin', 'Facebook', '2020-11-29', 2033000);

INSERT INTO donates (uid, pid, dtime, damt) VALUES
('linda', 'Facebook', '2020-11-29', 123420000);

INSERT INTO donates (uid, pid, dtime, damt) VALUES
('kim', 'Facebook', '2020-11-29', 2000000);

----------------------------------------------------

INSERT INTO donates (uid, pid, dtime, damt) VALUES
('admin', 'Apple Inc', '2019-11-29', 120000000);

INSERT INTO donates (uid, pid, dtime, damt) VALUES
('linda', 'Apple Inc', '2019-11-29', 120000000);

INSERT INTO donates (uid, pid, dtime, damt) VALUES
('kim', 'Apple Inc', '2019-11-29', 1230000000);

INSERT INTO donates (uid, pid, dtime, damt) VALUES
('Shin', 'Apple Inc', '2019-11-29', 12300000);

----------------------------------------------------

INSERT INTO donates (uid, pid, dtime, damt) VALUES
('admin', 'MAGA', '2020-11-29', 990000000);

INSERT INTO donates (uid, pid, dtime, damt) VALUES
('linda', 'MAGA', '2020-11-29', 890000000);

INSERT INTO donates (uid, pid, dtime, damt) VALUES
('kim', 'MAGA', '2020-11-29', 990000);

INSERT INTO donates (uid, pid, dtime, damt) VALUES
('Shin', 'MAGA', '2020-11-29', 12300000);  

----------------------------------------------------

INSERT INTO donates (uid, pid, dtime, damt) VALUES
('admin', 'Avengers', '2020-11-27', 9900);

INSERT INTO donates (uid, pid, dtime, damt) VALUES
('linda', 'Avengers', '2020-11-26', 8900);

INSERT INTO donates (uid, pid, dtime, damt) VALUES
('kim', 'Avengers', '2020-11-25', 99000);

INSERT INTO donates (uid, pid, dtime, damt) VALUES
('Shin', 'Avengers', '2020-11-22', 123000);  

----------------------------------------------------

INSERT INTO donates (uid, pid, dtime, damt) VALUES
('kim', 'Fantastic4', '2020-11-29', 2000);

INSERT INTO donates (uid, pid, dtime, damt) VALUES
('Shin', 'Fantastic4', '2020-11-29', 3000);  

----------------------------------------------------

INSERT INTO donates (uid, pid, dtime, damt) VALUES
('admin', 'IT2002', '2020-11-24', 9900);

INSERT INTO donates (uid, pid, dtime, damt) VALUES
('linda', 'IT2002', '2020-11-29', 8900);

INSERT INTO donates (uid, pid, dtime, damt) VALUES
('kim', 'IT2002', '2020-11-29', 99000);

INSERT INTO donates (uid, pid, dtime, damt) VALUES
('Shin', 'IT2002', '2020-11-29', 123000);  

----------------------------------------------------

