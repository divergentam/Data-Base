DROP DATABASE IF EXISTS banka;
CREATE DATABASE  DEFAULT CHARACTER SET utf8 COLLATE utf8_croatian_ci;

USE banka;

CREATE TABLE mesto(id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
				   naziv VARCHAR(15) NOT NULL
				   )ENGINE=INNODB;

CREATE TABLE korisnik(id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
					  telefon1 VARCHAR(20) NOT NULL,
					  telefon2 VARCHAR(20)
					  )ENGINE=INNODB;

CREATE TABLE fizicko_lice(JMBG VARCHAR(13) NOT NULL PRIMARY KEY,
						  ime VARCHAR(20) NOT NULL,
						  prezime VARCHAR(20) NOT NULL,
						  korisnik_id INT UNIQUE,
						  CONSTRAINT fk_korisnik_id1 
						  FOREIGN KEY (korisnik_id) REFERENCES korisnik(id)
						  	ON UPDATE CASCADE
						  	ON DELETE RESTRICT,
						  mesto_id INT NOT NULL,
						  CONSTRAINT fk_mesto_id
						  FOREIGN KEY (mesto_id) REFERENCES mesto(id)
						  	ON UPDATE CASCADE
						  	ON DELETE RESTRICT,
						  adresa VARCHAR(30) NOT NULL
						  )ENGINE=INNODB;

CREATE TABLE pravno_lice(pib VARCHAR(10) NOT NULL PRIMARY KEY,
						 naziv VARCHAR(50) NOT NULL,
						 email VARCHAR(30) NOT NULL UNIQUE,
						 korisnik_id INT UNIQUE,
						 CONSTRAINT fk_korisnik_id2
						 FOREIGN KEY (korisnik_id) REFERENCES korisnik(id)
						 	ON UPDATE CASCADE
						 	ON DELETE RESTRICT,
						 osoba_za_kontakt_JMBG VARCHAR(13) DEFAULT NULL,
						 CONSTRAINT fk_osoba_za_kontakt_JMBG 
						 FOREIGN KEY (osoba_za_kontakt_JMBG) REFERENCES fizicko_lice(JMBG)
						 	ON UPDATE CASCADE
						 	ON DELETE RESTRICT  
						 )ENGINE=INNODB;

CREATE TABLE banka(pib_id VARCHAR(10) NOT NULL PRIMARY KEY,
				   CONSTRAINT fk_pib 
				   FOREIGN KEY (pib_id) REFERENCES pravno_lice(pib)
				   		ON UPDATE CASCADE
				   		ON DELETE RESTRICT
				   )ENGINE=INNODB;

/*ako korisnik umre brise mu se racun*/ 

CREATE TABLE racuni(broj VARCHAR(20) NOT NULL PRIMARY KEY,
					korisnik_id INT NOT NULL,
					banka_pib VARCHAR(10) NOT NULL,
					dinarski BOOLEAN NOT NULL,
					stanje FLOAT NOT NULL,
					CONSTRAINT fk_korisnik_id3 
					FOREIGN KEY (korisnik_id) REFERENCES korisnik(id)
						ON UPDATE CASCADE
						ON DELETE CASCADE,
					CONSTRAINT fk_pib_banke
					FOREIGN KEY (banka_pib) REFERENCES banka(pib_id)
						ON UPDATE CASCADE
						ON DELETE CASCADE
					)ENGINE=INNODB;

CREATE TABLE transakcija(id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
						 iznos FLOAT NOT NULL,
						 datum_vreme DATETIME NOT NULL,
						 sa_racuna VARCHAR(20) NOT NULL,
						 CONSTRAINT fk_sa_racuna
						 FOREIGN KEY (sa_racuna) REFERENCES racuni(broj)
						 	ON UPDATE CASCADE
						 	ON DELETE CASCADE,
						 na_racun VARCHAR(20) NOT NULL,
						 CONSTRAINT fk_na_racun
						 FOREIGN KEY (na_racun) REFERENCES racuni(broj)
						 	ON UPDATE CASCADE
						 	ON DELETE CASCADE
						 )ENGINE=INNODB;

INSERT INTO korisnik(telefon1)
	VALUES ("0113108888"), -- 1 -- INTESA
		   ("0117859999"), -- 2 -- ALPHA BANK
		   ("0800201201"); -- 3 -- Erste banka

