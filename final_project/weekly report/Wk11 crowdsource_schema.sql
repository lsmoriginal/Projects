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
	pduration NUMERIC NOT NULL CHECK(pduration > 0),
	keywords VARCHAR(60),
	pstatus VARCHAR(20),
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

DROP TABLE donates;
DROP TABLE users;
DROP TABLE projects;