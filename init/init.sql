
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Login')
BEGIN
    CREATE DATABASE Login;
END
GO

USE Login;
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'roles' AND type = 'U')
BEGIN
    CREATE TABLE roles (
        id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
        role_name VARCHAR(50) NOT NULL UNIQUE
    );
END
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'Accounts' AND type = 'U')
BEGIN
    CREATE TABLE Accounts (
        id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
        username VARCHAR(255) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        role_id INT NOT NULL, 
        FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
    );
END
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'permissions' AND type = 'U')
BEGIN
    CREATE TABLE permissions (
        id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
        role_id INT NOT NULL,
        permission_name NVARCHAR(50) NOT NULL,
        FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
    );
END
GO

IF NOT EXISTS (SELECT * FROM roles WHERE role_name = 'admin')
BEGIN
    INSERT INTO roles (role_name) VALUES ('admin'), ('dev'), ('user');
END
GO

IF NOT EXISTS (SELECT * FROM Accounts WHERE username = 'IN23')
BEGIN
    DECLARE @role_id INT;
    SELECT @role_id = id FROM roles WHERE role_name = 'dev';

    INSERT INTO Accounts (username, password, role_id)
    VALUES ('IN23', '$2y$10$MWYm7RKEVJ8Us7S1S4j/n.l4yEDQzytDMH15PCFT0YZvYGc7nqUnC', @role_id);
END
GO

IF NOT EXISTS (SELECT * FROM permissions WHERE permission_name = 'dev')
BEGIN
    DECLARE @admin_role INT, @dev_role INT, @user_role INT;
    
    SELECT @admin_role = id FROM roles WHERE role_name = 'admin';
    SELECT @dev_role = id FROM roles WHERE role_name = 'dev';
    SELECT @user_role = id FROM roles WHERE role_name = 'user';

    INSERT INTO permissions (role_id, permission_name) VALUES
    (@admin_role, 'manage_shop'),
    (@dev_role, 'dev'),
    (@dev_role, 'manage_roles'),
    (@user_role, 'custom');
END
GO

USE [master]
GO

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Marketbasket')
BEGIN
    CREATE DATABASE Marketbasket;
END
GO

USE [Marketbasket];
GO
DROP TABLE IF EXISTS [dbo].[Einkauf_Produkte];
GO
DROP TABLE IF EXISTS [dbo].[Einkauf];
GO
DROP TABLE IF EXISTS [dbo].[Produkte];
GO
DROP TABLE IF EXISTS [dbo].[Personen];
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'Produkte' AND type = 'U')
BEGIN
CREATE TABLE [dbo].[Produkte](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Produkt] [varchar](50) NULL,
 CONSTRAINT [PK_Produkte] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'Personen' AND type = 'U')
BEGIN
CREATE TABLE [dbo].[Personen](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Vorname] [varchar](50) NULL,
	[Nachname] [varchar](50) NULL,
	[Geburtstag] [date] NULL,
	[Stadt] [varchar](50) NULL,
	[Postleitzahl] [varchar](50) NULL,
	[Straße] [varchar](50) NULL,
	[Hausnummer] [varchar](10) NULL,
 CONSTRAINT [PK_Personen] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'Einkauf' AND type = 'U')
BEGIN
CREATE TABLE [dbo].[Einkauf](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PersonenID] [int] NULL,
	[Einkaufsdatum] [datetime] NULL,
 CONSTRAINT [PK_Einkauf] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'Einkauf_Produkte' AND type = 'U')