INSERT INTO korisnik(telefon1, telefon2)
	VALUES ("0658527411", "0613232321"), -- 4 -- Pera Peric
		   ("0666669996", null), -- 5 -- d.o.o International expert consorcium limited
		   ("063357741,", null), -- 6 -- Mika Mikic
		   ("0602587413", null); -- 7 -- Mica Micic

INSERT INTO mesto(naziv)
	VALUES ("Niš"), ("Beograd");

INSERT INTO fizicko_lice(JMBG, ime, prezime, korisnik_id, mesto_id, adresa)
	VALUES
	("1010990342519", "Pera", "Perić", 4, 1, "Božidara Adžije 12"),
	("0202992567435", "Mika", "Mikić", 6, 1, "7.jula 4"),
	("2801953582395", "Mića", "Mićić", 7, 2, "Nemanjina 32");

INSERT INTO pravno_lice(pib, korisnik_id, naziv, email) 
	VALUES
	("123456789", 1, "INTESA", "kontakt@bancaintesa.rs"),
	("987654321", 2, "ALPHA BANK", "kontakt@alpha.rs"),
	("123321123", 3, "Erste banka", "kontakt@erste.rs");

INSERT INTO pravno_lice (pib, korisnik_id, naziv, email, osoba_za_kontakt_JMBG)
	VALUES 
	("369963369", 5, 
	"d.o.o. International expert consorcium limited",
	"diploma@lako.com",
	"2801953582395");

INSERT INTO banka(pib_id) 
	VALUES ("123456789"), ("987654321"), ("123321123");

INSERT INTO racuni (broj, dinarski, korisnik_id, banka_pib, stanje)
	VALUES 
	("160-123321000-77", 1, 4, "123456789", 52000),
	("180-987654321-68", 1, 5, "987654321", 303000),
	("160-123456789-00", 0, 6, "123456789", 6000),
	("160-123321002-77", 0, 4, "123456789", 320);

-- 180-987654321-68 1500 2019-11-25
-- "YYYY-MM-DD HH:mm:SS"
-- 
INSERT INTO transakcija(sa_racuna, na_racun, iznos, datum_vreme)
	VALUES 
	("160-123321000-77", "180-987654321-68", 21000, "2018-11-25"),
	("160-123321000-77", "160-123456789-00", 35000, "2018-12-15"),
	("160-123456789-00", "180-987654321-68", 11000, "2019-01-25"),
	("160-123456789-00", "180-987654321-68", 20000, "2019-03-21"),
	("160-123456789-00", "180-987654321-68", 1000, "2019-04-12"),
	("160-123321002-77", "180-987654321-68", 1500, "2019-11-25");

-- a) Izlisati sva fizička lica 
-- (uključujući i podatke koji se odnose na tabelu korisnik). 
SELECT 
	fizicko_lice.korisnik_id,
	fizicko_lice.ime,
	fizicko_lice.prezime,
	fizicko_lice.JMBG,
	fizicko_lice.adresa,
	mesto.naziv,
	korisnik.telefon1 AS `broj telefona`,
	korisnik.telefon2 AS `drugi broj telefona`	
FROM
	fizicko_lice
INNER JOIN korisnik ON fizicko_lice.korisnik_id = korisnik.id
INNER JOIN mesto ON mesto.id = fizicko_lice.mesto_id;


-- b)Izlistati sve transakcije koje su se desile 2019. godine. 
SELECT
	*
FROM 
	transakcija
WHERE 
	datum_vreme >=  "2019-1-1 00:00:00"
	AND datum_vreme < "2020-01-01 00:00:00";

-- c)Izlistati sva pravna lica koja imaju otvorene račune u Alpha banci. 
SELECT
	pl.*
FROM
	pravno_lice AS `pl`
INNER JOIN korisnik ON korisnik.id = pl.korisnik_id
INNER JOIN racuni ON racuni.korisnik_id = korisnik.id
INNER JOIN banka ON banka.pib_id = racuni.banka_pib
INNER JOIN pravno_lice  AS `pl_banka` ON pl_banka.pib = banka.pib_id
WHERE pl_banka.naziv = "ALPHA BANK";

-- d) Izlistati sva fizička lica koja nemaju otvoren račun ni u jednoj banci. 
SELECT
	fizicko_lice.*, 
	racuni.broj
