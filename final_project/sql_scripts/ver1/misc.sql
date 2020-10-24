select * from users;

insert into users (uid, uname, upassword, upicurl, ucash) 
values 
('admin', 'ShaoMin', '12345', 'http://dummyimage.com/250x250.jpg/5fa2dd/ffffff', 1000000);

-- failed project
INSERT INTO projects (pid, uid, ptarget, pdeadline, pdesc, ppicurl) VALUES 
('overdued_project', 'admin', 2000000, '2020-10-13 09:34:56', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, curs', 'http://dummyimage.com/250x250.jpg/cc0000/ffffff');

        INSERT INTO donates (uid, pid, dtime, damt, dtrans) VALUES 
        ('jlaidlaw26', 'overdued_project', '2019-12-08 10:52:02', '21000', FALSE);
        
        INSERT INTO donates (uid, pid, dtime, damt, dtrans) VALUES 
        ('ogeist3', 'overdued_project', '2020-01-29 10:50:19', '79000', FALSE);
        
        INSERT INTO donates (uid, pid, dtime, damt, dtrans) VALUES 
        ('bberthe11', 'overdued_project', '2020-03-26 17:03:52', '55000', FALSE);
        
        INSERT INTO donates (uid, pid, dtime, damt, dtrans) VALUES 
        ('gguidotti2c', 'overdued_project', '2020-09-02 11:27:28', '91000', FALSE);
        
        INSERT INTO donates (uid, pid, dtime, damt, dtrans) VALUES 
        ('bboase1j', 'overdued_project', '2020-03-04 19:31:36', '10000', FALSE);
        
        INSERT INTO donates (uid, pid, dtime, damt, dtrans) VALUES 
        ('ecornwalls', 'overdued_project', '2020-06-08 07:14:14', '1100', FALSE);
        
        INSERT INTO donates (uid, pid, dtime, damt, dtrans) VALUES 
        ('llaba1n', 'overdued_project', '2020-08-02 10:24:48', 1300, FALSE);

-- on-going project
INSERT INTO projects (pid, uid, ptarget, pdeadline, pdesc, ppicurl) VALUES 
('new_proj', 'admin', 2000000, '2020-12-13 09:34:56', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, curs', 'http://dummyimage.com/250x250.jpg/cc0000/ffffff');

      INSERT INTO donates (uid, pid, dtime, damt, dtrans) VALUES 
        ('wharm29', 'new_proj', '2020-09-21 23:11:17', '382000', FALSE);
        
        INSERT INTO donates (uid, pid, dtime, damt, dtrans) VALUES 
        ('sfreezer1t', 'new_proj', '2020-07-09 09:33:58', '320000', FALSE);
        
        INSERT INTO donates (uid, pid, dtime, damt, dtrans) VALUES 
        ('jlaidlaw26', 'new_proj', '2020-01-16 18:09:54', '422000', FALSE);
        
        INSERT INTO donates (uid, pid, dtime, damt, dtrans) VALUES 
        ('sfreezer1t', 'new_proj', '2019-12-16 08:17:40', '69000', FALSE);
        
        INSERT INTO donates (uid, pid, dtime, damt, dtrans) VALUES 
        ('srean20', 'new_proj', '2020-06-08 08:49:06', '49000', FALSE);




-- successful project
INSERT INTO projects (pid, uid, ptarget, pdeadline, pdesc, ppicurl) VALUES 
('new_proj2', 'admin', 3000000, '2020-12-13 09:34:56', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, curs', 'http://dummyimage.com/250x250.jpg/cc0000/ffffff');


        INSERT INTO donates (uid, pid, dtime, damt, dtrans) VALUES 
        ('lkaradzas4', 'new_proj2', '2019-12-17 18:01:39', '464000', FALSE);
        
        INSERT INTO donates (uid, pid, dtime, damt, dtrans) VALUES 
        ('mkill1b', 'new_proj2', '2020-04-26 05:19:29', '1154000', FALSE);
        
        INSERT INTO donates (uid, pid, dtime, damt, dtrans) VALUES 
        ('wharm29', 'new_proj2', '2020-05-23 14:38:44', '880000', FALSE);
        
        INSERT INTO donates (uid, pid, dtime, damt, dtrans) VALUES 
        ('dwickenden14', 'new_proj2', '2020-10-23 04:48:52', '2580000', FALSE);
        
        INSERT INTO donates (uid, pid, dtime, damt, dtrans) VALUES 
        ('etrueman1f', 'new_proj2', '2020-05-12 08:51:42', '1021000', FALSE);
        
        INSERT INTO donates (uid, pid, dtime, damt, dtrans) VALUES 
        ('fgemmill1k', 'new_proj2', '2019-10-18 17:15:41', '3800000', FALSE);




insert into users (uid, uname, upassword, upicurl, ucash) 
values ('normal_user', 'ShaoMin (not admin)', '12345', 'http://dummyimage.com/250x250.jpg/5fa2dd/ffffff', 1000000);



SELECT * FROM users WHERE uid = 'jmustoe1u';

-- project initated by
SELECT * FROM
users, projects
WHERE users.uid = projects.uid AND
users.uid = 'admin'

ORDER BY users.uid;

--ongoing projects
SELECT projects.pid, DATE(projects.pdeadline), projects.ptarget, SUM(donates.damt) FROM
users, projects, donates
WHERE users.uid = projects.uid AND
donates.pid = projects.pid AND
users.uid = 'admin' AND
pdeadline > NOW()
GROUP BY projects.pid;

--EXPIRED PROJECTS
SELECT * FROM
users, projects
WHERE users.uid = projects.uid AND
users.uid = 'admin' AND
pdeadline <= NOW()
ORDER BY users.uid;

SELECT projects.pid, DATE(projects.pdeadline), projects.ptarget, SUM(donates.damt) FROM
users, projects, donates
WHERE users.uid = projects.uid AND
donates.pid = projects.pid AND
users.uid = 'admin' AND
pdeadline <= NOW()
GROUP BY projects.pid;


--PROJECTS I have donated to

SELECT p1.pid, DATE(p1.pdeadline), p1.ptarget, SUM(d1.damt)
FROM users u1, projects p1, donates d1
WHERE
	u1.uid = p1.uid AND
	d1.pid = p1.pid
GROUP BY p1.pid
HAVING 'etrueman1f' IN (
	SELECT d2.uid
	FROM donates d2, projects p2
	WHERE p2.pid = d2.pid  AND
	p1.pid = p2.pid
);


INSERT INTO donates (uid, pid, dtime, damt, dtrans) VALUES 
('admin', 'Aerified', '2020-08-02 10:24:48', 10, FALSE);

INSERT INTO donates (uid, pid, dtime, damt, dtrans) VALUES 
('admin', 'Andalax', '2020-08-02 10:24:48', 20, FALSE);

INSERT INTO donates (uid, pid, dtime, damt, dtrans) VALUES 
('admin', 'Biodex', '2020-08-02 10:24:48', 30, FALSE);

INSERT INTO donates (uid, pid, dtime, damt, dtrans) VALUES 
('admin', 'Job', '2020-08-02 10:24:48', 40, FALSE);


---owner of the project
SELECT uid
FROM projects
WHERE projects.pid = 'Aerified';


---find donors of this project
SELECT donates.uid, donates.damt
FROM projects, donates
WHERE projects.pid = donates.pid AND
projects.pid = 'Aerified';