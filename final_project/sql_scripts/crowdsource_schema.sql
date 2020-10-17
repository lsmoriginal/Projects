CREATE TABLE users(
	uid VARCHAR(20) PRIMARY KEY,
	uname VARCHAR(30) NOT NULL,
	upassword VARCHAR(20) NOT NULL,
	upicurl VARCHAR(100),
	ucash NUMERIC CHECK(ucash >= 0)
);

CREATE TABLE projects(
	pid VARCHAR(20) PRIMARY KEY,
	ptarget NUMERIC NOT NULL CHECK(ptarget > 0),
	pdeadline TIMESTAMP NOT NULL,
	pdesc VARCHAR(500),
	ppicurl VARCHAR(100)
);

CREATE TABLE initiates(
	uid VARCHAR(20),
	pid VARCHAR(20),
	CONSTRAINT i_keys PRIMARY KEY(
		uid, pid
	),
	FOREIGN KEY(uid) REFERENCES users(uid),
	FOREIGN KEY(pid) REFERENCES projects(pid)
);

CREATE TABLE donates(
	uid VARCHAR(20),
	pid VARCHAR(20),
	dtime TIMESTAMP,
	damt NUMERIC NOT NULL CHECK(damt > 0),
	dtrans VARCHAR(20) NOT NULL,
	CONSTRAINT d_keys PRIMARY KEY(
		uid, pid, dtime
	),
	FOREIGN KEY(uid) REFERENCES users(uid),
	FOREIGN KEY(pid) REFERENCES projects(pid)
);

DROP TABLE donates;
DROP TABLE users;
DROP TABLE projects;