FROM
	racuni
RIGHT JOIN korisnik ON korisnik.id = racuni.korisnik_id
INNER JOIN fizicko_lice ON korisnik.id = fizicko_lice.korisnik_id
WHERE racuni.broj is NULL;

-- e) Napisati upit kojim se pravi rezervna kopija svih transakcija.
CREATE TABLE transakcija_backup LIKE transakcija;
INSERT INTO transakcija_backup(sa_racuna, na_racun, datum_vreme, iznos)
SELECT
	*
FROM
	transakcija;

-- f) Napisati upite kojim se sa računa 160-123456789-00 prebacuje 1.000 din na račun 180-987654321-68.
-- (Dodatno, neki od računa može biti devizni. Prevesti dinare u evre po kursu kupovni=117, prodajni=118).
UPDATE
	racuni
SET
	stanje = stanje - IF(racuni.dinarski = 1, 1000, 1000/117)
WHERE racuni.broj = "160-123456789-00";

UPDATE 
	racuni
SET 
	stanje = stanje - IF(racuni.dinarski = 1, 1000, 1000/118)
WHERE racuni.broj = "180-987654321-68";

-- g) Izlistati sve korisnike u bazi i prikazati njihov id kao kolonu pod imenom „id korisnika“,
-- naziv (naziv pravnog lica ili ime i prezime fizičkog lica) kao jednu kolonu pod nazivom „naziv korisnika“
-- i kontakt telefone. Rezultat upita sačuvati kao „view“ objekat. 

CREATE VIEW view_g AS
SELECT
	korisnik.id AS `id korisnika`,
	IF(JMBG is NULL, pravno_lice.naziv,
		CONCAT(fizicko_lice.ime," ",fizicko_lice.prezime)) AS `naziv korisnika`,
	korisnik.telefon1,
	korisnik.telefon2
FROM 
	korisnik
LEFT JOIN fizicko_lice ON korisnik.id = fizicko_lice.korisnik_id
LEFT JOIN pravno_lice ON korisnik.id = pravno_lice.korisnik_id
ORDER BY korisnik.id ASC;

-- h) Prikazati koja banka ima koliko otvorenih računa. Banke sortirati rastuće po broju računa. 
SELECT 
	banka.pib_id,
	pravno_lice.naziv,
	COUNT(racuni.broj) AS `broj racuna`
FROM
	banka
LEFT JOIN pravno_lice ON pravno_lice.pib = banka.pib_id
LEFT JOIN racuni ON banka.pib_id = racuni.banka_pib
GROUP BY 
	banka.pib_id,
	pravno_lice.naziv
ORDER BY broj racuna DESC;

-- i) Prikazati one račune sa kojih je bilo više od dve transakcije. 
SELECT
	racuni.broj,
	COUNT(transakcija.sa_racuna) AS `broj transakcija`
FROM
	racuni
LEFT JOIN transakcija ON racuni.broj = transakcija.sa_racuna
GROUP BY 
	racuni.broj
HAVING `broj transakcija` > 2;

-- j) Prikazati koliko je dinara sa kog racuna ukupno uplaceno na bilo koj drugi racun

SELECT 
	racuni.broj AS `broj racuna`,
	IF(SUM(transakcija.iznos)is NULL, 0, SUM(transakcija.iznos)) AS `poslato sa racuna u dinarima`
FROM
	transakcija
RIGHT JOIN racuni ON racuni.broj = transakcija.sa_racuna
GROUP BY racuni.broj
ORDER BY racuni.broj ASC;

-- k)Prikazati koliko dinara je svaki od korisnika ukupno uplatio sa bilo kog računa.  
-- + k dodatno : prikazati ko su korisnici

-- I moj nacin
SELECT
	korisnik.id AS `id korisnika`,
	IF(pravno_lice.naziv is NULL, CONCAT(fizicko_lice.ime," ", fizicko_lice.prezime), pravno_lice.naziv) AS `naziv`,
	IF(racuni.broj is NULL, "nema racun", racuni.broj)  AS `broj racuna`,
	IF(SUM(transakcija.iznos)is NULL, 0, SUM(transakcija.iznos)) AS `ukupno poslato sa racuna u din.`
FROM 
	korisnik
