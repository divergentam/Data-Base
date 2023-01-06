DROP DATABASE IF EXISTS hoteli;
CREATE DATABASE hoteli DEFAULT CHARACTER SET utf8 COLLATE utf8_croatian_ci;

USE hoteli;

CREATE TABLE drzava(id INT PRIMARY KEY AUTO_INCREMENT,
					naziv VARCHAR(30) NOT NULL
					)ENGINE=INNODB;

CREATE TABLE mesto(id INT PRIMARY KEY AUTO_INCREMENT,
				   naziv VARCHAR(30) NOT NULL,
				   drzava_id INT NOT NULL,
				   CONSTRAINT fk_drzava_id
				   FOREIGN KEY(drzava_id) REFERENCES drzava(id)
				   		ON UPDATE CASCADE
				   		ON DELETE RESTRICT
				   )ENGINE=INNODB;

CREATE TABLE tip(id INT PRIMARY KEY AUTO_INCREMENT,
				 naziv VARCHAR(30) NOT NULL
				 )ENGINE=INNODB;

CREATE TABLE korisnik(id INT PRIMARY KEY AUTO_INCREMENT,
					  ime VARCHAR(30) NOT NULL,
					  prezime VARCHAR(30) NOT NULL,
					  drzava_id INT NOT NULL,
					  email VARCHAR(50) UNIQUE,
					  CONSTRAINT fk_drzava_id2 
					  FOREIGN KEY (drzava_id) REFERENCES drzava(id)
					  		ON UPDATE CASCADE
					 		ON DELETE RESTRICT
					  )ENGINE=INNODB;

CREATE TABLE ugostiteljski_objekti(id INT PRIMARY KEY AUTO_INCREMENT,
								   naziv VARCHAR(60) NOT NULL,
								   mesto_id INT NOT NULL,
								   tip_id INT NOT NULL,
								   adresa VARCHAR(60) NOT NULL,
								   CONSTRAINT fk_mesto_id
								   FOREIGN KEY (mesto_id) REFERENCES mesto(id)
								   		ON UPDATE CASCADE
								   		ON DELETE RESTRICT,
								   CONSTRAINT fk_tip_id 
								   FOREIGN KEY (tip_id) REFERENCES tip(id)
								   		ON UPDATE CASCADE
								   		ON DELETE RESTRICT
								   )ENGINE=INNODB;

CREATE TABLE recenzija(id INT PRIMARY KEY AUTO_INCREMENT,
					   tekst VARCHAR(400) NOT NULL,
					   datum_vreme DATETIME NOT NULL,
					   objekat_id INT NOT NULL,
					   korisnik_id INT NOT NULL,
					   ocena INT NOT NULL,
					   CONSTRAINT fk_objekat_id 
					   FOREIGN KEY (objekat_id) REFERENCES ugostiteljski_objekti(id)
					   		ON UPDATE CASCADE
					   		ON DELETE RESTRICT,
					   CONSTRAINT fk_korisnik_id
					   FOREIGN KEY (korisnik_id) REFERENCES korisnik(id)
					   		ON UPDATE CASCADE
					   		ON DELETE RESTRICT,
					   CONSTRAINT proveri_ocenu CHECK(ocena >= 1 AND ocena <= 5)
					   )ENGINE=INNODB;

INSERT INTO drzava(naziv)
	VALUES ("Srbija"), ("SAD"), ("Severna Koreja");

INSERT INTO mesto(naziv, drzava_id)
	VALUES ("Niš", 1), ("New York", 2);

INSERT INTO tip(naziv)
	VALUES ("Kafana"), ("Hotel"), ("Kafić");

INSERT INTO korisnik(ime, prezime, drzava_id, email)
	VALUES ("Pera", "Perić", 1, "pera.peric@nesto.com"),
		   ("John", "Kramer", 2, "random@123.com"),
		   ("Miša", "Botić", 1, "misa@bla.bla.gov.rs"),
		   ("Kim", "Jong-un", 3, "dictator@nk.kp"),
		   ("Marko", "Marković", 1, "marko.markovic@nesto.com"),
		   ("Laza", "Lazić", 1, "laza.lazic@nesto.com");

INSERT INTO ugostiteljski_objekti(naziv, mesto_id, tip_id, adresa)
	VALUES ("Gusar", 1, 1, "Jadranska BB"),
		   ("Ambasador", 1, 2, "Trg Kralja Milana 4"),
		   ("Boem", 1, 1, "Dragiše Cvetkovića 50"),
		   ("Random place", 2, 2, "Random 123"),
		   ("Kafica", 1, 3, "Izmišljena 32");