BEGIN
CREATE TABLE [dbo].[Einkauf_Produkte](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[EinkaufID] [int] NULL,
	[ProduktID] [int] NULL,
 CONSTRAINT [PK_Einkauf_Produkte] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO


ALTER TABLE [dbo].[Einkauf]  WITH CHECK ADD  CONSTRAINT [FK_Einkauf_Personen] FOREIGN KEY([PersonenID])
REFERENCES [dbo].[Personen] ([ID])
GO

ALTER TABLE [dbo].[Einkauf] CHECK CONSTRAINT [FK_Einkauf_Personen]
GO
END
GO


ALTER TABLE [dbo].[Einkauf_Produkte]  WITH CHECK ADD  CONSTRAINT [FK_Einkauf_Produkte_Einkauf] FOREIGN KEY([EinkaufID])
REFERENCES [dbo].[Einkauf] ([ID])
GO

ALTER TABLE [dbo].[Einkauf_Produkte] CHECK CONSTRAINT [FK_Einkauf_Produkte_Einkauf]
GO

ALTER TABLE [dbo].[Einkauf_Produkte]  WITH CHECK ADD  CONSTRAINT [FK_Einkauf_Produkte_Produkte] FOREIGN KEY([ProduktID])
REFERENCES [dbo].[Produkte] ([ID])
GO

ALTER TABLE [dbo].[Einkauf_Produkte] CHECK CONSTRAINT [FK_Einkauf_Produkte_Produkte]
GO

END
GO

CREATE OR ALTER VIEW [dbo].[Market Basket 1]
AS
WITH Info AS (SELECT        OrderList.EinkaufID, OrderList.ProduktIDs
                               FROM            (SELECT        EinkaufID, COUNT(ProduktID) AS ProduktIDs
                                                         FROM            dbo.Einkauf_Produkte
                                                         GROUP BY EinkaufID
                                                         HAVING         (COUNT(ProduktID) >= 2)) AS OrderList INNER JOIN
                                                        dbo.Einkauf AS Eink ON OrderList.EinkaufID = Eink.ID INNER JOIN
                                                        dbo.Produkte AS Prod ON OrderList.ProduktIDs = Prod.ID)
    SELECT        TOP (100) PERCENT Info1.ProduktIDs AS Product1, Info2.ProduktIDs AS Product2, COUNT(*) AS Frequency
     FROM            Info AS Info1 INNER JOIN
                              Info AS Info2 ON Info1.EinkaufID = Info2.EinkaufID AND Info1.ProduktIDs <> Info2.ProduktIDs AND Info1.ProduktIDs < Info2.ProduktIDs
     GROUP BY Info1.ProduktIDs, Info2.ProduktIDs
     ORDER BY Frequency
GO

Create OR Alter View MarketbasketMPSO AS
WITH Info AS
(SELECT
	OrderList.EinkaufID,
	OrderList.ProduktIDs
FROM
	(SELECT
		EinkaufID,
		COUNT(ProduktID) AS ProduktIDs
	FROM Einkauf_Produkte
	GROUP BY EinkaufID
	HAVING COUNT(ProduktID) >= 2) AS OrderList
JOIN Einkauf AS Eink ON OrderList.EinkaufID = Eink.ID
JOIN Produkte AS Prod ON OrderList.ProduktIDs = Prod.ID)

SELECT 
	Info1.EinkaufID AS Einkaufsnummer,
	Info1.ProduktIDs AS Product1,
	Info2.ProduktIDs AS Product2
FROM Info AS Info1
JOIN Info AS Info2 ON Info1.EinkaufID = Info2.EinkaufID
WHERE Info1.ProduktIDs != Info2.ProduktIDs 
  AND Info1.ProduktIDs < Info2.ProduktIDs;
GO
Insert into dbo.Personen (Vorname, Nachname, Geburtstag, Stadt, Postleitzahl, Straße, Hausnummer) Values
 (N'Gitte', N'Eigenwillig', N'1943-04-04', N'Göppingen', N'59146', N'Karl-Georg-auch Schlauchin-Platz', N'2'),
 (N'Uta', N'Heidrich', N'1995-12-21', N'Zerbst', N'83987', N'Zobelweg', N'7/1'),
 (N'Hubert', N'Häring', N'1957-12-12', N'Seelow', N'27641', N'Hedi-Walter-Ring', N'6'),
 (N'Marion', N'Hentschel', N'1943-09-07', N'Berchtesgaden', N'86997', N'Lotti-Jessel-Weg', N'84'),
 (N'Notburga', N'Weinhold', N'1997-10-11', N'Hohenstein-Ernstthal', N'48030', N'Wellerstr.', N'6'),
 (N'Wenzel', N'Mitschke', N'1974-12-14', N'Töbingen', N'07833', N'Kuschplatz', N'20'),
 (N'Erwin', N'Stoll', N'2002-10-16', N'Borna', N'21558', N'Ilija-Ruppert-Weg', N'4'),
 (N'Ehrenfried', N'Etzold', N'1952-03-02', N'Burg', N'11232', N'Rudolphgasse', N'5'),
 (N'Gudrun', N'Mentzel', N'1975-02-06', N'Lödinghausen', N'23865', N'Pia-Matthäi-Ring', N'34'),
 (N'Jörgen', N'Stiffel', N'1994-06-13', N'Kehl', N'58217', N'Beckmanngasse', N'1'),
 (N'Jonathan', N'Kroker', N'2001-04-14', N'Diepholz', N'74043', N'Ehlertstr.', N'46'),
 (N'Silva', N'Junitz', N'1959-02-18', N'Schlöchtern', N'63182', N'Cornelius-Dühn-Gasse', N'734'),
 (N'Metin', N'Karge', N'1951-03-19', N'Riesa', N'72985', N'Hans-Ulrich-Bohnbach-Allee', N'8/9'),
 (N'Mathilde', N'Weller', N'1952-03-27', N'Brand', N'85491', N'Jolanda-Hermann-Ring', N'0'),
 (N'Hatice', N'Ehlert', N'1964-10-25', N'Geldern', N'22041', N'Hahnplatz', N'225'),
 (N'Friedl', N'Ruppert', N'1937-04-17', N'Schrobenhausen', N'74935', N'Hillerweg', N'5'),
 (N'Angelina', N'Mielcarek', N'1935-08-24', N'Goslar', N'51830', N'Katarzyna-Bender-Gasse', N'556'),
 (N'Elzbieta', N'Bonbach', N'1996-12-25', N'Ahaus', N'25484', N'Jacqueline-Ziegert-Weg', N'0/2'),
 (N'Wiltrud', N'Lüwer', N'2000-05-09', N'Gerolzhofen', N'73971', N'Bernard-Zimmer-Weg', N'630'),
 (N'Annie', N'Baum', N'2003-06-09', N'Apolda', N'76042', N'Timo-Weinhage-Gasse', N'507'),
 (N'Jakob', N'Trapp', N'2007-02-13', N'Hildburghausen', N'86206', N'Putzplatz', N'1/7'),
 (N'Gölay', N'Bohlander', N'2005-03-18', N'Recklinghausen', N'90709', N'Paffrathplatz', N'295'),
 (N'Fredi', N'Meyer', N'2006-05-09', N'Angermönde', N'03718', N'Isabella-Rudolph-Gasse', N'4'),
 (N'Oxana', N'Schlosser', N'1967-04-27', N'Eisleben', N'29119', N'Stadelmannstraße', N'3'),
 (N'Emmerich', N'Trupp', N'1973-03-27', N'Griesbach Rottal', N'17448', N'Heribert-Weinhage-Straße', N'4/1'),
 (N'Alina', N'Lüffler', N'1989-01-21', N'Löbben', N'48328', N'Kuschstr.', N'36'),
 (N'Marvin', N'Weimer', N'1975-05-14', N'Roding', N'69854', N'van der Dussenring', N'492'),
 (N'Danuta', N'Wilms', N'1991-03-11', N'Artern', N'86605', N'Gesche-Wulff-Platz', N'0'),
 (N'Reimer', N'Tröb', N'1940-10-10', N'Rockenhausen', N'96366', N'Ulla-Jäkel-Ring', N'12'),
 (N'Sigurd', N'Rose', N'1971-09-17', N'Freudenstadt', N'16305', N'Schlosserstr.', N'24'),
 (N'Felix', N'Hoffmann', N'2005-11-19', N'Badalzungen', N'42132', N'Otto-Wiek-Straße', N'0'),
 (N'Aleksandr', N'Koch', N'1968-04-27', N'Apolda', N'21096', N'Lioba-Rohleder-Straße', N'6/7'),
 (N'Törkan', N'Wesack', N'1941-04-12', N'Hönfeld', N'50576', N'Ramon-Neuschäfer-Allee', N'383'),
 (N'Jessika', N'Eberth', N'1959-07-07', N'Ilmenau', N'56094', N'Benjamin-Fiebig-Ring', N'136'),
 (N'Inka', N'Bloch', N'1951-10-28', N'Fulda', N'02835', N'Gunther-Kraushaar-Ring', N'224'),
 (N'Maja', N'Kraushaar', N'1934-06-13', N'Sangerhausen', N'00222', N'Damian-Johann-Gasse', N'29'),
 (N'Friedhold', N'Baum', N'1948-09-14', N'Apolda', N'12243', N'Klaus-Ulrich-Jäkel-Platz', N'696'),
 (N'Filiz', N'Seifert', N'1995-01-20', N'Gürlitz', N'17863', N'Speerallee', N'713'),
 (N'Edmund', N'Kaul', N'1948-08-27', N'Konstanz', N'50479', N'Silke-Binner-Allee', N'43'),
 (N'Kornelia', N'Jessel', N'1952-10-10', N'Gardelegen', N'76280', N'Vladimir-Gutknecht-Straße', N'04'),
 (N'Renate', N'Schünland', N'1968-10-04', N'Sangerhausen', N'47752', N'Jolanda-Rädel-Weg', N'0'),
 (N'Andrei', N'Gutknecht', N'1948-06-17', N'Gürlitz', N'94917', N'Bernhard-Henck-Weg', N'31'),
 (N'Woldemar', N'Dehmel', N'1995-02-10', N'Ebern', N'37465', N'Weinholdplatz', N'4/3'),
 (N'Olivia', N'Kitzmann', N'1956-07-28', N'Mittweida', N'72255', N'Radischstr.', N'70'),
 (N'Annelise', N'Sößebier', N'1964-05-13', N'Groß-Gerau', N'63075', N'Mälzerstr.', N'5'),
 (N'Alfredo', N'Junken', N'1969-12-05', N'Eutin', N'91778', N'Gertzstr.', N'8'),
 (N'Jochem', N'Kallert', N'1943-02-15', N'Hettstedt', N'21608', N'Muzaffer-Hamann-Weg', N'2/8'),
 (N'Rocco', N'Salz', N'1944-09-04', N'Regensburg', N'55422', N'Harald-Otto-Weg', N'116'),
 (N'Gebhard', N'Otto', N'1991-09-12', N'Schwäbisch Gmönd', N'58006', N'Anita-Hermighausen-Platz', N'071'),
 (N'Ingrid', N'Salz', N'1955-08-13', N'Rottweil', N'91954', N'Emmerich-Holsten-Ring', N'3'),
 (N'Inken', N'Boucsein', N'1964-03-17', N'Güttingen', N'87439', N'Fliegnerallee', N'458'),
 (N'Dagobert', N'Martin', N'1949-08-26', N'Weimar', N'38981', N'Knappestr.', N'888'),
 (N'Christian', N'Reinhardt', N'1934-06-21', N'Dessau', N'58408', N'Faruk-Peukert-Gasse', N'80'),
 (N'Margret', N'Müchlichen', N'1998-02-25', N'Hechingen', N'48844', N'Mirko-Jessel-Weg', N'513'),
 (N'Knut', N'Drub', N'1994-05-18', N'Bad Kreuznach', N'36112', N'Martha-Winkler-Allee', N'949'),
 (N'Olaf', N'Reinhardt', N'1962-11-04', N'Sulzbach-Rosenberg', N'08478', N'H.-Dieter-Heintze-Ring', N'18'),
 (N'Manfred', N'Sager', N'1987-03-14', N'Konstanz', N'27042', N'Agatha-Wende-Allee', N'365'),
 (N'Nadine', N'Schottin', N'1987-12-08', N'Geldern', N'94169', N'Lissy-Lorch-Gasse', N'714'),
 (N'Hans-Willi', N'Weiß', N'1983-08-31', N'Erding', N'86924', N'Dehmelgasse', N'6/4'),
 (N'Bernward', N'Kabus', N'1959-04-05', N'Gerolzhofen', N'90533', N'Benderstraße', N'949'),
 (N'Reimer', N'Bolnbach', N'1973-06-26', N'Gelnhausen', N'56871', N'Kostolzinplatz', N'350'),
 (N'Alessandro', N'Trub', N'1940-06-19', N'Darmstadt', N'47760', N'Scheuermannring', N'91'),
 (N'Heinz-Dieter', N'Speer', N'1938-03-17', N'Freital', N'60572', N'Schmiedeckestr.', N'384'),
 (N'Annegrete', N'Pergande', N'1985-08-11', N'Wesel', N'93067', N'Frankeweg', N'52'),
 (N'Harriet', N'Barkholz', N'1973-11-27', N'Sankt Goarshausen', N'92421', N'Irmhild-Briemer-Ring', N'16'),
 (N'Wenke', N'Hettner', N'1985-04-06', N'Riesa', N'88585', N'Karoline-Hofmann-Ring', N'2'),
 (N'Luise', N'Fürster', N'1948-08-19', N'Töbingen', N'95171', N'Betina-Ortmann-Ring', N'0/8'),
 (N'Frederic', N'Wilms', N'1970-07-23', N'Burglengenfeld', N'14707', N'Ottomar-Blömel-Ring', N'9/1'),
 (N'Orhan', N'Ladeck', N'1954-07-04', N'Cloppenburg', N'24295', N'Roggeweg', N'84'),
 (N'Jolanta', N'Ladeck', N'1935-02-16', N'Hohenmülsen', N'37761', N'Beyergasse', N'2'),
 (N'Edeltrud', N'Kabus', N'1974-10-02', N'Malchin', N'65070', N'Berend-Schinke-Straße', N'342'),
 (N'Mahmut', N'Schmidt', N'1954-03-25', N'Kleve', N'42954', N'Hentschelgasse', N'451'),
 (N'Jacek', N'Schulz', N'1981-04-07', N'Eichstätt', N'12456', N'Mechthild-Barth-Allee', N'5'),
 (N'Mareike', N'Heydrich', N'1991-06-02', N'Aachen', N'99631', N'Rosenowplatz', N'2'),
 (N'Aleksandr', N'Bonbach', N'1948-09-06', N'Weißwasser', N'45287', N'Zdenka-Ernst-Weg', N'4/5'),
 (N'Hanns', N'Mitschke', N'1986-12-16', N'Bergzabern', N'92946', N'Loosweg', N'616'),
 (N'Gönther', N'Schmiedecke', N'1940-04-03', N'Parsberg', N'25874', N'Lindnerweg', N'1'),
 (N'Pierre', N'Jähn', N'1969-05-03', N'Bamberg', N'32565', N'Niemeierstraße', N'23'),
 (N'Ursel', N'Weitzel', N'1981-02-26', N'Schwabmönchen', N'87506', N'Weinholdring', N'0'),
 (N'Edeltraud', N'Loos', N'1970-07-31', N'Ribnitz-Damgarten', N'68810', N'Christophgasse', N'0'),
 (N'Karl-Jörgen', N'Martin', N'1945-10-13', N'Holzminden', N'34283', N'Annelore-Budig-Straße', N'8'),
 (N'Hansjürg', N'Dobes', N'1952-07-22', N'Dachau', N'54133', N'Steckelallee', N'183'),
 (N'Steven', N'Bien', N'2000-10-16', N'Melle', N'02563', N'Kambsstraße', N'319'),
 (N'Kurt', N'Scholtz', N'1975-05-01', N'Bautzen', N'35018', N'Moritz-Tröb-Straße', N'1'),
 (N'Zehra', N'Schlosser', N'1980-08-05', N'Büblingen', N'99900', N'Irma-Gorlitz-Ring', N'9'),
 (N'Xaver', N'Ehlert', N'1953-06-13', N'Wolfenböttel', N'57177', N'Seifertring', N'185'),
 (N'Fred', N'Knappe', N'1953-06-23', N'Viechtach', N'55542', N'Suse-Buchholz-Straße', N'037'),
 (N'Olena', N'Löbs', N'1976-10-31', N'Möhldorf am Inn', N'35151', N'Walther-Girschner-Ring', N'56'),
 (N'Gudrun', N'Hamann', N'1996-11-11', N'Neustadt am Röbenberge', N'10203', N'Gregor-Flantz-Straße', N'913'),
 (N'Pia', N'Stumpf', N'1993-03-29', N'Euskirchen', N'79731', N'Hürlestraße', N'1'),
 (N'Gerolf', N'Niemeier', N'1965-03-10', N'Wittmund', N'85277', N'Heidelinde-Henschel-Ring', N'38'),
 (N'Rouven', N'Schuchhardt', N'1980-02-19', N'Bad Mergentheim', N'09586', N'Eggert-Gieß-Platz', N'43'),
 (N'Hans-Gönther', N'Schmidt', N'1943-05-11', N'Sankt Goar', N'82720', N'Hans D.-Wulff-Gasse', N'423'),
 (N'Jost', N'Bonbach', N'2005-01-04', N'Brilon', N'52175', N'Magda-Dussen van-Gasse', N'3/7'),
 (N'Claus', N'Heß', N'1940-03-21', N'Osterburg', N'19181', N'Hans-Gerd-Lindner-Platz', N'13'),
 (N'Yvonne', N'Kraushaar', N'1969-01-11', N'Genthin', N'31833', N'Friedrich-Gieß-Ring', N'42'),
 (N'Anneli', N'Krebs', N'1963-09-29', N'Marktheidenfeld', N'53128', N'Matteo-Jacob-Ring', N'8'),
 (N'Otfried', N'Reising', N'1959-09-29', N'Aurich', N'12097', N'Eigenwilligstr.', N'52'),
 (N'Loni', N'Klemm', N'1997-05-18', N'Northeim', N'49275', N'Weißstr.', N'44'),
 (N'Gerolf', N'Eckbauer', N'1986-10-03', N'Förstenwalde', N'34637', N'Walburga-Binner-Ring', N'988'),
 (N'Miroslaw', N'Trubin', N'1985-12-26', N'Badalzungen', N'78534', N'Heydrichallee', N'6/5'),
 (N'Helge', N'Austermöhle', N'1995-10-08', N'Tuttlingen', N'05482', N'Uschi-Birnbaum-Gasse', N'6'),
 (N'Claas', N'Pruschke', N'1938-04-08', N'Bötzow', N'64086', N'Lüchelgasse', N'0/6'),
 (N'Krzysztof', N'Walter', N'2000-05-20', N'Gadebusch', N'38720', N'Ullmanngasse', N'376'),
 (N'Steve', N'Sontag', N'1964-07-19', N'Helmstedt', N'30168', N'Carla-Kaul-Straße', N'47'),
 (N'Senta', N'Gierschner', N'1997-02-20', N'Hamburg', N'98083', N'Regine-Lüwer-Gasse', N'530'),
 (N'Walentina', N'Bürner', N'1937-09-28', N'Bad Liebenwerda', N'73048', N'Hanife-Zimmer-Gasse', N'2'),
 (N'Iwan', N'Mohaupt', N'2005-06-20', N'Heinsberg', N'36361', N'Katrin-Rosemann-Straße', N'9'),
 (N'Luzie', N'Lüwer', N'1936-01-30', N'Aurich', N'28487', N'Weitzelstraße', N'2/1'),
 (N'Georg', N'Mölichen', N'1935-12-25', N'Fössen', N'72697', N'Reinhild-Rürricht-Straße', N'47'),
 (N'Iwan', N'Jacob', N'1938-06-15', N'Passau', N'26095', N'Vogtweg', N'5'),
 (N'Mohammed', N'Henck', N'1938-07-07', N'Waldmönchen', N'11673', N'Hermighausenring', N'01'),
 (N'Lisette', N'Fürster', N'1995-10-15', N'Badoberan', N'19370', N'Etta-Junk-Weg', N'096'),
 (N'Florentine', N'Hamann', N'1951-12-23', N'Backnang', N'66801', N'Ullrichweg', N'318'),
 (N'Gottfried', N'Zorbach', N'1936-02-15', N'Jölich', N'53237', N'Uta-Pülitz-Allee', N'317'),
 (N'Brigitta', N'Butte', N'1953-04-15', N'Saarbröcken', N'33816', N'Höseyin-Süding-Straße', N'418'),
 (N'Evelin', N'Hahn', N'1995-10-12', N'Chemnitz', N'12726', N'Freudenbergerring', N'1/6'),
 (N'Waltrud', N'Hering', N'1944-04-11', N'Sümmerda', N'05824', N'Holstenplatz', N'7'),
 (N'Beatrix', N'Bloch', N'1984-03-28', N'Dübeln', N'25292', N'Buchholzplatz', N'8/8'),
 (N'Angela', N'Stroh', N'1953-04-14', N'Delitzsch', N'34538', N'Henkallee', N'026'),
 (N'Filiz', N'Boucsein', N'1959-05-03', N'Säckingen', N'11946', N'Heinz-Wilhelm-Zimmer-Platz', N'7/4'),
 (N'Slobodan', N'Karge', N'1938-02-01', N'Güttingen', N'36210', N'Schuchhardtplatz', N'7/2'),
 (N'Gaby', N'Carsten', N'1946-07-26', N'Ilmenau', N'73434', N'Diedrich-Hänel-Platz', N'5'),
 (N'Stanislaw', N'Biggen', N'1956-02-18', N'Seelow', N'52882', N'Mario-Weimer-Ring', N'8'),
 (N'Karen', N'Stey', N'1934-12-29', N'Arnstadt', N'02497', N'Löbsallee', N'757'),
 (N'Gundel', N'Huhn', N'1986-06-13', N'Bad Mergentheim', N'04711', N'Alfred-Ruppersberger-Straße', N'9/0'),
 (N'Aneta', N'Bähr', N'1967-09-03', N'Gerolzhofen', N'80405', N'Evamaria-Kambs-Platz', N'1'),
 (N'Margrit', N'Haering', N'1947-06-13', N'Worbis', N'02327', N'Dussen vanstr.', N'6/9'),
 (N'Olga', N'Ring', N'1944-03-26', N'Hannoversch Mönden', N'84098', N'Joseph-Gerlach-Ring', N'4/7'),
 (N'Viktor', N'Tröb', N'1948-07-16', N'Jessen', N'16091', N'Jockelplatz', N'4/5'),
 (N'Rupert', N'Hahn', N'1992-06-15', N'Vechta', N'87390', N'Anni-Wesack-Straße', N'38'),
 (N'Frederike', N'Dowerg', N'2001-09-22', N'Chemnitz', N'84412', N'Reimer-Mans-Weg', N'193'),
 (N'Klaus-Peter', N'Zirme', N'1996-04-24', N'Mittweida', N'99562', N'Alicia-Ebert-Platz', N'468'),
 (N'Carlos', N'Weller', N'1938-01-08', N'Sigmaringen', N'25584', N'Leonard-Rose-Allee', N'7/3'),
 (N'Manuel', N'Siering', N'1940-10-26', N'Perleberg', N'76648', N'Düringweg', N'3'),
 (N'Ricardo', N'Binner', N'1984-01-12', N'Bad Langensalza', N'19527', N'Gnatzstraße', N'0/6'),
 (N'Angelica', N'Schmidtke', N'1984-07-16', N'Rottweil', N'96335', N'Beckmannring', N'98'),
 (N'Kirsten', N'Buchholz', N'1998-07-08', N'Gera', N'39911', N'Claas-Drub-Ring', N'3/7'),
 (N'Friedlinde', N'Sauer', N'1997-02-26', N'Dinkelsböhl', N'95730', N'Theo-Drewes-Ring', N'54'),
 (N'Sami', N'Henck', N'1953-09-12', N'Ludwigslust', N'30100', N'Giuseppe-Junitz-Weg', N'09'),
 (N'Tadeusz', N'Lüchel', N'2007-04-06', N'Goslar', N'92733', N'Hessering', N'1/0'),
 (N'Rose-Marie', N'Hartmann', N'1967-08-07', N'Steinfurt', N'67992', N'Mendeweg', N'2/2'),
 (N'Roland', N'Biggen', N'1964-07-06', N'Erkelenz', N'52858', N'Annelie-Rogner-Gasse', N'0/2'),
 (N'Hanne', N'Herrmann', N'1978-09-15', N'Grimmen', N'55217', N'Pieperstraße', N'9'),
 (N'Hans-Wilhelm', N'Anders', N'1999-05-26', N'Soltau', N'35872', N'Ehrentraud-Pergande-Weg', N'299'),
 (N'Toni', N'Jacobi Jäckel', N'2004-11-03', N'Ludwigslust', N'40092', N'Sebastian-Keudel-Allee', N'1'),
 (N'Patrik', N'Berger', N'1943-08-21', N'Güttingen', N'64584', N'Anastasios-Ziegert-Allee', N'1/1'),
 (N'Sven', N'Huhn', N'1988-01-06', N'Niesky', N'50531', N'Südingallee', N'871'),
 (N'Karl-Dieter', N'Thanel', N'1947-11-03', N'Hofgeismar', N'09349', N'Nicolai-Sorgatz-Ring', N'5'),
 (N'Carolina', N'Klingelhüfer', N'1963-09-18', N'Pirmasens', N'07760', N'Claire-Dietz-Gasse', N'661'),
 (N'Denis', N'Dobes', N'1949-03-18', N'Recklinghausen', N'00418', N'Ottostr.', N'13'),
 (N'Fred', N'Wulf', N'1940-10-02', N'Erkelenz', N'20400', N'Swetlana-Bender-Ring', N'752'),
 (N'Linda', N'Mitschke', N'1978-04-06', N'Einbeck', N'78450', N'Kranzweg', N'903'),
 (N'Hilda', N'Jöttner', N'1993-11-11', N'Bad Kissingen', N'06970', N'Schachtstr.', N'727'),
 (N'Slawomir', N'Heintze', N'1992-08-21', N'Wunsiedel', N'70213', N'Salzstr.', N'45'),
 (N'Carl', N'Adler', N'1978-03-09', N'Eisleben', N'17509', N'Rustweg', N'0'),
 (N'Bernfried', N'Rudolph', N'1997-12-03', N'Meißen', N'44912', N'Rudolphgasse', N'0'),
 (N'Raisa', N'Misicher', N'1950-08-30', N'Bad Langensalza', N'15833', N'Erol-Steinberg-Weg', N'6/8'),
 (N'Jolanthe', N'Weimer', N'1983-02-01', N'Leipziger Land', N'15270', N'Cichoriusstraße', N'53'),
 (N'Benno', N'Krein', N'1984-10-24', N'Hamburg', N'43297', N'Benderweg', N'945'),
 (N'Dorota', N'Trapp', N'1970-09-02', N'Riesa', N'90099', N'Kunigunde-Ehlert-Straße', N'4/9'),
 (N'Arnold', N'Wulf', N'1968-12-01', N'Wunsiedel', N'00787', N'Eckbauerallee', N'4/4'),
 (N'Flora', N'Jockel', N'1946-01-09', N'Wittstock', N'06947', N'Binnergasse', N'3/5'),
 (N'Friedrich', N'Gumprich', N'2007-04-30', N'Delitzsch', N'87300', N'Beata-Müchlichen-Straße', N'8'),
 (N'Enno', N'Jacobi Jäckel', N'1939-11-17', N'Hamburg', N'17343', N'Thiesstraße', N'980'),
 (N'Sigrun', N'Segebahn', N'1993-05-27', N'Osterode am Harz', N'74338', N'Schünlandring', N'8/3'),
 (N'Frieda', N'Wulff', N'1982-12-01', N'Regen', N'43153', N'Stadelmannstr.', N'9/1'),
 (N'Annelie', N'Kensy', N'1949-10-02', N'Wurzen', N'13373', N'Mareen-Wähner-Ring', N'206'),
 (N'Gunther', N'Koch', N'1965-11-05', N'Eutin', N'89316', N'Blömelstraße', N'105'),
 (N'Renate', N'Karge', N'1934-07-24', N'Bersenbröck', N'65381', N'Natalija-Knappe-Allee', N'176'),
 (N'Hannchen', N'Haase', N'1977-05-31', N'Berchtesgaden', N'71852', N'Dühnstraße', N'01'),
 (N'Rödiger', N'Ditschlerin', N'1956-09-19', N'Pinneberg', N'92294', N'Natascha-Sößebier-Ring', N'607'),
 (N'Birger', N'Scholz', N'1942-03-03', N'Celle', N'98993', N'Tim-Jacob-Allee', N'8/1'),
 (N'Ilias', N'Kruschwitz', N'2000-10-22', N'Weißenfels', N'04349', N'Wilmsenweg', N'468'),
 (N'Lidia', N'Gutknecht', N'1982-10-17', N'Heinsberg', N'46929', N'Katy-Steckel-Weg', N'673'),
 (N'Ewa', N'Roht', N'1982-01-04', N'Regensburg', N'31421', N'Sabri-Carsten-Weg', N'7'),
 (N'Adina', N'Roht', N'1996-02-19', N'Perleberg', N'47639', N'Heintzeweg', N'7'),
 (N'Siegward', N'Otto', N'1976-03-01', N'Riesa', N'98805', N'Gerhard-Mitschke-Weg', N'8/3'),
 (N'Werner', N'Stey', N'1958-06-13', N'Emmendingen', N'10927', N'Säuberlichweg', N'2'),
 (N'Adolf', N'Kensy', N'1947-01-24', N'Gießen', N'75351', N'Reichmannstraße', N'0/4'),
 (N'Katerina', N'Caspar', N'1959-07-08', N'Gürlitz', N'48803', N'Fechnerstraße', N'64'),
 (N'Gottlob', N'Hülzenbecher', N'1966-07-03', N'Sebnitz', N'02161', N'Fliegnerweg', N'781'),
 (N'Ralf-Dieter', N'Rogner', N'2000-05-13', N'Soest', N'08673', N'Patbergweg', N'9'),
 (N'Jozef', N'Bachmann', N'1991-11-16', N'Hersbruck', N'86723', N'Rochus-Weinhage-Ring', N'4'),
 (N'Urte', N'Steckel', N'1986-05-04', N'Sangerhausen', N'02586', N'Erhardt-Schottin-Platz', N'23'),
 (N'Hildburg', N'Wilms', N'1940-03-30', N'Staffelstein', N'26504', N'Henschelplatz', N'006'),
 (N'Herrmann', N'Holsten', N'1957-05-03', N'Osterode am Harz', N'11289', N'Enno-Bohlander-Straße', N'8'),
 (N'Leyla', N'Preiß', N'1998-03-10', N'Sankt Goarshausen', N'08883', N'Heingasse', N'2/9'),
 (N'Victor', N'Haase', N'1945-12-29', N'Säckingen', N'58724', N'Hartungweg', N'50'),
 (N'Karina', N'Jäntsch', N'1950-03-13', N'Gifhorn', N'69194', N'Cichoriusring', N'8/2'),
 (N'Nada', N'Weimer', N'1943-02-24', N'Möhlhausen', N'03090', N'Conradigasse', N'796'),
 (N'Frederike', N'Hartung', N'1964-08-30', N'Altentreptow', N'30318', N'Reichmannstr.', N'26'),
 (N'Waldemar', N'Trapp', N'1987-12-26', N'Mayen', N'62400', N'Gislinde-Henschel-Ring', N'222'),
 (N'Anneliese', N'Noack', N'1953-06-24', N'Schwabmönchen', N'22905', N'Pia-Kitzmann-Ring', N'22'),
 (N'Ilija', N'Jäkel', N'1979-04-09', N'Donaueschingen', N'33677', N'Eva-Cichorius-Weg', N'2'),
 (N'Birte', N'Meyer', N'1999-08-02', N'Ingolstadt', N'49240', N'Lachmannweg', N'0'),
 (N'Marcella', N'Stey', N'1973-12-04', N'Brandenburg', N'77930', N'Max-Christoph-Straße', N'866'),
 (N'Udo', N'Heinz', N'1951-09-14', N'Miesbach', N'88663', N'Dobesstraße', N'163'),
 (N'Ada', N'Seidel', N'1976-11-07', N'Rockenhausen', N'50378', N'Bohlanderplatz', N'10'),
 (N'Manja', N'Holzapfel', N'1974-07-07', N'Stollberg', N'39022', N'Anja-Neureuther-Allee', N'512'),
 (N'Carl', N'Ditschlerin', N'1963-03-08', N'Miltenberg', N'30488', N'Jürg-Müchlichen-Gasse', N'167'),
 (N'Jo', N'Gute', N'2001-10-22', N'Eisleben', N'89171', N'Margit-van der Dussen-Allee', N'9'),
 (N'Gertrud', N'Jäkel', N'1939-01-14', N'Querfurt', N'11395', N'Anne-Hermann-Ring', N'9/8'),
 (N'Marija', N'Junk', N'1937-09-28', N'Monschau', N'66501', N'Rührichtring', N'572'),
 (N'Rita', N'Dussen van', N'2004-12-14', N'Uelzen', N'46171', N'Zobelring', N'22'),
 (N'Laurenz', N'Beier', N'1965-06-15', N'Plauen', N'59967', N'Strohstr.', N'0'),
 (N'Hans-Christian', N'Ebert', N'2002-10-04', N'Weißwasser', N'36124', N'Rennerallee', N'0'),
 (N'Grazyna', N'Weinhold', N'1948-07-30', N'Lödinghausen', N'53145', N'Pasquale-Zorbach-Weg', N'481'),
 (N'Ahmed', N'Schmidt', N'1962-08-07', N'Wetzlar', N'66503', N'Dietlinde-Roht-Ring', N'5/6'),
 (N'Abdullah', N'Pärtzelt', N'1974-05-10', N'Bayreuth', N'31930', N'Roland-Fritsch-Weg', N'55'),
 (N'Alexej', N'Metz', N'1979-03-06', N'Eberswalde', N'14485', N'Ignaz-Ladeck-Ring', N'7'),
 (N'Denise', N'Gertz', N'1967-08-07', N'Garmisch-Partenkirchen', N'44422', N'Hajo-Wilms-Allee', N'3'),
 (N'Vitali', N'Klotz', N'1956-11-19', N'Dören', N'42670', N'Bährallee', N'705'),
 (N'Ann', N'Barkholz', N'1952-01-17', N'Stadtroda', N'77608', N'Bauergasse', N'7/1'),
 (N'Gitta', N'Beckmann', N'1984-04-02', N'Eutin', N'69380', N'Elenore-Mölichen-Weg', N'0/3'),
 (N'Antonios', N'Heidrich', N'1961-11-29', N'Eutin', N'86211', N'Frühlichplatz', N'657'),
 (N'Gretchen', N'Schöler', N'2005-06-13', N'Soltau', N'67554', N'Brunhilde-Wagenknecht-Allee', N'801'),
 (N'Felicitas', N'Klotz', N'1959-08-25', N'Witzenhausen', N'08141', N'Frankeplatz', N'80'),
 (N'Betty', N'Linke', N'1978-07-13', N'Greiz', N'10251', N'Jopichallee', N'241'),
 (N'Gölsen', N'Binner', N'1956-03-29', N'Darmstadt', N'51563', N'Rainer-Schuchhardt-Weg', N'7/5'),
 (N'Gretchen', N'Aumann', N'1940-05-04', N'Schongau', N'87098', N'Pruschkestr.', N'7/0'),
 (N'Lilly', N'Hauffer', N'1950-03-01', N'Darmstadt', N'58081', N'Birnbaumgasse', N'0/0'),
 (N'Adam', N'Gute', N'1948-04-14', N'Moers', N'50244', N'Alexa-Rühricht-Platz', N'00'),
 (N'Tilo', N'Killer', N'1982-09-27', N'Wittenberg', N'06706', N'Dowergplatz', N'5/9'),
 (N'Ioannis', N'Koch II', N'1972-12-30', N'Strausberg', N'14241', N'Luzia-Schmidt-Gasse', N'5'),
 (N'Artur', N'Plath', N'1983-02-08', N'Helmstedt', N'08254', N'Agathe-Hoffmann-Straße', N'9/0'),
 (N'Jorge', N'Scheel', N'1985-09-18', N'Schlöchtern', N'63296', N'Willibald-Hartung-Platz', N'7/5'),
 (N'Adolf', N'Klemt', N'1968-08-28', N'Torgau', N'01757', N'Nikola-Ritter-Allee', N'8'),
 (N'Elly', N'Eberth', N'1995-02-25', N'Ebersberg', N'34220', N'Pärtzeltallee', N'3'),
 (N'Ria', N'Schottin', N'1946-03-08', N'Sankt Goarshausen', N'04154', N'Justina-Scholl-Straße', N'832'),
 (N'Giesela', N'Radisch', N'1975-04-18', N'Meppen', N'54906', N'Briemerweg', N'8'),
 (N'Gotthold', N'Boucsein', N'1988-11-29', N'Jölich', N'66151', N'Fiebigallee', N'1'),
 (N'Nelli', N'Ehlert', N'1980-05-14', N'Ludwigsburg', N'48982', N'Friederike-Jacobi Jäckel-Allee', N'3'),
 (N'Hassan', N'Klapp', N'1959-08-31', N'Fulda', N'89484', N'Lilija-Faust-Gasse', N'2'),
 (N'Florentine', N'Kraushaar', N'1934-09-26', N'Burglengenfeld', N'95211', N'Bohlandergasse', N'86'),
 (N'Dogan', N'Gude', N'1993-08-12', N'Dinslaken', N'52557', N'Pieperstraße', N'4/6'),
 (N'Balthasar', N'Heidrich', N'2004-06-30', N'Gerolzhofen', N'95718', N'Philomena-Dietz-Straße', N'2/2'),
 (N'Raphaela', N'Berger', N'1965-04-07', N'Cuxhaven', N'90181', N'Faustallee', N'370'),
 (N'Cläre', N'Weinhold', N'1983-02-28', N'Brandenburg', N'69176', N'Betti-Bauer-Straße', N'635'),
 (N'Gertraut', N'Johann', N'2006-11-01', N'Saarbröcken', N'59463', N'Paffrathstraße', N'7'),
 (N'Doris', N'Bohlander', N'1978-03-19', N'Gürlitz', N'39490', N'Konstanze-Noack-Allee', N'5'),
 (N'Magnus', N'Kreusel', N'2003-12-06', N'Hüxter', N'86630', N'Magrit-Rürricht-Weg', N'6/9'),
 (N'Ariane', N'Hartmann', N'1987-07-02', N'Perleberg', N'44222', N'Etzoldring', N'535'),
 (N'Liselotte', N'Buchholz', N'1989-12-14', N'Griesbach Rottal', N'63842', N'Häringweg', N'9'),
 (N'Sevim', N'Henschel', N'1952-09-11', N'Wanzleben', N'66583', N'Fritschplatz', N'56'),
 (N'Adelheid', N'Lindner', N'1956-01-25', N'Stendal', N'84204', N'Kreinstraße', N'0'),
 (N'Siegrun', N'Renner', N'1942-11-16', N'Freudenstadt', N'49676', N'Kira-Scholtz-Ring', N'3'),
 (N'Claudia', N'Sülzer', N'1985-09-29', N'Dessau', N'15107', N'Gudeplatz', N'19'),
 (N'Bruno', N'auch Schlauchin', N'2001-01-10', N'Hainichen', N'05755', N'Gütz-Küster-Straße', N'284'),
 (N'Lambert', N'Tintzmann', N'1982-03-29', N'Ebermannstadt', N'08901', N'Harloffgasse', N'67'),
 (N'Kirstin', N'Trüst', N'1998-04-23', N'Senftenberg', N'18098', N'Lüchelweg', N'1'),
 (N'Yasmin', N'Thies', N'1988-01-10', N'Bremervürde', N'53291', N'Dietzring', N'2'),
 (N'Mona', N'Hecker', N'1937-02-17', N'Hagenow', N'38393', N'Laila-Oestrovsky-Straße', N'522'),
 (N'Gerold', N'Niemeier', N'1999-03-08', N'Kleve', N'64877', N'Boucseinstraße', N'0/7'),
 (N'Gustav', N'Schmiedt', N'1987-12-20', N'Rothenburg ob der Tauber', N'30410', N'Peukertgasse', N'1/6'),
 (N'Ilias', N'Schwital', N'1953-05-15', N'Auerbach', N'71650', N'Hahnallee', N'6/1'),
 (N'Juliana', N'Scholtz', N'1973-09-02', N'Gerolzhofen', N'24151', N'Marten-Löbs-Straße', N'4/6'),
 (N'Insa', N'Scholl', N'1989-11-01', N'Eisleben', N'03573', N'Rohtstraße', N'5'),
 (N'Reinhardt', N'Gotthard', N'1936-06-11', N'Mallersdorf', N'20659', N'Ladeckplatz', N'2/3'),
 (N'Leszek', N'Eckbauer', N'1968-08-02', N'Dieburg', N'95013', N'Ismail-Mende-Straße', N'7/1'),
 (N'Freddy', N'Zobel', N'1999-07-20', N'Grevesmöhlen', N'55761', N'Radischstraße', N'6'),
 (N'Kirsten', N'Hoffmann', N'1987-12-01', N'Duderstadt', N'50071', N'Warmerplatz', N'8'),
 (N'Carlos', N'Reinhardt', N'1997-12-10', N'Lürrach', N'02295', N'Oestrovskyallee', N'0/0'),
 (N'Hartmut', N'Girschner', N'1936-04-10', N'Säckingen', N'25117', N'Boucseinstr.', N'9/5'),
 (N'Evangelia', N'Zahn', N'1958-07-01', N'Rastatt', N'16756', N'Bruderstr.', N'6/9'),
 (N'Freya', N'Frühlich', N'1949-04-04', N'Goslar', N'23201', N'Köhnertstraße', N'8/2'),
 (N'Valentin', N'Adolph', N'1970-02-12', N'Greiz', N'66549', N'Maya-Bolander-Gasse', N'6/2'),
 (N'Patrizia', N'Killer', N'1939-06-16', N'Eichstätt', N'12527', N'Denis-Schünland-Platz', N'3'),
 (N'Hans-Dietrich', N'Möhle', N'1969-12-29', N'Moers', N'61317', N'Detlev-Schenk-Allee', N'185'),
 (N'Miroslawa', N'Wagenknecht', N'1945-05-15', N'Cloppenburg', N'31970', N'Gabor-Zänker-Ring', N'41'),
 (N'Curt', N'Heuser', N'1968-07-23', N'Iserlohn', N'58427', N'Riehlstr.', N'4'),
 (N'Emil', N'Lüffler', N'1940-03-31', N'Dinslaken', N'19067', N'Jockelplatz', N'8'),
 (N'Herrmann', N'Stadelmann', N'1945-09-08', N'Vohenstrauß', N'99619', N'Giuseppina-Pechel-Straße', N'36'),
 (N'Erdal', N'Trubin', N'1943-05-18', N'Olpe', N'82402', N'Dorina-Lindau-Platz', N'3'),
 (N'Knud', N'Sager', N'1939-08-18', N'Diepholz', N'05377', N'Heintzeplatz', N'4'),
 (N'Ignatz', N'Kuhl', N'1941-03-21', N'Fössen', N'58107', N'Cordula-Trubin-Allee', N'135'),
 (N'Ilka', N'Finke', N'1967-12-21', N'Kyritz', N'93744', N'Gerd-Jäntsch-Ring', N'5/3'),
 (N'Antonie', N'Knappe', N'1976-07-13', N'Eisenberg', N'08890', N'Bayram-Kroker-Gasse', N'22'),
 (N'Danilo', N'Rümer', N'1944-06-06', N'Stollberg', N'62333', N'Carstengasse', N'04'),
 (N'Bernward', N'Tschentscher', N'1947-03-01', N'Stadtsteinach', N'81489', N'van der Dussenstr.', N'9'),
 (N'Andrea', N'Salz', N'1974-10-29', N'Schongau', N'45509', N'Trubingasse', N'2/5'),
 (N'Birgitta', N'Mende', N'1937-09-22', N'Auerbach', N'74603', N'Susan-Berger-Straße', N'712'),
 (N'Irena', N'Ritter', N'1997-11-22', N'Löneburg', N'74773', N'Kreszenz-Gehringer-Straße', N'310'),
 (N'Zdravko', N'Häring', N'1997-03-14', N'Rosenheim', N'71594', N'Grein Grothallee', N'0/9'),
 (N'Mandy', N'Briemer', N'1975-09-28', N'Bayreuth', N'17303', N'Bolzmannring', N'97'),
 (N'Betina', N'Hartmann', N'2005-11-14', N'Steinfurt', N'13061', N'Eberthgasse', N'2/0'),
 (N'Anatol', N'Wagenknecht', N'1962-07-18', N'Emmendingen', N'53777', N'Beierallee', N'143'),
 (N'Ingelore', N'Hartmann', N'1980-01-21', N'Uelzen', N'60830', N'Jöttnerring', N'2'),
 (N'Gertraud', N'Austermöhle', N'1935-08-19', N'Roding', N'05087', N'Ingetraut-Drubin-Gasse', N'0/5'),
 (N'Hans-Gönther', N'Tröb', N'1967-05-22', N'Kamenz', N'13047', N'Egbert-Gertz-Straße', N'08'),
 (N'Sonia', N'Rosemann', N'1967-01-18', N'Hersbruck', N'95317', N'Adelgunde-Kuhl-Weg', N'552'),
 (N'Hans Jörgen', N'Ring', N'1987-04-13', N'Kützting', N'27904', N'Franz-Josef-Pieper-Weg', N'9'),
 (N'Renata', N'Ditschlerin', N'1947-04-22', N'Roth', N'67960', N'Joseph-Hethur-Straße', N'205'),
 (N'Gertrude', N'Möhle', N'1992-02-09', N'Wunsiedel', N'68932', N'Dolores-Zorbach-Allee', N'708'),
 (N'Antonietta', N'Rümer', N'1986-12-16', N'Eichstätt', N'84022', N'Roskothstraße', N'0'),
 (N'Berit', N'Seidel', N'2005-06-21', N'Main-Hüchst', N'42808', N'Elena-Sager-Straße', N'258'),
 (N'Sergej', N'Kraushaar', N'1982-03-15', N'Aue', N'46622', N'Else-Zimmer-Ring', N'618'),
 (N'Iwona', N'Ring', N'1999-06-11', N'Hohenstein-Ernstthal', N'86423', N'Stavros-Reichmann-Ring', N'3/8'),
 (N'Mirco', N'Adler', N'1937-05-09', N'Sümmerda', N'71782', N'Ali-Trubin-Ring', N'0'),
 (N'Elzbieta', N'Gertz', N'1965-04-22', N'Beilngries', N'59795', N'Wilmsenplatz', N'506'),
 (N'Sylvio', N'Segebahn', N'1953-11-07', N'Aachen', N'27694', N'Antonios-Schleich-Platz', N'4/4'),
 (N'Kati', N'Patberg', N'1939-02-23', N'Flüha', N'96255', N'Maurice-Mielcarek-Straße', N'530'),
 (N'Andrzej', N'Karge', N'1959-10-09', N'Borna', N'06406', N'Zofia-Gieß-Gasse', N'419'),
 (N'Tatjana', N'Kallert', N'1939-03-27', N'Holzminden', N'89611', N'Olaf-Schmiedecke-Platz', N'991'),
 (N'Gerolf', N'Neuschäfer', N'1989-04-20', N'Zeulenroda', N'95586', N'Alois-Hofmann-Weg', N'8/2'),
 (N'Klothilde', N'Etzler', N'1960-09-15', N'Bad Langensalza', N'89471', N'Gorlitzallee', N'175'),
 (N'Hans-Uwe', N'Rudolph', N'1951-12-16', N'Rastatt', N'52850', N'Leif-Dietz-Straße', N'431'),
 (N'Marta', N'Hülzenbecher', N'1951-08-26', N'Worbis', N'49939', N'Hillerstr.', N'9'),
 (N'Friedhelm', N'Bauer', N'1935-05-15', N'Dresden', N'57516', N'Heide-Marie-Patberg-Platz', N'18'),
 (N'Raik', N'Köhnert', N'1990-11-27', N'Herford', N'52143', N'Seipplatz', N'646'),
 (N'Ramazan', N'Mosemann', N'1936-07-11', N'Deggendorf', N'59194', N'Marcella-Ladeck-Allee', N'405'),
 (N'Martin', N'Eimer', N'1959-07-27', N'Wolfach', N'43824', N'Sagerallee', N'04'),
 (N'Hans-Peter', N'Henck', N'1989-04-14', N'Bogen', N'09385', N'Nicolas-Boucsein-Gasse', N'9'),
 (N'Clarissa', N'Binner', N'1986-09-21', N'Biedenkopf', N'81523', N'Nohlmansstraße', N'141'),
 (N'Tadeusz', N'Riehl', N'1942-04-01', N'Cottbus', N'33815', N'Marie-Theres-Weinhold-Straße', N'19'),
 (N'Ann', N'Seip', N'1938-05-31', N'Stade', N'71657', N'Margrafstraße', N'6/2'),
 (N'Ernestine', N'Bohnbach', N'1976-03-06', N'Hansestadttralsund', N'41018', N'Diana-Ebert-Allee', N'0/9'),
 (N'Hans-J.', N'Sorgatz', N'1954-10-18', N'Delitzsch', N'63465', N'Hesergasse', N'250'),
 (N'Silva', N'Aumann', N'1975-12-27', N'Bruchsal', N'09744', N'Ercan-Etzler-Gasse', N'2/5'),
 (N'Svenja', N'Jungfer', N'1958-02-06', N'Forst', N'01049', N'Adolphplatz', N'72'),
 (N'Birte', N'Lüffler', N'1992-05-14', N'Kemnath', N'61124', N'Luigi-Kensy-Gasse', N'04'),
 (N'Christina', N'Schöler', N'1969-09-11', N'Rosenheim', N'16789', N'Karzstr.', N'54'),
 (N'Catherine', N'Johann', N'1984-02-28', N'Mallersdorf', N'32161', N'Sofia-Tschentscher-Gasse', N'30'),
 (N'Hans-Walter', N'Barth', N'1954-12-09', N'Neuruppin', N'41671', N'Tania-Bolnbach-Weg', N'58'),
 (N'Sina', N'Dobes', N'2003-06-21', N'Wertingen', N'07095', N'Filippo-Hüfig-Straße', N'3/7'),
 (N'Jenny', N'Hauffer', N'1943-10-21', N'Meiningen', N'45505', N'Karlheinz-Barth-Weg', N'29'),
 (N'Therese', N'Hiller', N'1966-07-31', N'Ansbach', N'91368', N'Klingelhüferstraße', N'3'),
 (N'Margrit', N'Hoffmann', N'1995-11-12', N'Rostock', N'44760', N'Ackermannstr.', N'680'),
 (N'Monica', N'Schöler', N'1947-02-05', N'Apolda', N'55619', N'Holtring', N'2'),
 (N'Petar', N'Beer', N'1937-02-05', N'Bad Kissingen', N'43869', N'Rudolphallee', N'772'),
 (N'Frieda', N'Scheuermann', N'1966-07-09', N'Grimmen', N'12924', N'Marcella-Stolze-Straße', N'251'),
 (N'Mia', N'Weiß', N'1991-03-07', N'Hönfeld', N'52098', N'Lidija-Ziegert-Gasse', N'182'),
 (N'Serpil', N'Gute', N'1973-08-05', N'Griesbach Rottal', N'84752', N'Fredi-Albers-Platz', N'2/9'),
 (N'Romy', N'Drubin', N'1935-09-26', N'Cottbus', N'67799', N'Ortmannstr.', N'6'),
 (N'Giuseppe', N'Keudel', N'1990-04-18', N'Recklinghausen', N'63340', N'Margitta-Becker-Ring', N'389'),
 (N'Zlatko', N'Warmer', N'1951-11-25', N'Tirschenreuth', N'50559', N'Ã„nne-Putz-Platz', N'33'),
 (N'Betty', N'Kruschwitz', N'1999-04-07', N'Malchin', N'52694', N'Grüttnerstraße', N'771'),
 (N'Harri', N'Beyer', N'1997-05-29', N'Hannoversch Mönden', N'81553', N'Rädelplatz', N'5'),
 (N'Dietlinde', N'Davids', N'1966-12-23', N'Neustrelitz', N'21556', N'Dussen vanallee', N'6'),
 (N'Julian', N'Franke', N'1959-03-31', N'Ebern', N'21800', N'Silvana-Biggen-Weg', N'5'),
 (N'Bela', N'Ruppert', N'1977-05-17', N'Niesky', N'21880', N'Harry-Weller-Platz', N'0'),
 (N'Siegmund', N'Lindner', N'2000-11-18', N'Jölich', N'12454', N'Gorlitzallee', N'7'),
 (N'Greta', N'Kobelt', N'2004-07-01', N'Aachen', N'66973', N'Sauerallee', N'835'),
 (N'Erdogan', N'Langern', N'2001-07-12', N'Freudenstadt', N'04359', N'Bekir-Mitschke-Weg', N'94'),
 (N'Gero', N'Binner', N'1940-08-04', N'Bautzen', N'83866', N'Jähnplatz', N'856'),
 (N'Swantje', N'Martin', N'1993-12-23', N'Senftenberg', N'49335', N'Josefa-Bruder-Platz', N'82'),
 (N'Mariele', N'Mohaupt', N'1968-04-16', N'Marktheidenfeld', N'58060', N'Ilja-Ullrich-Ring', N'1'),
 (N'Hans-Michael', N'Fischer', N'1989-01-27', N'Rastatt', N'76996', N'Harloffstraße', N'1'),
 (N'Carin', N'Hänel', N'1964-11-27', N'Helmstedt', N'90624', N'Boucseinplatz', N'58'),
 (N'Laszlo', N'Radisch', N'1938-05-30', N'Quedlinburg', N'96662', N'Anatol-Junitz-Straße', N'332'),
 (N'Nikolaos', N'Bolzmann', N'1941-07-22', N'Dören', N'15286', N'Buchholzgasse', N'650'),
 (N'Wally', N'Steinberg', N'2002-03-31', N'Delitzsch', N'63724', N'Margrit-Carsten-Allee', N'088'),
 (N'Hanno', N'Eberth', N'1957-03-20', N'Neustrelitz', N'23542', N'Loni-Geisler-Gasse', N'39'),
 (N'Miguel', N'Heydrich', N'1950-12-17', N'Altütting', N'23127', N'Sebastian-Paffrath-Allee', N'8/8'),
 (N'Charles', N'Jäkel', N'2004-10-25', N'Wiedenbröck', N'64323', N'Jockelstr.', N'436'),
 (N'Edelbert', N'Jessel', N'1951-07-11', N'Malchin', N'25727', N'Ullrichplatz', N'7/6'),
 (N'Urban', N'Mangold', N'1942-05-05', N'Fössen', N'67126', N'Dragan-Stahr-Weg', N'19'),
 (N'Hans-Friedrich', N'Gutknecht', N'1993-03-05', N'Main-Hüchst', N'88737', N'Helga-Fischer-Gasse', N'965'),
 (N'Leila', N'Kraushaar', N'1955-02-25', N'Eisenhöttenstadt', N'74777', N'Rolf-Dieter-Reuter-Gasse', N'37'),
 (N'Rosi', N'Segebahn', N'1991-03-04', N'Angermönde', N'48189', N'Speerstraße', N'48'),
 (N'Bayram', N'Mielcarek', N'1987-03-05', N'Dübeln', N'56219', N'Janus-Kensy-Platz', N'86'),
 (N'Irena', N'Jähn', N'1995-09-19', N'Auerbach', N'68985', N'Ziegertweg', N'522'),
 (N'Enno', N'Reinhardt', N'1957-10-23', N'Hildesheim', N'00457', N'Hendriksplatz', N'1/0'),
 (N'Ekaterina', N'Schinke', N'1958-07-02', N'Werdau', N'34158', N'Zänkerring', N'2'),
 (N'Martine', N'Lüwer', N'1978-12-30', N'Eberswalde', N'77282', N'Inna-Bärer-Ring', N'3/3'),
 (N'Tölay', N'Binner', N'1934-09-16', N'Worbis', N'46854', N'Heinplatz', N'6'),
 (N'Milka', N'Beyer', N'1978-06-20', N'Weißenfels', N'55336', N'Pauline-Dippel-Straße', N'9/6'),
 (N'Hans-Gönther', N'Lüffler', N'1955-07-12', N'Calw', N'29699', N'Georgia-Möller-Weg', N'281'),
 (N'Harriet', N'Bohlander', N'2001-07-05', N'Merseburg', N'38905', N'Catherine-Barth-Gasse', N'02'),
 (N'Ferdi', N'Killer', N'1983-01-06', N'Pegnitz', N'59245', N'Dussen vanstraße', N'067'),
 (N'Maria-Theresia', N'Kühler', N'1999-04-11', N'Wolfenböttel', N'29769', N'Wilmsring', N'2/4'),
 (N'Heinz-Willi', N'Zirme', N'1940-09-24', N'Staßfurt', N'11338', N'Junitzplatz', N'41'),
 (N'Silvana', N'Mohaupt', N'1990-10-17', N'Freital', N'41394', N'Dürrgasse', N'8'),
 (N'Klaus', N'Schwital', N'1937-11-24', N'Sternberg', N'47236', N'Hanne-Ehlert-Platz', N'1/0'),
 (N'Anastasios', N'Schleich', N'2004-01-15', N'Anklam', N'59017', N'Schollstraße', N'565'),
 (N'Mariusz', N'Gotthard', N'1993-10-22', N'Staßfurt', N'60158', N'Emmi-Lindner-Allee', N'449'),
 (N'Norbert', N'Lachmann', N'1962-11-02', N'Freudenstadt', N'76585', N'Bonbachring', N'160'),
 (N'Denis', N'Mende', N'1947-02-13', N'Bautzen', N'45196', N'Reinhardtweg', N'43'),
 (N'Uli', N'Keudel', N'1985-03-18', N'Neustadt am Röbenberge', N'58466', N'Dietrich-Mosemann-Straße', N'814'),
 (N'Theresa', N'Dussen van', N'1999-10-08', N'Hohenmülsen', N'16432', N'Sofia-Mangold-Platz', N'8/0'),
 (N'Horst-Dieter', N'Mende', N'1965-04-11', N'Lürrach', N'21991', N'Bachmannweg', N'53'),
 (N'Wolf-Dietrich', N'Huhn', N'1953-10-11', N'Hersbruck', N'51948', N'Udo-Wagner-Allee', N'7/9'),
 (N'Mechtild', N'Hermann', N'1977-08-20', N'Guben', N'50247', N'Berta-Rürricht-Platz', N'5/0'),
 (N'Reimer', N'Barkholz', N'1993-08-11', N'Osterode am Harz', N'61445', N'Gutering', N'304'),
 (N'Hendrik', N'Fiebig', N'2002-11-16', N'Greiz', N'86871', N'Sößebierallee', N'23'),
 (N'Thorben', N'Lüffler', N'1958-08-03', N'Hildesheim', N'74231', N'Mirko-Staude-Weg', N'2'),
 (N'Dorothee', N'Koch II', N'1962-07-16', N'Bamberg', N'01159', N'Renata-Rührdanz-Platz', N'829'),
 (N'Franz', N'Fiebig', N'1934-12-26', N'Neustadtner Waldnaab', N'89207', N'Vincenzo-Schuchhardt-Platz', N'277'),
 (N'Editha', N'Seidel', N'2004-11-26', N'Löbeck', N'65082', N'Ingelore-Hein-Platz', N'37'),
 (N'Gunter', N'Kramer', N'1942-06-01', N'Heiligenstadt', N'00365', N'Tröbstr.', N'0/8'),
 (N'Gino', N'Fürster', N'1955-05-19', N'Ebern', N'48873', N'Heinzallee', N'3'),
 (N'Jolanta', N'Flantz', N'1995-07-18', N'Burg', N'87041', N'Kurt-Ring-Platz', N'5'),
 (N'Sylke', N'Dippel', N'1935-11-17', N'Brilon', N'50571', N'Madlen-Heidrich-Platz', N'429'),
 (N'Sigmar', N'Adolph', N'2003-03-27', N'Suhl', N'29979', N'Kreinplatz', N'486'),
 (N'Sabine', N'Pärtzelt', N'1953-02-18', N'Belzig', N'05850', N'Hartmannring', N'4'),
 (N'Hans-Wilhelm', N'Tröb', N'1950-09-30', N'Soltau', N'42500', N'Löbsgasse', N'7/1'),
 (N'Cemal', N'Hecker', N'1975-09-15', N'Bad Freienwalde', N'45537', N'Ortwin-Trüst-Platz', N'816'),
 (N'Kata', N'Juncken', N'1994-01-26', N'Oberviechtach', N'99752', N'Rustweg', N'020'),
 (N'Klaus-Peter', N'Fiebig', N'1982-03-03', N'Aschaffenburg', N'43428', N'Holtstraße', N'0/4'),
 (N'Ben', N'Kruschwitz', N'1980-12-03', N'Flüha', N'46121', N'Hertha-Davids-Ring', N'56'),
 (N'Britta', N'Möller', N'1971-12-02', N'Bad Kreuznach', N'98997', N'Egbert-Pülitz-Platz', N'014'),
 (N'Rosa-Maria', N'Ebert', N'1948-01-10', N'Schwerin', N'64699', N'Nettestr.', N'47'),
 (N'Cäcilie', N'Rudolph', N'1980-12-14', N'Dören', N'32753', N'Justine-Dippel-Gasse', N'53'),
 (N'Karoline', N'Schacht', N'1950-10-09', N'Büblingen', N'65168', N'Hentschelgasse', N'766'),
 (N'Reinhilde', N'Becker', N'1958-09-17', N'Artern', N'89819', N'Strohgasse', N'7/3'),
 (N'Gerda', N'Warmer', N'1988-02-02', N'Ribnitz-Damgarten', N'39464', N'Annamaria-Stumpf-Gasse', N'9'),
 (N'Nikolaj', N'Fechner', N'1941-08-27', N'Husum', N'27532', N'Hendriksweg', N'877'),
 (N'Cetin', N'Gutknecht', N'1984-12-22', N'Stadtroda', N'77421', N'Dühnstr.', N'7'),
 (N'Stanislaw', N'Hauffer', N'1977-05-09', N'Kehl', N'06772', N'Eigenwilligweg', N'64'),
 (N'Hanife', N'Lüwer', N'1957-09-04', N'Haldensleben', N'87869', N'Recep-Becker-Allee', N'1/1'),
 (N'Beata', N'Seifert', N'1978-04-24', N'Demmin', N'80909', N'Gierschnerstraße', N'62'),
 (N'Marko', N'Zimmer', N'1970-08-12', N'Erfurt', N'66904', N'Janina-Bärer-Weg', N'63'),
 (N'Sepp', N'Hentschel', N'1977-03-26', N'Husum', N'73001', N'Mohamed-Ruppert-Gasse', N'6/8'),
 (N'Wieslaw', N'Gierschner', N'1971-03-21', N'Schwerin', N'78278', N'Buttestr.', N'3'),
 (N'Timo', N'Sontag', N'1951-05-15', N'Burglengenfeld', N'74375', N'Annelore-Ritter-Ring', N'002'),
 (N'Frederike', N'Speer', N'1964-01-22', N'Coburg', N'40306', N'Beckmannweg', N'1'),
 (N'Burkhard', N'Meister', N'1940-07-16', N'Osterburg', N'71427', N'Krokerring', N'28'),
 (N'Zeki', N'Vollbrecht', N'1975-03-26', N'Fulda', N'94607', N'Mariechen-Wähner-Weg', N'10'),
 (N'Konstanze', N'Seidel', N'1990-01-15', N'Forst', N'31568', N'Stumpfring', N'76'),
 (N'Carlo', N'Mohaupt', N'1938-03-08', N'Schmülln', N'54561', N'Stavros-Frühlich-Ring', N'193'),
 (N'Antonio', N'Hauffer', N'1939-02-01', N'Senftenberg', N'37181', N'Zimmerring', N'4/3'),
 (N'Karlheinz', N'Walter', N'1999-05-22', N'Hohenstein-Ernstthal', N'13922', N'Meike-Stey-Weg', N'30'),
 (N'Sylke', N'Oderwald', N'1957-09-21', N'Belzig', N'11797', N'Truppring', N'804'),
 (N'Manuela', N'Tschentscher', N'1980-01-31', N'Dübeln', N'52970', N'Thekla-Nohlmans-Platz', N'5'),
 (N'Robin', N'Gehringer', N'1998-12-03', N'Hüxter', N'86308', N'Roswita-Matthäi-Platz', N'8'),
 (N'Ehrhard', N'Bohlander', N'2000-09-08', N'Zerbst', N'81636', N'Paffrathring', N'079'),
 (N'Francesca', N'Stiffel', N'1965-10-16', N'Miltenberg', N'12307', N'Ferenc-Bien-Straße', N'751'),
 (N'Carola', N'Faust', N'2001-06-02', N'Oranienburg', N'58350', N'Gehringergasse', N'53'),
 (N'Sigrun', N'Bonbach', N'1992-09-27', N'Gönzburg', N'78201', N'Benderring', N'8/0'),
 (N'Joseph', N'Hartmann', N'1945-04-20', N'Feuchtwangen', N'06608', N'Sonia-Wirth-Straße', N'981'),
 (N'Rose-Marie', N'Harloff', N'2000-01-13', N'Amberg', N'59405', N'Putzring', N'6'),
 (N'Baptist', N'Budig', N'1948-10-09', N'Haldensleben', N'32174', N'Heckerstr.', N'0'),
 (N'Franziska', N'Steckel', N'1993-01-23', N'Tecklenburg', N'80249', N'Lorenz-Schenk-Gasse', N'6/9'),
 (N'Gilbert', N'Hande', N'1982-10-12', N'Bitterfeld', N'09401', N'Scheelstr.', N'3'),
 (N'Julius', N'Pruschke', N'1976-07-06', N'Hettstedt', N'25481', N'Klappgasse', N'179'),
 (N'Berend', N'Walter', N'1956-06-10', N'Stadtsteinach', N'62176', N'Roland-Scheel-Straße', N'4'),
 (N'Thekla', N'Becker', N'2002-10-28', N'Moers', N'60755', N'Ã„nne-Hesse-Gasse', N'29'),
 (N'Jochen', N'Scheel', N'1944-03-08', N'Hüxter', N'67707', N'Ruthild-Weihmann-Ring', N'5/9'),
 (N'Sylvana', N'Misicher', N'1977-01-11', N'Eisleben', N'96195', N'Alan-Hering-Weg', N'9'),
 (N'Almut', N'Oderwald', N'1945-04-12', N'Kelheim', N'08032', N'Mathilde-Bohnbach-Weg', N'773'),
 (N'Hagen', N'Fiebig', N'1959-03-09', N'Hagenow', N'61259', N'Annerose-Gumprich-Allee', N'7/8'),
 (N'Mareile', N'Junck', N'1993-02-01', N'Büblingen', N'21879', N'Bodo-Trüst-Straße', N'9'),
 (N'Sabina', N'Junk', N'1971-02-14', N'Bad Langensalza', N'86427', N'Yasmin-Heinrich-Gasse', N'3'),
 (N'Selma', N'Herrmann', N'1968-06-13', N'Dresden', N'56449', N'Michael-Kambs-Allee', N'494'),
 (N'Helena', N'Kramer', N'1993-03-13', N'Rockenhausen', N'68291', N'Rita-Schleich-Platz', N'5'),
 (N'Ladislaus', N'Steinberg', N'2006-05-26', N'Hannoversch Mönden', N'74049', N'Egon-Dehmel-Allee', N'9'),
 (N'Woldemar', N'Jäntsch', N'1980-03-10', N'Neustadtner Waldnaab', N'53305', N'Wähnerstraße', N'11'),
 (N'Almut', N'Langern', N'1948-08-23', N'Cottbus', N'94211', N'Kaspar-Mielcarek-Gasse', N'8'),
 (N'Hans-Rudolf', N'Hartung', N'1943-11-26', N'Kamenz', N'13162', N'Rohtstraße', N'0/0'),
 (N'Jeannette', N'Misicher', N'1954-05-22', N'Kamenz', N'99228', N'Hubertine-Flantz-Gasse', N'642'),
 (N'Cilli', N'Hofmann', N'2006-10-08', N'Geldern', N'44609', N'Oscar-Koch II-Ring', N'066'),
 (N'Urszula', N'van der Dussen', N'2000-10-19', N'Merseburg', N'33819', N'Dürrallee', N'960'),
 (N'Malte', N'Hartmann', N'1945-10-28', N'Marienberg', N'05129', N'Dusan-Wulf-Gasse', N'2/9'),
 (N'Robby', N'Fürster', N'1945-08-26', N'Feuchtwangen', N'28470', N'Anette-Kohl-Gasse', N'4'),
 (N'Emanuel', N'Weinhold', N'1981-12-03', N'Forst', N'68995', N'Ritterstr.', N'3/2'),
 (N'Laila', N'Kühler', N'1994-02-27', N'Rathenow', N'88753', N'Bolzmannring', N'318'),
 (N'Irmela', N'Müchlichen', N'1978-06-20', N'Miesbach', N'61939', N'Silvio-Scheel-Straße', N'72'),
 (N'Gitte', N'Karge', N'1983-03-27', N'Mayen', N'00438', N'Wulfweg', N'5/4'),
 (N'Emil', N'Siering', N'1989-06-07', N'Schleiz', N'11205', N'Briemerplatz', N'99'),
 (N'Suzanne', N'Gieß', N'1999-12-15', N'Kitzingen', N'45266', N'Marisa-Hellwig-Platz', N'721'),
 (N'Katy', N'Holzapfel', N'1988-01-04', N'Meiningen', N'37169', N'Sorgatzstraße', N'53'),
 (N'Sergio', N'Mielcarek', N'1960-09-20', N'Bischofswerda', N'39642', N'Ortmannstr.', N'7'),
 (N'Juliana', N'Säuberlich', N'1972-04-09', N'Sonneberg', N'68602', N'Chantal-Düring-Straße', N'1/9'),
 (N'Kristian', N'Lüffler', N'1947-09-30', N'Backnang', N'93847', N'Anne-Katrin-Gehringer-Allee', N'7'),
 (N'Hans-Wolfgang', N'Mies', N'2006-02-12', N'Oberviechtach', N'37665', N'Lüchelallee', N'9/7'),
 (N'Alwine', N'Rose', N'1934-10-20', N'Sondershausen', N'09355', N'Trubplatz', N'149'),
 (N'Boris', N'Kuhl', N'2005-11-27', N'Neubrandenburg', N'57637', N'Köhnertallee', N'8/4'),
 (N'Brunhilde', N'Ackermann', N'1939-03-13', N'Mettmann', N'31568', N'Pasquale-Riehl-Platz', N'9'),
 (N'Clemens', N'Conradi', N'1977-03-22', N'Meiningen', N'77003', N'Vollbrechtgasse', N'00'),
 (N'Birgit', N'Pechel', N'1955-07-17', N'Neustadtner Waldnaab', N'69280', N'Reinhardtgasse', N'0'),
 (N'Hans-H.', N'Eckbauer', N'1970-07-16', N'Gerolzhofen', N'52872', N'Winklerplatz', N'6'),
 (N'Nadja', N'Herrmann', N'2004-09-16', N'Regen', N'73876', N'Nadeschda-Junk-Ring', N'288'),
 (N'Gereon', N'Kaul', N'1952-07-03', N'Groß-Gerau', N'36531', N'Rebekka-Trapp-Gasse', N'865'),
 (N'Elfriede', N'Matthäi', N'1984-06-02', N'Merseburg', N'19471', N'Etzlerstraße', N'6'),
 (N'Romana', N'Hänel', N'1981-10-14', N'Schwandorf', N'50433', N'Julian-Caspar-Weg', N'8/2'),
 (N'Hans-Otto', N'Loos', N'1960-11-26', N'Wittenberg', N'74090', N'Hüfigring', N'59'),
 (N'Maja', N'Carsten', N'1961-07-03', N'Hohenmülsen', N'04117', N'Hakan-Krebs-Allee', N'3/7'),
 (N'Jaroslav', N'Seifert', N'1993-06-17', N'Paderborn', N'35650', N'Meisterring', N'47'),
 (N'Hans-Theo', N'Stey', N'1960-08-29', N'Greifswald', N'10556', N'Blochstr.', N'46'),
 (N'Diana', N'Fiebig', N'1961-10-22', N'Forchheim', N'26539', N'Mirjana-Ortmann-Weg', N'6'),
 (N'Liane', N'Rogge', N'1935-07-12', N'Eisenhöttenstadt', N'68871', N'Birgit-Wagenknecht-Gasse', N'1/0'),
 (N'Hans-Dietrich', N'Stolze', N'1944-03-28', N'Oberviechtach', N'69644', N'Jasmin-Zimmer-Gasse', N'266'),
 (N'Gabriella', N'Schweitzer', N'1954-05-15', N'Püßneck', N'61196', N'Gottfried-Scholtz-Ring', N'4'),
 (N'Adolfine', N'Gude', N'1970-03-03', N'Merseburg', N'12868', N'Grein Grothstr.', N'4/1'),
 (N'Nick', N'Walter', N'1954-08-23', N'Bad Liebenwerda', N'95585', N'Lena-Wähner-Allee', N'50'),
 (N'Ivanka', N'Weinhold', N'2007-03-01', N'Aurich', N'80067', N'Arndt-Ladeck-Weg', N'8/1'),
 (N'Danielle', N'Hethur', N'1950-02-25', N'Jena', N'26074', N'Pieperallee', N'912'),
 (N'Lissy', N'Hänel', N'1983-04-01', N'Torgau', N'25295', N'Wielochallee', N'009'),
 (N'Hubertus', N'Heydrich', N'1960-12-25', N'Haldensleben', N'46195', N'Kraushaarstraße', N'80'),
 (N'Erkan', N'Steinberg', N'1970-10-20', N'Monschau', N'28773', N'Adriana-Lachmann-Platz', N'4'),
 (N'Pius', N'Säuberlich', N'1972-01-14', N'Gräfenhainichen', N'68611', N'Benthinstr.', N'6'),
 (N'Dimitrios', N'Striebitz', N'1985-11-28', N'Worbis', N'91968', N'Gottfried-Mangold-Allee', N'8'),
 (N'Dierk', N'Kallert', N'1939-01-07', N'Meißen', N'96427', N'Reichmanngasse', N'8/5'),
 (N'Andrzej', N'Jöttner', N'1991-11-21', N'Starnberg', N'84773', N'Jakob-Hürle-Platz', N'950'),
 (N'Janna', N'Hertrampf', N'2001-09-04', N'Backnang', N'40757', N'Sülzerring', N'5/8'),
 (N'Marian', N'Neureuther', N'1947-06-12', N'Hohenstein-Ernstthal', N'37700', N'Hamannstraße', N'0'),
 (N'Luigi', N'Lüffler', N'1937-12-02', N'Hersbruck', N'59451', N'Wolf-Dietrich-Lehmann-Straße', N'13'),
 (N'Cosimo', N'Zirme', N'1996-03-21', N'Heinsberg', N'81390', N'Birgitta-Franke-Gasse', N'0'),
 (N'Nina', N'Thies', N'1943-03-03', N'Schlöchtern', N'68643', N'Karzstraße', N'369'),
 (N'Silvana', N'Eberth', N'1946-12-20', N'Witzenhausen', N'45837', N'Andrzej-Cichorius-Platz', N'4');
GO
Insert Into dbo.Einkauf(PersonenID,Einkaufsdatum) Values
(71,2024-10-14),(465,2024-10-14),(442,2024-10-14),(34,2024-10-14),(107,2024-10-14),(270,2024-10-14),(240,2024-10-14),(180,2024-10-14),(212,2024-10-14),(444,2024-10-14),(63,2024-10-14),(197,2024-10-14),(39,2024-10-14),(394,2024-10-14),(35,2024-10-14),(385,2024-10-14),(368,2024-10-14),(474,2024-10-14),(389,2024-10-14),(478,2024-10-14),(452,2024-10-14),(61,2024-10-14),(144,2024-10-14),(203,2024-10-14),(61,2024-10-14),(235,2024-10-14),(317,2024-10-14),(169,2024-10-14),(408,2024-10-14),(84,2024-10-14),(173,2024-10-14),(127,2024-10-14),(411,2024-10-14),(288,2024-10-14),(175,2024-10-14),(346,2024-10-14),(212,2024-10-14),(271,2024-10-14),(349,2024-10-14),(178,2024-10-14),(180,2024-10-14),(79,2024-10-14),(182,2024-10-14),(340,2024-10-14),(418,2024-10-14),(270,2024-10-14),(330,2024-10-14),(218,2024-10-14),(441,2024-10-14),(422,2024-10-14),(405,2024-10-14),(283,2024-10-14),(325,2024-10-14),(126,2024-10-14),(228,2024-10-14),(310,2024-10-14),(177,2024-10-14),(311,2024-10-14),(288,2024-10-14),(461,2024-10-14),(377,2024-10-14),(399,2024-10-14),(499,2024-10-14),(405,2024-10-14),(119,2024-10-14),(93,2024-10-14),(116,2024-10-14),(285,2024-10-14),(180,2024-10-14),(330,2024-10-14),(303,2024-10-14),(226,2024-10-14),(385,2024-10-14),(49,2024-10-14),(3,2024-10-14),(219,2024-10-14),(278,2024-10-14),(350,2024-10-14),(264,2024-10-14),(293,2024-10-14),(225,2024-10-14),(77,2024-10-14),(417,2024-10-14),(105,2024-10-14),(289,2024-10-14),(245,2024-10-14),(93,2024-10-14),(470,2024-10-14),(499,2024-10-14),(185,2024-10-14),(84,2024-10-14),(256,2024-10-14),(373,2024-10-14),(129,2024-10-14),(297,2024-10-14),(398,2024-10-14),(130,2024-10-14),(330,2024-10-14),(498,2024-10-14),(100,2024-10-14),(264,2024-10-14),(409,2024-10-14),(134,2024-10-14),(494,2024-10-14),(490,2024-10-14),(458,2024-10-14),(438,2024-10-14),(428,2024-10-14),(247,2024-10-14),(239,2024-10-14),(477,2024-10-14),(71,2024-10-14),(205,2024-10-14),(166,2024-10-14),(459,2024-10-14),(246,2024-10-14),(453,2024-10-14),(296,2024-10-14),(172,2024-10-14),(251,2024-10-14),(410,2024-10-14),(418,2024-10-14),(417,2024-10-14),(253,2024-10-14),(13,2024-10-14),(125,2024-10-14),(84,2024-10-14),(154,2024-10-14),(217,2024-10-14),(35,2024-10-14),(491,2024-10-14),(17,2024-10-14),(117,2024-10-14),(103,2024-10-14),(10,2024-10-14),(235,2024-10-14),(231,2024-10-14),(187,2024-10-14),(206,2024-10-14),(301,2024-10-14),(369,2024-10-14),(184,2024-10-15),(160,2024-10-15),(230,2024-10-15),(64,2024-10-15),(245,2024-10-15),(402,2024-10-15),(113,2024-10-15),(256,2024-10-15),(84,2024-10-15),(234,2024-10-15),(197,2024-10-15),(237,2024-10-15),(348,2024-10-15),(246,2024-10-15),(79,2024-10-15),(300,2024-10-15),(338,2024-10-15),(405,2024-10-15),(424,2024-10-15),(429,2024-10-15),(158,2024-10-15),(382,2024-10-15),(261,2024-10-15),(304,2024-10-15),(260,2024-10-15),(71,2024-10-15),(132,2024-10-15),(323,2024-10-15),(390,2024-10-15),(131,2024-10-15),(62,2024-10-15),(439,2024-10-15),(170,2024-10-15),(436,2024-10-15),(245,2024-10-15),(179,2024-10-15),(474,2024-10-15),(343,2024-10-15),(359,2024-10-15),(483,2024-10-15),(28,2024-10-15),(120,2024-10-15),(494,2024-10-15),(259,2024-10-15),(362,2024-10-15),(369,2024-10-15),(270,2024-10-15),(5,2024-10-15),(154,2024-10-15),(486,2024-10-15),(14,2024-10-15),(334,2024-10-15),(371,2024-10-15),(278,2024-10-15),(350,2024-10-15),(482,2024-10-15),(442,2024-10-15),(298,2024-10-15),(339,2024-10-15),(399,2024-10-15),(478,2024-10-15),(488,2024-10-15),(236,2024-10-15),(230,2024-10-15),(425,2024-10-15),(201,2024-10-15),(290,2024-10-15),(307,2024-10-15),(330,2024-10-15),(279,2024-10-15),(160,2024-10-15),(453,2024-10-15),(10,2024-10-15),(374,2024-10-15),(373,2024-10-15),(469,2024-10-15),(78,2024-10-15),(329,2024-10-15),(345,2024-10-15),(366,2024-10-15),(16,2024-10-15),(86,2024-10-15),(350,2024-10-15),(29,2024-10-15),(261,2024-10-15),(236,2024-10-15),(20,2024-10-15),(104,2024-10-15),(178,2024-10-15),(337,2024-10-15),(366,2024-10-15),(268,2024-10-15),(216,2024-10-15),(484,2024-10-15),(281,2024-10-15),(292,2024-10-15),(439,2024-10-15),(72,2024-10-15),(65,2024-10-15),(100,2024-10-15),(203,2024-10-15),(372,2024-10-15),(477,2024-10-15),(316,2024-10-15),(5,2024-10-15),(264,2024-10-15),(15,2024-10-15),(473,2024-10-15),(304,2024-10-15),(115,2024-10-15),(162,2024-10-15),(357,2024-10-15),(248,2024-10-15),(277,2024-10-15),(182,2024-10-15),(58,2024-10-15),(403,2024-10-15),(191,2024-10-15),(64,2024-10-15),(95,2024-10-15),(261,2024-10-15),(195,2024-10-15),(108,2024-10-15),(306,2024-10-15),(29,2024-10-15),(186,2024-10-15),(245,2024-10-15),(222,2024-10-15),(143,2024-10-15),(103,2024-10-15),(393,2024-10-15),(272,2024-10-15),(426,2024-10-15),(102,2024-10-15),(409,2024-10-15),(337,2024-10-15),(61,2024-10-15),(327,2024-10-15),(432,2024-10-15),(329,2024-10-15),(87,2024-10-15),(84,2024-10-15),(395,2024-10-16),(301,2024-10-16),(110,2024-10-16),(209,2024-10-16),(133,2024-10-16),(270,2024-10-16),(488,2024-10-16),(394,2024-10-16),(498,2024-10-16),(480,2024-10-16),(93,2024-10-16),(359,2024-10-16),(141,2024-10-16),(81,2024-10-16),(157,2024-10-16),(125,2024-10-16),(225,2024-10-16),(294,2024-10-16),(487,2024-10-16),(262,2024-10-16),(414,2024-10-16),(182,2024-10-16),(272,2024-10-16),(18,2024-10-16),(346,2024-10-16),(253,2024-10-16),(85,2024-10-16),(346,2024-10-16),(78,2024-10-16),(254,2024-10-16),(463,2024-10-16),(365,2024-10-16),(234,2024-10-16),(462,2024-10-16),(483,2024-10-16),(193,2024-10-16),(349,2024-10-16),(453,2024-10-16),(155,2024-10-16),(211,2024-10-16),(397,2024-10-16),(34,2024-10-16),(443,2024-10-16),(261,2024-10-16),(43,2024-10-16),(364,2024-10-16),(329,2024-10-16),(367,2024-10-16),(360,2024-10-16),(452,2024-10-16),(78,2024-10-16),(46,2024-10-16),(11,2024-10-16),(338,2024-10-16),(175,2024-10-16),(493,2024-10-16),(48,2024-10-16),(320,2024-10-16),(420,2024-10-16),(411,2024-10-16),(212,2024-10-16),(117,2024-10-16),(397,2024-10-16),(194,2024-10-16),(187,2024-10-16),(308,2024-10-16),(490,2024-10-16),(284,2024-10-16),(168,2024-10-16),(249,2024-10-16),(281,2024-10-16),(157,2024-10-16),(148,2024-10-16),(45,2024-10-16),(475,2024-10-16),(249,2024-10-16),(313,2024-10-16),(193,2024-10-16),(274,2024-10-16),(230,2024-10-16),(392,2024-10-16),(215,2024-10-16),(81,2024-10-16),(192,2024-10-16),(367,2024-10-16),(46,2024-10-16),(306,2024-10-16),(88,2024-10-16),(312,2024-10-16),(341,2024-10-16),(323,2024-10-16),(54,2024-10-16),(423,2024-10-16),(459,2024-10-16),(262,2024-10-16),(102,2024-10-16),(255,2024-10-16),(296,2024-10-16),(342,2024-10-16),(438,2024-10-16),(100,2024-10-16),(55,2024-10-16),(441,2024-10-16),(427,2024-10-16),(430,2024-10-16),(200,2024-10-16),(456,2024-10-16),(216,2024-10-16),(497,2024-10-16),(142,2024-10-16),(109,2024-10-16),(150,2024-10-16),(423,2024-10-16),(311,2024-10-16),(180,2024-10-16),(135,2024-10-16),(486,2024-10-16),(30,2024-10-16),(132,2024-10-16),(488,2024-10-16),(218,2024-10-16),(127,2024-10-16),(240,2024-10-16),(387,2024-10-16),(484,2024-10-16),(345,2024-10-16),(129,2024-10-16),(361,2024-10-16),(449,2024-10-16),(333,2024-10-16),(484,2024-10-16),(455,2024-10-16),(449,2024-10-16),(412,2024-10-16),(40,2024-10-16),(61,2024-10-16),(404,2024-10-16),(405,2024-10-16),(488,2024-10-16),(326,2024-10-16),(356,2024-10-16),(467,2024-10-16),(63,2024-10-17),(307,2024-10-17),(399,2024-10-17),(327,2024-10-17),(494,2024-10-17),(206,2024-10-17),(363,2024-10-17),(242,2024-10-17),(252,2024-10-17),(186,2024-10-17),(348,2024-10-17),(287,2024-10-17),(495,2024-10-17),(21,2024-10-17),(363,2024-10-17),(272,2024-10-17),(29,2024-10-17),(328,2024-10-17),(293,2024-10-17),(284,2024-10-17),(165,2024-10-17),(87,2024-10-17),(155,2024-10-17),(32,2024-10-17),(460,2024-10-17),(223,2024-10-17),(6,2024-10-17),(396,2024-10-17),(333,2024-10-17),(28,2024-10-17),(66,2024-10-17),(306,2024-10-17),(303,2024-10-17),(382,2024-10-17),(303,2024-10-17),(363,2024-10-17),(464,2024-10-17),(18,2024-10-17),(383,2024-10-17),(433,2024-10-17),(122,2024-10-17),(55,2024-10-17),(490,2024-10-17),(395,2024-10-17),(280,2024-10-17),(326,2024-10-17),(466,2024-10-17),(117,2024-10-17),(332,2024-10-17),(114,2024-10-17),(220,2024-10-17),(340,2024-10-17),(94,2024-10-17),(390,2024-10-17),(151,2024-10-17),(158,2024-10-17),(377,2024-10-17),(35,2024-10-17),(370,2024-10-17),(386,2024-10-17),(160,2024-10-17),(36,2024-10-17),(111,2024-10-17),(317,2024-10-17),(323,2024-10-17),(497,2024-10-17),(7,2024-10-17),(296,2024-10-17),(494,2024-10-17),(306,2024-10-17),(452,2024-10-17),(467,2024-10-17),(491,2024-10-17),(79,2024-10-17),(165,2024-10-17),(58,2024-10-17),(171,2024-10-17),(59,2024-10-17),(113,2024-10-17),(125,2024-10-17),(145,2024-10-17),(50,2024-10-17),(439,2024-10-17),(110,2024-10-17),(51,2024-10-17),(117,2024-10-17),(349,2024-10-17),(293,2024-10-17),(302,2024-10-17),(224,2024-10-17),(319,2024-10-17),(13,2024-10-17),(161,2024-10-17),(238,2024-10-17),(179,2024-10-17),(446,2024-10-17),(417,2024-10-17),(241,2024-10-17),(313,2024-10-17),(32,2024-10-17),(94,2024-10-17),(190,2024-10-17),(165,2024-10-17),(180,2024-10-17),(82,2024-10-17),(21,2024-10-17),(137,2024-10-17),(236,2024-10-17),(181,2024-10-17),(276,2024-10-17),(306,2024-10-17),(472,2024-10-17),(77,2024-10-17),(15,2024-10-17),(90,2024-10-17),(443,2024-10-17),(393,2024-10-17),(167,2024-10-17),(119,2024-10-17),(452,2024-10-17),(181,2024-10-17),(423,2024-10-17),(144,2024-10-17),(236,2024-10-17),(359,2024-10-17),(277,2024-10-17),(11,2024-10-17),(492,2024-10-17),(389,2024-10-17),(202,2024-10-17),(189,2024-10-17),(145,2024-10-17),(402,2024-10-17),(43,2024-10-17),(206,2024-10-17),(85,2024-10-17),(258,2024-10-17),(431,2024-10-17),(494,2024-10-17),(398,2024-10-17),(300,2024-10-17),(40,2024-10-17),(284,2024-10-18),(205,2024-10-18),(364,2024-10-18),(243,2024-10-18),(272,2024-10-18),(382,2024-10-18),(410,2024-10-18),(130,2024-10-18),(475,2024-10-18),(97,2024-10-18),(268,2024-10-18),(262,2024-10-18),(103,2024-10-18),(28,2024-10-18),(354,2024-10-18),(178,2024-10-18),(5,2024-10-18),(9,2024-10-18),(205,2024-10-18),(386,2024-10-18),(12,2024-10-18),(100,2024-10-18),(93,2024-10-18),(288,2024-10-18),(127,2024-10-18),(195,2024-10-18),(246,2024-10-18),(18,2024-10-18),(207,2024-10-18),(109,2024-10-18),(426,2024-10-18),(493,2024-10-18),(198,2024-10-18),(201,2024-10-18),(372,2024-10-18),(471,2024-10-18),(495,2024-10-18),(147,2024-10-18),(37,2024-10-18),(330,2024-10-18),(236,2024-10-18),(348,2024-10-18),(213,2024-10-18),(165,2024-10-18),(392,2024-10-18),(349,2024-10-18),(379,2024-10-18),(271,2024-10-18),(24,2024-10-18),(390,2024-10-18),(27,2024-10-18),(57,2024-10-18),(399,2024-10-18),(336,2024-10-18),(355,2024-10-18),(63,2024-10-18),(205,2024-10-18),(61,2024-10-18),(444,2024-10-18),(144,2024-10-18),(125,2024-10-18),(347,2024-10-18),(482,2024-10-18),(146,2024-10-18),(116,2024-10-18),(236,2024-10-18),(283,2024-10-18),(387,2024-10-18),(187,2024-10-18),(348,2024-10-18),(314,2024-10-18),(486,2024-10-18),(133,2024-10-18),(412,2024-10-18),(98,2024-10-18),(173,2024-10-18),(121,2024-10-18),(243,2024-10-18),(381,2024-10-18),(43,2024-10-18),(276,2024-10-18),(82,2024-10-18),(193,2024-10-18),(23,2024-10-18),(22,2024-10-18),(486,2024-10-18),(304,2024-10-18),(97,2024-10-18),(115,2024-10-18),(496,2024-10-18),(175,2024-10-18),(318,2024-10-18),(341,2024-10-18),(115,2024-10-18),(174,2024-10-18),(38,2024-10-18),(317,2024-10-18),(478,2024-10-18),(183,2024-10-18),(226,2024-10-18),(232,2024-10-18),(428,2024-10-18),(163,2024-10-18),(118,2024-10-18),(190,2024-10-18),(338,2024-10-18),(165,2024-10-18),(451,2024-10-18),(132,2024-10-18),(86,2024-10-18),(145,2024-10-18),(397,2024-10-18),(15,2024-10-18),(213,2024-10-18),(104,2024-10-18),(90,2024-10-18),(366,2024-10-18),(418,2024-10-18),(386,2024-10-18),(395,2024-10-18),(172,2024-10-18),(467,2024-10-18),(245,2024-10-18),(58,2024-10-18),(107,2024-10-18),(179,2024-10-18),(241,2024-10-18),(338,2024-10-18),(196,2024-10-18),(154,2024-10-18),(255,2024-10-18),(56,2024-10-18),(446,2024-10-18),(489,2024-10-18),(286,2024-10-18),(489,2024-10-18),(197,2024-10-18),(126,2024-10-18),(273,2024-10-18),(286,2024-10-18),(74,2024-10-18),(155,2024-10-18),(69,2024-10-19),(40,2024-10-19),(445,2024-10-19),(111,2024-10-19),(66,2024-10-19),(330,2024-10-19),(8,2024-10-19),(14,2024-10-19),(248,2024-10-19),(339,2024-10-19),(261,2024-10-19),(243,2024-10-19),(157,2024-10-19),(169,2024-10-19),(323,2024-10-19),(247,2024-10-19),(33,2024-10-19),(40,2024-10-19),(410,2024-10-19),(298,2024-10-19),(364,2024-10-19),(35,2024-10-19),(115,2024-10-19),(18,2024-10-19),(79,2024-10-19),(239,2024-10-19),(306,2024-10-19),(312,2024-10-19),(41,2024-10-19),(24,2024-10-19),(196,2024-10-19),(11,2024-10-19),(231,2024-10-19),(367,2024-10-19),(147,2024-10-19),(454,2024-10-19),(373,2024-10-19),(455,2024-10-19),(30,2024-10-19),(494,2024-10-19),(461,2024-10-19),(479,2024-10-19),(463,2024-10-19),(35,2024-10-19),(295,2024-10-19),(477,2024-10-19),(134,2024-10-19),(261,2024-10-19),(74,2024-10-19),(123,2024-10-19),(408,2024-10-19),(246,2024-10-19),(227,2024-10-19),(363,2024-10-19),(394,2024-10-19),(313,2024-10-19),(29,2024-10-19),(130,2024-10-19),(458,2024-10-19),(351,2024-10-19),(440,2024-10-19),(361,2024-10-19),(295,2024-10-19),(423,2024-10-19),(187,2024-10-19),(364,2024-10-19),(323,2024-10-19),(372,2024-10-19),(455,2024-10-19),(144,2024-10-19),(438,2024-10-19),(203,2024-10-19),(203,2024-10-19),(20,2024-10-19),(246,2024-10-19),(427,2024-10-19),(236,2024-10-19),(464,2024-10-19),(487,2024-10-19),(427,2024-10-19),(240,2024-10-19),(208,2024-10-19),(74,2024-10-19),(275,2024-10-19),(201,2024-10-19),(227,2024-10-19),(477,2024-10-19),(70,2024-10-19),(348,2024-10-19),(83,2024-10-19),(412,2024-10-19),(307,2024-10-19),(99,2024-10-19),(118,2024-10-19),(131,2024-10-19),(324,2024-10-19),(125,2024-10-19),(91,2024-10-19),(33,2024-10-19),(465,2024-10-19),(21,2024-10-19),(226,2024-10-19),(356,2024-10-19),(449,2024-10-19),(363,2024-10-19),(10,2024-10-19),(138,2024-10-19),(126,2024-10-19),(160,2024-10-19),(397,2024-10-19),(134,2024-10-19),(18,2024-10-19),(138,2024-10-19),(327,2024-10-19),(413,2024-10-19),(41,2024-10-19),(386,2024-10-19),(174,2024-10-19),(435,2024-10-19),(426,2024-10-19),(498,2024-10-19),(164,2024-10-19),(489,2024-10-19),(485,2024-10-19),(424,2024-10-19),(479,2024-10-19),(139,2024-10-19),(283,2024-10-19),(188,2024-10-19),(55,2024-10-19),(493,2024-10-19),(461,2024-10-19),(395,2024-10-19),(191,2024-10-19),(57,2024-10-19),(177,2024-10-19),(170,2024-10-19),(5,2024-10-19),(347,2024-10-19),(148,2024-10-19),(452,2024-10-19),(464,2024-10-19),(363,2024-10-20),(37,2024-10-20),(444,2024-10-20),(294,2024-10-20),(147,2024-10-20),(121,2024-10-20),(343,2024-10-20),(475,2024-10-20),(280,2024-10-20),(422,2024-10-20),(117,2024-10-20),(76,2024-10-20),(180,2024-10-20),(347,2024-10-20),(485,2024-10-20),(345,2024-10-20),(232,2024-10-20),(311,2024-10-20),(179,2024-10-20),(236,2024-10-20),(296,2024-10-20),(159,2024-10-20),(365,2024-10-20),(487,2024-10-20),(477,2024-10-20),(38,2024-10-20),(141,2024-10-20),(419,2024-10-20),(419,2024-10-20),(2,2024-10-20),(283,2024-10-20),(184,2024-10-20),(148,2024-10-20),(28,2024-10-20),(485,2024-10-20),(325,2024-10-20),(387,2024-10-20),(64,2024-10-20),(297,2024-10-20),(177,2024-10-20),(134,2024-10-20),(256,2024-10-20),(221,2024-10-20),(100,2024-10-20),(318,2024-10-20),(350,2024-10-20),(332,2024-10-20),(205,2024-10-20),(290,2024-10-20),(472,2024-10-20),(367,2024-10-20),(358,2024-10-20),(300,2024-10-20),(190,2024-10-20),(148,2024-10-20),(26,2024-10-20),(415,2024-10-20),(85,2024-10-20),(149,2024-10-20),(472,2024-10-20),(348,2024-10-20),(395,2024-10-20),(302,2024-10-20),(93,2024-10-20),(58,2024-10-20),(218,2024-10-20),(383,2024-10-20),(197,2024-10-20),(472,2024-10-20),(153,2024-10-20),(370,2024-10-20),(271,2024-10-20),(278,2024-10-20),(92,2024-10-20),(276,2024-10-20),(287,2024-10-20),(85,2024-10-20),(438,2024-10-20),(452,2024-10-20),(172,2024-10-20),(106,2024-10-20),(225,2024-10-20),(38,2024-10-20),(20,2024-10-20),(401,2024-10-20),(462,2024-10-20),(244,2024-10-20),(302,2024-10-20),(344,2024-10-20),(373,2024-10-20),(357,2024-10-20),(197,2024-10-20),(205,2024-10-20),(405,2024-10-20),(12,2024-10-20),(162,2024-10-20),(103,2024-10-20),(153,2024-10-20),(111,2024-10-20),(383,2024-10-20),(75,2024-10-20),(179,2024-10-20),(312,2024-10-20),(406,2024-10-20),(52,2024-10-20),(444,2024-10-20),(329,2024-10-20),(486,2024-10-20),(343,2024-10-20),(142,2024-10-20),(480,2024-10-20),(457,2024-10-20),(10,2024-10-20),(55,2024-10-20),(81,2024-10-20),(295,2024-10-20),(104,2024-10-20),(73,2024-10-20),(488,2024-10-20),(28,2024-10-20),(413,2024-10-20),(319,2024-10-20),(1,2024-10-20),(215,2024-10-20),(204,2024-10-20),(377,2024-10-20),(57,2024-10-20),(347,2024-10-20),(460,2024-10-20),(124,2024-10-20),(427,2024-10-20),(478,2024-10-20),(227,2024-10-20),(482,2024-10-20),(336,2024-10-20),(167,2024-10-20),(327,2024-10-20),(89,2024-10-20),(97,2024-10-20),(66,2024-10-20),(256,2024-10-20),(391,2024-10-20),(27,2024-10-20),(193,2024-10-20),(122,2024-10-20),(7,2024-10-20),(375,2024-10-20),(94,2024-10-20);
GO
Insert Into dbo.Produkte(Produkt) Values
('Testprodukt'),
('Produkt 1'),
('Produkt 2'),
('Produkt 3'),
('Produkt 4'),
('Produkt 5'),
('Produkt 6'),
('Produkt 7'),
('Produkt 8'),
('Produkt 9'),
('Produkt 10');

GO
Insert into dbo.Einkauf_Produkte (EinkaufID,ProduktID) Values
(1,3),(1,4),(1,7),(1,11),(2,2),(2,4),(2,8),(4,1),(4,4),(5,3),(5,7),(5,11),(6,1),(6,2),(6,8),(7,4),(7,7),(8,2),(9,7),(10,4),(10,8),(11,2),(11,3),(11,7),(11,11),(12,2),(12,3),(12,5),(12,7),(13,1),(13,2),(13,6),(13,10),(14,7),(14,11),(15,1),(15,5),(16,3),(16,7),(16,8),(16,9),(17,2),(17,10),(18,2),(18,8),(18,9),(19,6),(20,1),(20,8),(20,9),(20,11),(21,2),(21,9),(22,4),(22,6),(22,7),(22,9),(23,1),(23,8),(23,10),(24,2),(24,9),(25,1),(25,10),(26,4),(26,10),(27,4),(27,11),(28,6),(28,10),(28,11),(29,5),(29,9),(29,10),(29,11),(30,1),(30,3),(31,7),(31,11),(32,1),(32,4),(32,7),(32,9),(33,4),(33,7),(34,7),(34,8),(34,9),(34,10),(35,1),(35,4),(35,5),(36,2),(36,8),(36,9),(36,11),(37,4),(38,2),(38,3),(38,5),(38,8),(38,9),(39,7),(39,10),(39,11),(40,6),(40,9),(41,2),(41,3),(41,5),(41,7),(42,1),(42,5),(42,7),(43,6),(43,10),(44,2),(44,7),(45,7),(45,9),(46,5),(46,8),(47,7),(48,3),(48,10),(49,2),(49,4),(49,10),(50,6),(50,8),(50,9),(50,10),(50,11),(51,3),(52,2),(52,9),(53,3),(53,6),(53,9),(54,6),(54,9),(54,10),(54,11),(55,9),(56,1),(56,2),(56,7),(57,1),(58,1),(58,5),(58,9),(59,4),(59,6),(59,7),(59,10),(60,5),(60,7),(60,10),(61,2),(61,6),(61,9),(62,4),(62,6),(62,11),(63,1),(63,6),(63,7),(63,9),(65,5),(65,10),(66,1),(66,3),(66,4),(66,5),(66,10),(67,3),(67,4),(67,7),(67,9),(67,11),(68,1),(68,4),(68,9),(69,10),(70,2),(70,3),(70,5),(70,6),(70,8),(70,10),(71,3),(71,5),(71,8),(72,1),(72,8),(73,7),(73,11),(74,2),(74,3),(74,8),(75,8),(76,4),(76,8),(77,5),(77,11),(78,1),(78,9),(79,7),(79,11),(80,1),(80,2),(80,6),(80,7),(80,9),(81,2),(81,7),(82,1),(82,2),(82,6),(83,9),(84,1),(84,3),(85,5),(85,9),(86,9),(86,10),(86,11),(87,1),(87,6),(87,7),(87,8),(87,11),(88,1),(88,2),(88,3),(88,4),(88,7),(88,10),(89,6),(89,8),(89,9),(90,1),(90,3),(90,7),(91,3),(91,5),(91,8),(91,9),(92,8),(93,3),(93,9),(94,2),(95,1),(95,9),(96,1),(96,3),(96,7),(97,2),(97,10),(98,1),(98,8),(99,8),(100,1),(100,10),(101,10),(102,2),(102,3),(103,1),(103,8),(103,9),(103,10),(104,1),(104,2),(104,5),(105,1),(105,7),(107,4),(107,5),(108,7),(108,8),(109,1),(109,3),(109,8),(109,11),(110,5),(110,8),(111,7),(111,10),(112,2),(112,3),(112,4),(112,8),(112,9),(113,6),(113,9),(113,10),(114,1),(114,2),(114,5),(114,10),(114,11),(115,2),(115,6),(115,7),(116,2),(117,2),(117,10),(118,2),(118,3),(118,7),(119,3),(119,5),(119,6),(119,9),(119,11),(120,7),(120,10),(121,7),(122,3),(122,7),(123,7),(123,10),(124,4),(124,7),(124,9),(125,2),(125,3),(125,9),(126,2),(129,7),(130,8),(130,10),(131,1),(131,3),(131,6),(131,8),(132,5),(132,9),(132,10),(133,2),(133,5),(133,8),(133,9),(134,7),(134,8),(134,9),(135,3),(135,4),(135,8),(135,11),(136,2),(136,9),(137,2),(137,4),(137,10),(137,11),(138,7),(139,2),(139,8),(139,10),(140,2),(141,3),(141,7),(141,8),(142,7),(143,3),(144,1),(144,9),(145,10),(147,1),(148,1),(148,2),(148,9),(148,10),(149,6),(149,8),(149,10),(150,2),(150,5),(150,7),(150,8),(151,5),(151,11),(152,1),(152,2),(152,3),(152,11),(153,7),(154,5),(154,9),(154,10),(155,7),(155,8),(156,7),(156,9),(156,10),(156,11),(157,3),(158,2),(158,3),(158,7),(158,9),(159,1),(159,2),(159,7),(159,8),(160,1),(160,2),(161,8),(161,9),(162,4),(162,6),(162,9),(163,1),(163,6),(163,10),(164,1),(164,5),(165,3),(165,5),(165,7),(165,9),(165,11),(166,4),(166,10),(167,3),(167,4),(167,8),(167,10),(168,3),(168,5),(168,7),(168,8),(168,9),(169,1),(169,2),(170,2),(170,10),(171,2),(171,5),(172,1),(172,2),(172,3),(172,7),(172,10),(173,2),(173,10),(174,11),(175,4),(175,5),(175,8),(175,9),(175,11),(176,6),(177,5),(177,10),(178,3),(179,1),(179,2),(179,3),(179,6),(179,7),(179,8),(179,9),(180,9),(180,10),(181,9),(181,10),(181,11),(182,4),(182,5),(182,10),(182,11),(183,2),(183,6),(183,9),(183,10),(184,7),(184,10),(185,7),(185,10),(186,1),(186,4),(186,8),(187,1),(187,4),(187,6),(187,7),(188,1),(188,4),(188,6),(188,9),(188,11),(189,5),(189,10),(190,3),(190,11),(191,8),(191,9),(191,10),(192,2),(193,1),(194,6),(194,9),(195,3),(195,5),(195,8),(195,10),(196,7),(197,6),(197,9),(197,10),(198,2),(198,5),(198,6),(199,7),(199,10),(200,2),(200,10),(201,8),(202,8),(203,3),(203,5),(203,10),(204,5),(204,9),(205,2),(206,6),(206,7),(207,1),(208,3),(208,6),(208,11),(209,4),(209,7),(209,8),(209,9),(209,10),(210,11),(211,9),(212,4),(212,5),(212,9),(212,10),(213,3),(213,4),(213,7),(213,10),(214,1),(214,3),(214,5),(214,8),(215,7),(215,8),(215,9),(216,2),(216,6),(216,7),(217,2),(217,7),(217,8),(217,9),(218,2),(218,9),(221,1),(221,4),(221,6),(222,1),(222,5),(222,11),(223,3),(223,8),(223,11),(224,7),(224,9),(224,10),(225,10),(226,1),(226,9),(228,4),(228,7),(229,2),(229,6),(229,8),(230,1),(230,3),(230,4),(231,8),(232,4),(232,7),(233,1),(233,2),(235,10),(236,2),(236,3),(236,8),(237,1),(237,5),(238,9),(239,2),(239,9),(240,1),(240,4),(240,8),(240,9),(240,10),(241,8),(242,1),(242,9),(243,2),(243,4),(244,1),(244,10),(245,4),(245,7),(245,11),(246,5),(246,7),(246,9),(247,6),(247,9),(247,11),(248,3),(248,7),(249,1),(249,2),(249,5),(249,8),(249,9),(250,1),(250,3),(250,4),(250,5),(250,7),(250,11),(251,7),(251,9),(251,10),(252,1),(252,2),(252,3),(252,8),(253,3),(254,4),(254,10),(254,11),(255,1),(255,4),(255,7),(255,8),(255,9),(257,1),(258,2),(258,4),(258,5),(258,10),(259,5),(259,7),(259,9),(260,2),(260,4),(260,8),(260,9),(261,3),(261,5),(261,9),(262,4),(262,6),(262,9),(263,2),(263,3),(263,5),(263,9),(263,11),(264,1),(264,7),(264,9),(264,10),(265,1),(265,2),(265,5),(266,7),(267,7),(267,10),(268,4),(268,8),(269,1),(269,6),(269,7),(270,3),(270,10),(271,2),(271,9),(271,10),(272,4),(272,7),(272,9),(273,9),(274,2),(274,9),(274,10),(275,8),(275,9),(275,11),(276,3),(276,10),(277,3),(277,9),(278,4),(278,5),(278,8),(278,11),(279,1),(279,8),(279,10),(280,1),(280,2),(280,4),(280,6),(281,8),(282,1),(282,3),(282,7),(282,8),(283,3),(283,5),(283,10),(284,2),(284,4),(285,2),(285,3),(285,10),(286,2),(286,3),(286,10),(287,1),(287,2),(287,3),(287,6),(287,7),(288,2),(288,3),(288,4),(288,9),(288,10),(289,1),(289,2),(289,5),(289,11),(290,1),(290,5),(290,9),(291,7),(292,2),(292,9),(293,4),(293,6),(293,7),(293,10),(293,11),(294,3),(294,9),(295,9),(295,10),(296,3),(296,7),(297,4),(297,8),(297,9),(297,10),(299,6),(299,7),(299,9),(300,1),(300,3),(300,5),(300,8),(300,10),(301,1),(301,10),(302,3),(302,9),(303,5),(303,9),(304,2),(304,4),(304,9),(305,1),(305,2),(305,3),(305,7),(305,8),(306,11),(307,6),(307,7),(307,9),(308,7),(308,10),(309,6),(309,9),(310,2),(310,6),(310,10),(311,9),(312,7),(312,9),(313,10),(314,2),(314,3),(314,6),(315,1),(315,7),(315,8),(315,9),(315,10),(315,11),(316,3),(316,6),(316,11),(317,4),(317,9),(317,10),(318,1),(318,3),(318,4),(318,5),(318,8),(319,3),(319,8),(320,7),(321,2),(321,4),(322,1),(322,9),(323,10),(323,11),(324,5),(324,10),(325,1),(325,2),(325,5),(325,6),(325,10),(325,11),(326,10),(327,9),(328,5),(329,4),(329,7),(329,9),(330,6),(330,8),(330,9),(330,11),(331,3),(331,4),(331,8),(331,11),(332,11),(333,8),(333,11),(334,3),(334,8),(335,1),(335,8),(336,2),(337,2),(337,8),(339,3),(339,8),(339,11),(340,2),(340,3),(340,4),(341,3),(342,11),(343,7),(343,10),(344,9),(345,4),(346,1),(346,6),(347,3),(347,7),(348,2),(348,5),(348,7),(348,8),(348,10),(350,5),(350,6),(351,3),(351,5),(351,7),(352,1),(352,2),(353,2),(353,10),(354,4),(354,5),(354,7),(354,9),(354,10),(355,6),(356,3),(356,9),(356,10),(357,2),(357,9),(358,6),(359,3),(359,10),(359,11),(360,2),(360,10),(360,11),(361,3),(361,4),(361,5),(361,10),(362,1),(362,3),(362,5),(362,7),(362,8),(362,9),(362,10),(363,2),(363,3),(363,7),(363,9),(363,10),(364,1),(364,6),(365,5),(365,6),(365,7),(366,2),(366,5),(366,9),(367,4),(367,5),(367,8),(367,10),(367,11),(368,3),(368,4),(369,1),(369,2),(369,9),(369,10),(370,8),(371,8),(371,9); 
GO
Insert into dbo.Einkauf_Produkte (EinkaufID,ProduktID) Values
(372,2),(372,5),(372,10),(372,11),(373,1),(374,2),(375,3),(376,11),(377,7),(377,9),(377,10),(377,11),(378,2),(378,7),(378,10),(379,1),(379,2),(379,7),(379,8),(379,9),(380,3),(380,5),(380,7),(380,10),(380,11),(381,7),(381,9),(382,11),(383,1),(383,7),(383,9),(384,5),(384,9),(385,1),(385,4),(385,5),(386,1),(386,2),(386,4),(386,7),(386,9),(387,1),(388,1),(388,2),(388,5),(388,9),(388,10),(389,8),(391,5),(391,10),(392,9),(393,3),(393,4),(393,9),(393,11),(394,7),(394,8),(394,9),(394,10),(394,11),(395,2),(395,11),(396,5),(396,7),(397,2),(397,7),(397,10),(398,1),(398,2),(398,3),(398,5),(398,9),(400,2),(400,6),(400,10),(401,7),(401,8),(401,10),(401,11),(402,4),(402,9),(403,1),(403,2),(403,7),(403,8),(403,11),(404,1),(404,3),(404,9),(405,10),(406,1),(406,7),(407,3),(407,10),(408,3),(408,9),(408,11),(409,1),(409,2),(409,7),(410,4),(410,5),(411,8),(411,10),(411,11),(412,1),(412,2),(412,9),(412,11),(413,4),(413,7),(413,10),(413,11),(414,9),(415,10),(416,3),(417,2),(418,9),(420,8),(420,11),(421,2),(421,8),(421,10),(422,3),(422,9),(424,3),(426,1),(426,2),(426,3),(426,5),(426,9),(427,2),(427,10),(428,2),(428,3),(428,9),(428,11),(429,8),(429,10),(430,1),(430,2),(430,3),(430,4),(430,10),(431,1),(431,4),(431,6),(431,11),(432,1),(432,2),(432,4),(432,7),(432,10),(433,1),(433,3),(433,8),(433,9),(434,6),(434,9),(435,9),(435,10),(435,11),(436,4),(436,9),(437,7),(437,9),(438,2),(438,3),(439,4),(439,9),(440,1),(440,2),(440,7),(440,10),(441,1),(442,3),(442,11),(443,1),(443,2),(443,3),(444,1),(444,4),(444,10),(445,2),(445,4),(445,6),(446,1),(446,2),(446,3),(446,4),(446,8),(447,9),(447,11),(448,5),(449,9),(449,10),(450,3),(450,8),(451,8),(451,10),(452,7),(452,10),(452,11),(453,1),(453,2),(453,8),(453,9),(453,10),(454,1),(454,2),(454,6),(454,9),(455,1),(455,8),(455,11),(456,3),(456,5),(456,6),(456,7),(456,8),(456,10),(456,11),(457,1),(457,2),(457,7),(457,9),(458,1),(458,4),(458,9),(459,7),(459,9),(459,10),(460,3),(460,10),(460,11),(461,2),(461,3),(461,9),(462,2),(462,3),(462,4),(463,6),(463,9),(463,10),(463,11),(464,6),(465,2),(465,3),(465,6),(465,11),(466,1),(466,2),(467,3),(467,10),(468,2),(468,9),(468,11),(469,2),(470,3),(470,5),(471,3),(471,4),(471,8),(471,10),(472,5),(472,7),(472,9),(472,10),(473,2),(473,5),(473,9),(474,8),(474,11),(475,7),(476,4),(476,5),(476,6),(477,1),(477,10),(478,1),(478,7),(478,9),(479,8),(480,2),(480,3),(481,1),(481,4),(481,5),(481,7),(482,9),(483,2),(483,7),(483,9),(483,11),(484,1),(484,2),(484,3),(485,1),(485,3),(485,5),(485,8),(486,8),(487,1),(487,2),(487,3),(487,4),(487,9),(488,1),(488,2),(488,10),(489,4),(489,9),(489,10),(490,1),(490,2),(490,4),(490,5),(490,8),(490,9),(490,10),(491,2),(491,3),(491,6),(491,7),(491,9),(491,11),(492,2),(492,7),(492,10),(493,7),(493,8),(493,10),(494,2),(494,4),(494,5),(495,1),(495,9),(496,5),(496,7),(496,8),(496,9),(496,11),(497,3),(497,7),(497,9),(498,2),(499,9),(499,10),(500,9),(501,1),(501,4),(501,7),(501,9),(502,3),(502,7),(502,10),(503,3),(503,6),(504,9),(505,2),(505,9),(505,10),(506,2),(506,3),(506,6),(506,7),(507,7),(507,9),(508,3),(508,9),(508,10),(508,11),(509,2),(509,8),(509,9),(510,5),(510,9),(510,11),(511,1),(511,4),(511,5),(511,11),(512,2),(512,4),(512,8),(512,9),(512,10),(513,2),(513,7),(513,10),(514,6),(514,10),(514,11),(515,1),(515,4),(515,7),(516,2),(516,4),(516,8),(517,2),(517,4),(517,10),(518,5),(518,7),(519,10),(520,1),(521,5),(521,7),(521,11),(522,1),(522,5),(522,8),(522,10),(523,1),(523,4),(523,8),(523,9),(524,7),(524,8),(524,9),(524,11),(525,1),(525,2),(525,7),(525,8),(526,3),(526,8),(526,9),(526,10),(527,5),(527,7),(527,9),(527,10),(527,11),(528,6),(528,10),(529,2),(530,7),(530,9),(531,4),(531,9),(532,2),(532,7),(532,10),(532,11),(533,9),(533,11),(534,4),(534,9),(535,8),(535,11),(536,1),(536,2),(536,9),(536,10),(537,2),(537,6),(537,7),(537,8),(538,1),(538,6),(538,10),(539,2),(539,11),(540,2),(541,1),(541,2),(541,9),(542,2),(542,3),(542,6),(543,4),(543,5),(543,11),(545,2),(545,7),(546,3),(546,7),(546,8),(547,3),(547,10),(548,1),(548,7),(548,8),(548,9),(548,10),(549,2),(549,7),(550,9),(551,1),(551,7),(551,8),(551,9),(551,11),(552,1),(552,4),(552,6),(553,9),(553,11),(554,2),(554,8),(555,3),(555,7),(555,10),(556,2),(556,5),(557,1),(557,3),(557,9),(558,1),(558,8),(558,11),(559,2),(559,7),(560,5),(561,1),(561,3),(561,11),(562,2),(562,3),(562,5),(562,9),(562,10),(563,2),(563,7),(563,11),(564,3),(565,7),(565,9),(565,11),(566,1),(566,2),(566,9),(566,10),(567,1),(567,2),(567,5),(567,7),(568,7),(568,10),(569,2),(569,9),(570,3),(570,9),(570,10),(571,1),(571,3),(571,6),(572,6),(572,7),(572,10),(573,5),(573,9),(574,3),(574,10),(575,10),(575,11),(576,3),(576,5),(577,1),(577,5),(578,8),(578,9),(580,1),(580,5),(581,3),(581,6),(581,9),(582,2),(582,4),(582,7),(583,2),(584,7),(585,1),(585,3),(585,8),(586,1),(586,2),(586,4),(586,7),(587,3),(587,5),(587,8),(588,4),(588,9),(589,4),(589,8),(589,9),(589,10),(590,1),(590,3),(590,10),(591,2),(592,1),(592,5),(592,7),(593,7),(594,3),(594,5),(594,8),(596,1),(596,2),(596,4),(596,8),(597,1),(597,11),(598,2),(598,3),(598,10),(598,11),(599,1),(599,2),(599,6),(599,8),(600,2),(600,5),(600,7),(600,11),(601,1),(601,5),(601,7),(601,10),(602,6),(602,9),(603,2),(603,4),(603,8),(603,9),(604,2),(604,4),(605,2),(605,8),(606,2),(607,2),(607,11),(609,4),(610,2),(610,3),(610,6),(610,7),(610,10),(611,7),(611,8),(611,10),(611,11),(612,4),(612,8),(612,9),(612,10),(612,11),(613,6),(613,7),(613,9),(614,9),(615,3),(615,7),(616,2),(616,3),(616,4),(616,6),(616,9),(616,10),(617,1),(617,4),(617,10),(617,11),(618,1),(618,2),(618,4),(619,7),(619,8),(619,10),(620,2),(620,3),(620,4),(620,8),(620,9),(621,3),(621,9),(621,10),(622,8),(623,5),(624,3),(624,4),(624,11),(625,1),(625,3),(625,8),(626,4),(626,11),(627,3),(627,8),(627,10),(628,2),(628,10),(628,11),(629,9),(630,8),(630,9),(630,10),(631,4),(631,8),(631,10),(632,7),(633,9),(634,1),(635,3),(635,10),(636,9),(637,7),(637,11),(638,2),(638,5),(639,2),(640,1),(640,2),(641,1),(641,2),(641,5),(641,11),(642,1),(642,5),(643,9),(645,2),(645,4),(645,11),(646,1),(646,8),(646,9),(646,11),(647,2),(647,3),(648,3),(648,4),(648,7),(649,10),(650,1),(650,2),(650,3),(650,4),(650,7),(650,9),(650,10),(652,3),(652,7),(652,8),(653,2),(653,8),(654,5),(654,8),(655,6),(656,1),(656,2),(656,5),(656,8),(656,10),(657,2),(657,10),(657,11),(658,7),(658,8),(659,2),(659,3),(659,10),(660,2),(660,4),(660,7),(660,8),(660,9),(660,11),(661,5),(661,11),(662,1),(662,8),(663,10),(664,7),(664,9),(665,3),(665,11),(666,2),(666,9),(668,2),(668,6),(668,9),(669,3),(669,9),(670,1),(670,5),(670,10),(671,3),(672,1),(672,10),(673,9),(674,2),(674,4),(674,5),(674,6),(674,11),(675,3),(676,2),(676,8),(677,9),(677,10),(678,2),(678,4),(678,5),(678,8),(678,9),(679,2),(679,7),(679,10),(680,5),(680,10),(681,2),(681,5),(682,2),(682,3),(682,4),(682,6),(682,7),(682,8),(682,9),(682,10),(683,10),(684,8),(684,11),(686,3),(686,9),(686,10),(687,1),(687,2),(687,7),(688,2),(688,7),(688,11),(689,3),(690,10),(691,5),(691,6),(692,2),(692,3),(692,6),(692,10),(693,7),(694,9),(694,10),(695,1),(695,2),(695,3),(695,5),(696,10),(698,2),(698,7),(698,8),(698,9),(699,9),(701,5),(701,7),(701,9),(702,5),(702,6),(702,11),(703,2); 
GO
Insert into dbo.Einkauf_Produkte (EinkaufID,ProduktID) Values
(703,3),(703,10),(703,11),(704,1),(704,4),(704,6),(705,1),(705,2),(705,6),(705,7),(705,9),(706,5),(707,2),(707,5),(707,9),(708,2),(708,5),(708,7),(709,9),(709,10),(709,11),(711,1),(711,9),(711,10),(712,2),(712,4),(712,5),(712,9),(712,11),(714,3),(714,4),(714,7),(714,8),(715,11),(717,5),(717,11),(718,2),(718,9),(718,10),(719,2),(719,3),(720,3),(720,4),(720,7),(720,11),(721,3),(721,7),(721,11),(722,1),(722,2),(722,3),(722,9),(722,10),(723,4),(723,9),(724,2),(724,5),(724,10),(725,9),(726,2),(726,4),(727,2),(727,8),(727,11),(728,2),(728,8),(729,7),(732,3),(732,6),(732,7),(732,9),(733,3),(734,4),(734,7),(735,3),(735,6),(735,7),(736,3),(736,5),(736,10),(737,9),(738,2),(738,8),(739,4),(739,7),(739,10),(740,1),(740,10),(741,8),(741,9),(742,1),(742,5),(742,7),(742,9),(743,1),(743,7),(743,10),(743,11),(744,3),(744,7),(744,8),(745,1),(745,5),(745,10),(746,6),(746,8),(746,9),(747,2),(747,8),(748,1),(748,2),(748,4),(748,7),(748,10),(749,2),(750,2),(750,3),(750,7),(751,2),(751,3),(751,4),(751,10),(751,11),(752,3),(752,4),(753,1),(753,5),(753,7),(754,1),(754,3),(754,10),(755,2),(755,10),(755,11),(756,4),(756,8),(756,9),(757,1),(757,10),(758,2),(758,3),(758,7),(758,10),(759,3),(759,6),(759,9),(759,11),(761,2),(762,10),(763,3),(763,5),(763,7),(763,10),(764,4),(764,5),(764,9),(765,8),(766,5),(766,7),(766,11),(767,9),(768,2),(768,10),(769,6),(770,2),(770,8),(770,9),(770,10),(771,8),(772,9),(773,2),(773,5),(773,8),(773,10),(774,1),(774,8),(775,2),(775,3),(775,8),(775,10),(775,11),(776,1),(776,9),(776,11),(777,9),(777,11),(778,2),(778,3),(778,10),(779,2),(779,3),(779,10),(780,1),(781,7),(781,10),(782,3),(782,4),(783,3),(783,10),(784,1),(784,2),(785,9),(786,5),(786,9),(788,2),(788,6),(789,10),(791,4),(791,6),(791,7),(791,8),(792,3),(792,11),(793,9),(793,10),(793,11),(794,9),(794,11),(795,1),(795,2),(795,7),(795,9),(796,2),(796,3),(796,9),(796,10),(797,5),(797,7),(798,10),(799,4),(799,5),(799,7),(800,1),(800,2),(800,6),(801,3),(801,7),(801,8),(801,9),(802,8),(803,3),(803,5),(803,10),(804,2),(804,9),(804,10),(805,2),(805,4),(805,6),(805,8),(805,9),(805,11),(806,4),(806,9),(807,8),(807,9),(808,4),(808,8),(808,10),(809,9),(809,10),(811,3),(811,11),(812,2),(812,6),(812,7),(814,7),(815,7),(815,8),(815,9),(816,2),(817,9),(818,5),(818,11),(819,3),(819,4),(819,7),(819,8),(820,2),(820,7),(820,9),(821,4),(822,2),(822,3),(823,3),(824,3),(824,6),(824,8),(825,8),(825,10),(826,3),(826,10),(827,1),(827,4),(827,9),(828,1),(828,4),(828,9),(829,7),(829,8),(830,9),(831,5),(831,10),(832,6),(832,8),(832,10),(833,1),(833,7),(833,9),(833,10),(834,1),(834,3),(834,5),(835,1),(835,3),(835,10),(836,2),(836,9),(837,3),(837,8),(837,10),(838,7),(839,2),(839,8),(839,10),(840,3),(840,10),(841,2),(841,10),(842,3),(842,9),(843,3),(844,2),(844,7),(845,3),(845,9),(846,7),(846,8),(847,3),(847,8),(847,9),(848,1),(848,2),(848,8),(848,10),(850,1),(850,2),(850,4),(850,9),(851,2),(851,8),(852,3),(852,8),(852,9),(852,10),(853,2),(854,4),(854,7),(854,11),(855,8),(855,9),(856,4),(856,7),(856,8),(856,10),(857,10),(858,2),(858,3),(858,7),(858,9),(858,10),(859,1),(859,9),(860,2),(860,4),(860,5),(860,11),(861,1),(861,2),(861,4),(861,9),(861,11),(862,2),(862,10),(863,2),(863,11),(864,5),(864,7),(865,1),(865,5),(865,7),(866,2),(866,3),(866,6),(867,4),(867,7),(867,9),(867,10),(868,3),(869,2),(869,9),(869,10),(870,5),(870,7),(870,9),(870,10),(871,1),(871,8),(871,10),(872,7),(873,2),(873,4),(873,6),(874,3),(874,8),(874,10),(875,2),(875,5),(875,7),(875,9),(875,10),(876,9),(877,10),(878,1),(878,3),(878,7),(879,2),(880,11),(881,7),(881,9),(882,5),(883,4),(883,7),(883,11),(885,5),(885,10),(886,3),(886,8),(887,3),(888,2),(888,3),(888,5),(888,8),(888,9),(889,3),(889,4),(889,7),(889,8),(890,1),(890,2),(890,3),(890,10),(891,4),(891,10),(892,1),(892,2),(892,3),(892,4),(892,10),(894,4),(894,7),(894,8),(895,11),(896,9),(897,2),(897,5),(897,10),(898,2),(898,9),(899,1),(899,3),(899,5),(899,9),(900,4),(901,1),(901,7),(901,10),(902,2),(903,2),(903,8),(903,9),(903,10),(904,2),(904,3),(905,2),(905,4),(905,8),(905,11),(906,2),(906,3),(907,3),(907,11),(908,2),(908,5),(908,8),(908,10),(909,6),(910,1),(910,2),(910,3),(910,10),(911,1),(911,3),(911,4),(911,7),(911,9),(912,4),(912,9),(912,10),(913,1),(913,2),(913,6),(914,4),(914,5),(914,7),(915,8),(916,10),(916,11),(918,3),(918,10),(918,11),(919,1),(919,2),(919,5),(919,7),(919,10),(920,5),(920,10),(921,10),(922,2),(922,5),(922,9),(923,3),(923,9),(924,3),(924,5),(924,8),(924,10),(925,2),(925,3),(925,7),(925,9),(926,1),(926,4),(926,6),(927,3),(927,5),(928,1),(928,2),(928,10),(929,7),(930,9),(931,1),(931,4),(931,6),(931,10),(932,3),(932,5),(932,6),(932,10),(933,3),(933,4),(933,10),(934,1),(934,4),(935,3),(935,5),(936,9),(937,1),(937,2),(938,2),(938,5),(939,6),(939,9),(939,11),(940,3),(940,4),(940,7),(940,9),(940,10),(941,2),(941,3),(941,4),(941,6),(941,9),(941,11),(942,9),(943,5),(943,8),(943,9),(944,11),(945,8),(945,9),(946,2),(946,3),(946,9),(947,4),(947,10),(948,1),(948,5),(948,7),(950,10),(951,3),(951,7),(951,10),(952,11),(953,1),(953,5),(953,9),(954,1),(954,4),(954,6),(954,9),(954,10),(954,11),(955,3),(955,5),(956,7),(957,1),(957,5),(957,7),(957,8),(957,10),(957,11),(958,3),(958,10),(959,2),(959,9),(960,9),(961,2),(961,3),(961,4),(961,7),(961,8),(961,10),(962,9),(962,10),(963,2),(963,4),(963,5),(963,7),(963,9),(964,1),(964,4),(964,9),(964,11),(965,3),(966,4),(966,5),(966,7),(966,8),(967,2),(967,5),(967,7),(967,8),(967,9),(968,4),(968,7),(968,10),(968,11),(969,1),(969,3),(969,5),(969,10),(970,6),(971,11),(972,4),(972,5),(972,8),(972,11),(973,5),(973,9),(974,2),(974,3),(974,5),(974,7),(974,9),(975,2),(976,3),(976,5),(976,6),(977,4),(977,5),(977,10),(978,3),(979,1),(979,4),(979,5),(979,9),(979,11),(980,2),(980,4),(980,11),(981,4),(981,8),(982,1),(982,3),(982,10),(982,11),(983,8),(984,7),(984,9),(985,5),(985,10),(986,1),(986,6),(986,9),(988,3),(988,9),(988,10),(988,11),(989,3),(989,6),(989,8),(990,3),(990,4),(990,8),(990,10),(991,7),(991,9),(991,10),(992,2),(992,7),(992,8),(993,6),(993,8),(993,9),(994,10),(995,6),(995,7),(995,10),(996,3),(996,8),(996,10),(996,11),(997,2),(997,8),(997,9),(997,10),(997,11),(998,1),(998,5),(998,7),(998,11),(999,2),(999,8),(999,9),(999,10); 
GO