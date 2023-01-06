  /*brisemo bazu podataka filmovi ako vec postoji*/
DROP DATABASE IF EXISTS filmovi; 

 /*kreiramo bazu podataka filmovi*/
CREATE DATABASE filmovi;

CREATE TABLE zanr(id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
				  naziv VARCHAR(50) NOT NULL
				  )ENGINE=INNODB;

CREATE TABLE mesto(id INT NOT NULL AUTO_INCREMENT,
				   naziv VARCHAR(50) NOT NULL,
				   PRIMARY KEY(id)
				   )ENGINE=INNODB;

CREATE TABLE produkcijska_kuca(id INT NOT NULL AUTO_INCREMENT,
							   naziv VARCHAR(50) NOT NULL,
							   mesto_id INT NOT NULL,
							   PRIMARY KEY(id),
							   FOREIGN KEY(mesto_id) REFERENCES mesto(id)
							   		ON UPDATE CASCADE
							   		ON DELETE RESTRICT
							    )ENGINE=INNODB;

CREATE TABLE film(id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
				  naziv VARCHAR(50) NOT NULL,
				  godina_premijere INT NOT NULL,
				  budzet INT,
				  zanr_id INT NOT NULL,
				  produkcijska_kuca_id INT NOT NULL,
				  FOREIGN KEY (zanr_id) REFERENCES zanr(id)
				  		ON UPDATE CASCADE
				  		ON DELETE RESTRICT,
				  FOREIGN KEY(produkcijska_kuca_id) REFERENCES produkcijska_kuca(id)
				  		ON UPDATE CASCADE
				  		ON DELETE RESTRICT
				  )ENGINE=INNODB;
/*
koristimo ako hocemo da dodamo OGRANICENJE NEKOM ATRIBUTU
odnosno da ga proglasimo za foreign key
ALTER TABLE film 
	ADD CONSTRAINT fk_zanr_id
	FOREIGN KEY (zanr_id) REFERENCES zanr(id)
		ON UPDATE CASCADE 
		ON DELETE RESTRICT;

alter table film add
alter table film drop
alter table film rename
*/

INSERT INTO zanr(naziv) 
	VALUES ("komedija"), ("avantura"), ("horor"), ("drama");

INSERT INTO mesto(naziv)
	VALUES ("Beograd"), ("New York");

 /*
ako slucajno pogresim neki naziv u kodu i pokrenem ga i bazu se vec to upise 
nacin da ispravim 
UPDATE `mesto` SET `naziv` = 'New York' WHERE `mesto`.`id` = 2; 
*/

INSERT INTO produkcijska_kuca(naziv, mesto_id)
	VALUES ("Centar film", 1), 
		   ("Union film", 1),
		   ("New Line Cinema", 2);	

INSERT INTO film(naziv, godina_premijere, budzet, zanr_id, produkcijska_kuca_id)
	VALUES 
	("Maratonci trce pocasni krug", 1982, NULL, 1, 1),
	("Balkanski spijun", 1984, NULL, 1, 2),
	("Ko to tamo peva", 1980, NULL, 1, 1),
	("The lord of the rings: the fellowship of the ring", 2001, 93000000, 2, 3),
	("The lord of the rings: two towers", 2002, 93000000, 2, 3),
	("The lord of the rings: the return of the king", 2003, 93000000, 2, 3),
	("IT", 2017, 35000000, 3, 3),
	("The butterfly efect", 2004, 13000000, 4, 3),
	("Dumb and dumber to", 2014, 50000000, 1, 3);

--upiti

-- a)
SELECT 
	naziv
FROM 
	film;

-- b)
SELECT 
	*
FROM
	film
WHERE godina_premijere<2000;

/*
NIJE NETACNO ALI NIJE BAS BEST OPTION
*/
-- c)

-- I nacin
SELECT 
	film.naziv,
	film.godina_premijere,
	film.budzet,
	zanr.naziv
FROM
	film,
	zanr
WHERE
	film.zanr_id = zanr.id;

-- II nacin
SELECT 
	film.naziv,
	film.godina_premijere,
	film.budzet,
	zanr.naziv
FROM
	film
INNER JOIN zanr ON zanr.id = film.zanr_id;

-- d)
SELECT 
	film.naziv,
	film.godina_premijere,
	film.budzet,
	zanr.naziv
FROM
	film
INNER JOIN zanr ON film.zanr_id = zanr.id
WHERE zanr.naziv = "komedija";

-- e)
SELECT 
	film.naziv,
	film.godina_premijere,
	film.budzet,
	zanr.naziv
FROM 
	film
INNER JOIN zanr ON zanr.id = film.zanr_id
WHERE zanr.naziv = "komedija"
	AND film.godina_premijere < 2000;

-- f)
SELECT 
	film.naziv,
	film.godina_premijere,
	zanr.naziv, 
	produkcijska_kuca.naziv
FROM 
	film
INNER JOIN zanr ON zanr.id = film.zanr_id
INNER JOIN produkcijska_kuca ON produkcijska_kuca.id = film.produkcijska_kuca_id;
 
-- g)

-- I nacin
SELECT * FROM film
WHERE
	naziv LIKE "%the%"; -- osnovna verzija % menja proizvoljan br karaktera
-- II nacin
SELECT 
	* 
FROM 
	film
WHERE 
	naziv LIKE "% the %"
	OR naziv LIKE "the %"
	OR naziv LIKE "% the";

-- h)
SELECT 
	film.naziv,
	film.budzet
FROM
	film
ORDER BY 
	budzet DESC;
/*
ORDER BY ime ASC;
ORDER BY imw DESC;
*/

-- i)
SELECT 
	film.naziv,
	film.godina_premijere,
	film.budzet,
	produkcijska_kuca.naziv
FROM 
	film
INNER JOIN produkcijska_kuca ON produkcijska_kuca.id = film.produkcijska_kuca_id
INNER JOIN mesto ON mesto.id = produkcijska_kuca.mesto_id
WHERE mesto.naziv = "Beograd";

-- sa AS `` mozemo postaviti novi naziv za neku kolonu

-- j)
SELECT 
	film.naziv,
	film.godina_premijere,
	film.budzet,
	produkcijska_kuca.naziv AS `produkcijska kuca - naziv`,
	mesto.naziv AS `mesto - naziv`
FROM
	film
INNER JOIN produkcijska_kuca ON produkcijska_kuca.id = film.produkcijska_kuca_id
INNER JOIN mesto ON produkcijska_kuca.mesto_id = mesto.id
WHERE mesto.naziv = "Beograd" 
		AND film.godina_premijere = 1984;