INSERT INTO recenzija(objekat_id, korisnik_id, tekst, ocena, datum_vreme)
	VALUES 
	(1, 1, "Svaka cast!", 5, "2021-11-23 22:12:54"),
	(1, 2, "Not great, not terrible", 3, "2021-11-22 22:11:54"),
	(2, 3, "Najlepsi hotel u Beogradu!", 5, "2021-11-12 20:12:54"),
	(2, 4, "Beautiful hotel! Never saw anything like that in my county :(", 5, "2021-11-05 22:10:54"),
	(2, 5, "Jako potresno iskustvo. ", 1, "2021-11-13 12:12:54"),
	(2, 1, "Sramota za grad Niš", 1, "2021-11-03 22:12:54"),
	(3, 1, "Ok", 5, "2020-05-21 12:12:12"),
	(4, 2, "Nice place", 4, "2020-10-22 12:12:55"),
	(2, 6, "Veoma ružan hotel. Izbegavati.", 1, "2020-11-21 12:10:12");

-- a) Prikazati sve ugostiteljske objekte iz Niša koji imaju bar jednu recenziju.
SELECT 
	ugostiteljski_objekti.id,
	ugostiteljski_objekti.naziv,
	mesto.naziv,
	COUNT(recenzija.objekat_id) AS `broj recenzija`
FROM 
	ugostiteljski_objekti
INNER JOIN mesto ON mesto.id = ugostiteljski_objekti.mesto_id
INNER JOIN recenzija ON recenzija.objekat_id = ugostiteljski_objekti.id
WHERE mesto.naziv = "Niš"
GROUP BY ugostiteljski_objekti.id
HAVING `broj recenzija` >= 1;

-- b) Prikazati sve ugostiteljske objekte iz Niša koji nemaju nijednu recenziju. 
SELECT
	ugostiteljski_objekti.naziv,
	mesto.naziv,
	COUNT(recenzija.objekat_id) AS `broj recenzija`
FROM 
	ugostiteljski_objekti
INNER JOIN mesto ON mesto.id = ugostiteljski_objekti.mesto_id
LEFT JOIN recenzija ON ugostiteljski_objekti.id = recenzija.objekat_id
WHERE mesto.naziv = "Niš"
GROUP BY ugostiteljski_objekti.naziv
HAVING `broj recenzija` < 1;

-- c) Prikazati sve recenzije u kojima se pominje reč Beograd.
SELECT
	*
FROM 
	recenzija
WHERE tekst LIKE"%Beograd%";

-- d) Prikazati broj recenzija po tipu objekta.
SELECT 
	tip.naziv,
	COUNT(recenzija.objekat_id) AS `broj recenzija`
FROM
	tip
LEFT JOIN ugostiteljski_objekti ON ugostiteljski_objekti.tip_id = tip.id 
LEFT JOIN recenzija ON recenzija.objekat_id = ugostiteljski_objekti.id
GROUP BY tip.naziv;

-- e) Prikazati prosečnu ocenu koju svaki od objekata ima.
SELECT 
	ugostiteljski_objekti.id,
	ugostiteljski_objekti.naziv,
	IF(AVG(recenzija.ocena) is NULL, 0, AVG(recenzija.ocena)) AS `prosecna ocena`
FROM
	ugostiteljski_objekti
LEFT JOIN recenzija ON recenzija.objekat_id = ugostiteljski_objekti.id
GROUP BY ugostiteljski_objekti.naziv
ORDER BY ugostiteljski_objekti.id ASC;

-- f) Prikazati sve recenzije koje su ostavili domaći gosti (iz iste države u kojoj se nalazi i ugostiteljski objekat)
SELECT
	recenzija.id AS `recenzija br.`, 
	CONCAT(korisnik.ime, " ", korisnik.prezime) AS `korisnik`,
	recenzija.ocena,
	ugostiteljski_objekti.naziv AS `za objekat`,
	`drzava korisnika`.naziv AS `drzava korisnika`,
	`drzava objekta`.naziv AS `drzava objekta`
FROM 
	recenzija
INNER JOIN ugostiteljski_objekti ON ugostiteljski_objekti.id = recenzija.objekat_id
INNER JOIN mesto ON mesto.id = ugostiteljski_objekti.mesto_id
INNER JOIN drzava AS `drzava objekta` ON mesto.drzava_id = `drzava objekta`.id
INNER JOIN korisnik ON korisnik.id = recenzija.korisnik_id
INNER JOIN drzava AS `drzava korisnika` ON korisnik.drzava_id = `drzava korisnika`.id
WHERE `drzava korisnika`.naziv = `drzava objekta`.naziv;

