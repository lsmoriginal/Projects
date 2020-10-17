/*******************

  Create the schema

********************/

CREATE TABLE item (
    i_id INTEGER PRIMARY KEY,
    i_im_id CHAR(8) UNIQUE NOT NULL,
    i_name VARCHAR(50)  NOT NULL,
    i_price NUMERIC(5, 2)  NOT NULL CHECK(i_price > 0)
);

CREATE TABLE warehouse (
	w_id INTEGER PRIMARY KEY,
	w_name VARCHAR(50) NOT NULL,
	w_street VARCHAR(50) NOT NULL,
	w_city VARCHAR(50) NOT NULL,
	w_country VARCHAR(50) NOT NULL
);

CREATE TABLE stock (
    w_id INTEGER REFERENCES warehouse(w_id),
    i_id INTEGER REFERENCES item(i_id),
    s_qty SMALLINT NOT NULL CHECK (s_qty >= 0),
    PRIMARY KEY (w_id, i_id)
);