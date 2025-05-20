
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

USE Marketbasket;
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'Produkte' AND type = 'U')
BEGIN
CREATE TABLE [dbo].[Produkte](
	[ID] [int] NOT NULL,
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
	[ID] [int] NOT NULL,
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
	[ID] [int] NOT NULL,
	[PersonenID] [int] NULL,
	[Einkaufsdatum] [datetime] NULL,
 CONSTRAINT [PK_Einkauf] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Einkauf]  WITH CHECK ADD  CONSTRAINT [FK_Einkauf_Personen] FOREIGN KEY([PersonenID])
REFERENCES [dbo].[Personen] ([ID])
GO

ALTER TABLE [dbo].[Einkauf] CHECK CONSTRAINT [FK_Einkauf_Personen]
GO
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'Einkauf_Produkte' AND type = 'U')
BEGIN
CREATE TABLE [dbo].[Einkauf_Produkte](
	[ID] [int] NOT NULL,
	[EinkaufID] [int] NULL,
	[ProduktID] [int] NULL,
 CONSTRAINT [PK_Einkauf_Produkte] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
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