-- g) Prikazati ugostiteljski objekat sa maksimalnim brojem recenzija (jedan objekat).
SELECT
	ugostiteljski_objekti.naziv,
	COUNT(recenzija.objekat_id) AS `broj recenzija`
FROM
	ugostiteljski_objekti
LEFT JOIN recenzija ON recenzija.objekat_id = ugostiteljski_objekti.id
GROUP BY ugostiteljski_objekti.naziv
ORDER BY `broj recenzija` DESC
LIMIT 1;

INSERT INTO recenzija(objekat_id, korisnik_id, tekst, ocena, datum_vreme)
	VALUES (6, 2, "Fast service and good food. Honest prices.", 5, "2021-11-23 22:12:54" ),
    		(6, 1, "Top usluga, jako fina hrana, pristupačne cijene.", 5, "2021-3-13 13:34:27" ),
            (6, 3, "Nice!", 5, "2021-11-23 17:12:34" ),
            (6, 4, "Exelent food! Nice and very friendly staff ! Owner is not married so i suggest him to all free girls!:))))", 5, "2021-11-23 00:25:41" ),
            (6, 5, "Usluga vrhunska ambikent jako lep i dobar", 5, "2021-11-23 09:19:36" );


-- h) Prikazati ugostiteljski objekat sa maksimalnim brojem recenzija (sve objekte sa podjednakim, maksimalnim, brojem recenzija).

-- I nacin
SELECT 
	ugostiteljski_objekti.naziv,
	COUNT(recenzija.objekat_id) AS `broj recenzija`
FROM
	ugostiteljski_objekti
LEFT JOIN recenzija ON recenzija.objekat_id = ugostiteljski_objekti.id
GROUP BY ugostiteljski_objekti.naziv
HAVING `broj recenzija` = (
	SELECT 
		COUNT(recenzija.korisnik_id) AS br_recenzija
	FROM 
		ugostiteljski_objekti
	LEFT JOIN recenzija ON recenzija.objekat_id = ugostiteljski_objekti.id
	GROUP BY ugostiteljski_objekti.id
		ORDER BY br_recenzija DESC
	LIMIT 1
	);

-- II nacin
SELECT 
	ugostiteljski_objekti.id,
	ugostiteljski_objekti.naziv,
	COUNT(recenzija.objekat_id) AS `broj recenzija`
FROM
	ugostiteljski_objekti
LEFT JOIN recenzija ON recenzija.objekat_id = ugostiteljski_objekti.id
GROUP BY ugostiteljski_objekti.id
HAVING `broj recenzija` = (
	SELECT MAX(br) 
	FROM (
		SELECT 
			COUNT(recenzija.objekat_id) AS br
		FROM 
			ugostiteljski_objekti
		LEFT JOIN recenzija ON recenzija.objekat_id = ugostiteljski_objekti.id
		GROUP BY
			ugostiteljski_objekti.id
		) AS sq
	);

-- i) Prikazati sve ugostiteljske objekte sa većim brojem ocena 1 od ocene 5
-- ugostiteljski objekti koji imaju vise 1 nego petica

SELECT
	ugostiteljski_objekti.id,
	ugostiteljski_objekti.naziv,
	SUM(IF(ocena = 1, 1, 0)) AS broj_jedinica,
	SUM(IF(ocena = 5, 1, 0)) AS broj_petica
FROM
	ugostiteljski_objekti
INNER JOIN recenzija ON recenzija.objekat_id = ugostiteljski_objekti.id
GROUP BY ugostiteljski_objekti.id
HAVING broj_jedinica > broj_petica;

-- j) Kreirati view kojim se izvršava upit koji daje listu objekata sa brojem ocena (po ocenama). Na primer, objekat 1 ima 3 ocene 1, 0 ocena 2, 3 ocene 4, itd…

CREATE VIEW view_j AS
SELECT
	ugostiteljski_objekti.id,
	ugostiteljski_objekti.naziv,
	SUM(IF(ocena = 1, 1, 0)) AS broj_jedinica,
	SUM(IF(ocena = 2, 1, 0)) AS broj_dvojki,
	SUM(IF(ocena = 3, 1, 0)) AS broj_trojki,
	SUM(IF(ocena = 4, 1, 0)) AS broj_cetvorki,
	SUM(IF(ocena = 5, 1, 0)) AS broj_petica
FROM 
	ugostiteljski_objekti
LEFT JOIN recenzija ON recenzija.objekat_id = ugostiteljski_objekti.id
GROUP BY ugostiteljski_objekti.id;

SELECT * FROM view_j;
