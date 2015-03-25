CREATE TABLE cats (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  owner_id INTEGER,

  FOREIGN KEY(owner_id) REFERENCES human(id)
);

CREATE TABLE humans (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  house_id INTEGER,

  FOREIGN KEY(house_id) REFERENCES human(id)
);

CREATE TABLE houses (
  id INTEGER PRIMARY KEY,
  address VARCHAR(255) NOT NULL
);

INSERT INTO
  houses (id, address)
VALUES
  (1, "26th and Guerrero"), (2, "Dolores and Market");

INSERT INTO
  humans (id, fname, lname, house_id)
VALUES
  (1, "Alan", "Watts", 1),
  (2, "Friedrich", "Nietzsche", 1),
  (3, "Jake", "Shorty", 2),
  (4, "Catless", "Human", NULL);

INSERT INTO
  cats (id, name, owner_id)
VALUES
  (1, "Lunch", 1),
  (2, "Earl", 2),
  (3, "Haskell", 3),
  (4, "Lamar", 3),
  (5, "Stray Cat", NULL);