LEFT JOIN fizicko_lice ON korisnik.id = fizicko_lice.korisnik_id
LEFT JOIN pravno_lice ON korisnik.id = pravno_lice.korisnik_id
LEFT JOIN racuni ON korisnik.id = racuni.korisnik_id
LEFT JOIN transakcija ON racuni.broj = transakcija.sa_racuna
GROUP BY korisnik.id;

-- II Vukasinov nacin
SELECT
	korisnik.id AS `id korisnika`,
	`naziv korisnika`,
	IF(racuni.broj is NULL, "nema racun", racuni.broj) AS `broj racuna`,
	IF(SUM(transakcija.iznos)is NULL, 0, SUM(transakcija.iznos)) AS `ukupno poslato sa racuna u din.`
FROM 
	korisnik
LEFT JOIN racuni ON korisnik.id = racuni.korisnik_id
LEFT JOIN transakcija ON racuni.broj = transakcija.sa_racuna
INNER JOIN view_g ON view_g.`id korisnika` = korisnik.id
GROUP BY korisnik.id;

-- l) Prikazati koliko novca u dinarima svaki korisnik ima ukupno (uzeti u obzir sve račune koje 
-- neka osoba ima i računati evro po kursu 117.5 za devizne račune). 
SELECT
	`id korisnika`,
	`naziv korisnika`,
	IF(racuni.broj is NULL, "nema racun",racuni.broj) AS `broj racuna`,
	IF(SUM(IF(racuni.dinarski = 1, racuni.stanje, racuni.stanje * 117.5)) is NULL,
			0, SUM(IF(racuni.dinarski = 1, racuni.stanje, racuni.stanje * 117.5))) AS `stanje racuna`
FROM 
	view_g
LEFT JOIN racuni ON racuni.korisnik_id = view_g.`id korisnika`
GROUP BY `id korisnika`;


-- m) Prikazati one korisnike koji su u 2019. uplatili ukupno više novca od prosečne količine 
-- novca koja je ukupno uplaćena (po korisniku) u toku 2019.  

CREATE VIEW view_m AS
SELECT 
	`id korisnika`,
	racuni.broj,
	`naziv korisnika`,
	IF(SUM(transakcija.iznos)is NULL, 0, SUM(transakcija.iznos)) AS `ukupno uplaceno sa racuna`
FROM 
	view_g
INNER JOIN racuni ON racuni.korisnik_id = `id korisnika`
INNER JOIN transakcija ON racuni.broj = transakcija.sa_racuna
WHERE YEAR(transakcija.datum_vreme) = 2019
GROUP BY 
	`id korisnika`;

SELECT 
	*
FROM 
	view_m 
WHERE 
	view_m.`ukupno uplaceno sa racuna` > (SELECT 
											AVG(unutrasnji_view_m.`ukupno uplaceno sa racuna`)
										  FROM
										  	view_m AS unutrasnji_view_m);

-- n) Napaviti View koji prikazuje sve transakcije sa informacijama o tome koji korisnik je kom korisniku
-- i kada uplatio koji iznos novca (za korisnike pisati naziv korisnika).  

CREATE VIEW view_n AS
SELECT
	transakcija.id,
	poslao.`naziv korisnika` AS `poslao`,
	racun_sa.broj AS `sa racuna`,
	primio.`naziv korisnika` AS `primio`,
	racun_na.broj AS `na racun`,
	transakcija.iznos,
	transakcija.datum_vreme
FROM
	transakcija
INNER JOIN racuni AS racun_sa ON racun_sa.broj = transakcija.sa_racuna
INNER JOIN racuni AS racun_na ON racun_na.broj = transakcija.na_racun

INNER JOIN view_g AS poslao ON  poslao.`id korisnika`= racun_sa.korisnik_id
INNER JOIN view_g AS primio ON primio.`id korisnika` = racun_na.korisnik_id
ORDER BY transakcija.id ASC;

-- o) Prikazati sve transakcije iz View objekta iz prethodnog upita za koje važi 
-- da je na račun uplaćen veći ili jednak iznos novca od prosečnog iznosa novca 
-- uplaćivanog na taj račun (prosek računati za sve uplate na konkretni račun).  

SELECT
	*
FROM 
	view_n
WHERE view_n.iznos > (SELECT
						AVG(iznos)
					  FROM
					  	transakcija
					  WHERE view_n.`na racun` = transakcija.na_racun);