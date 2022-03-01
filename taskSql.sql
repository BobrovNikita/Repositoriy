----Create tables and references
--CREATE TABLE Banks 
--(
--	[IdBank] INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
--	[Name] NVARCHAR(30) NOT NULL
--);

--CREATE TABLE Town
--(
--	[IdTown] INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
--	[Name] NVARCHAR(30) NOT NULL
--);

--CREATE TABLE SocialStatus
--(
--	[IdStatus] INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
--	[Name] NVARCHAR(30) NOT NULL
--);

--CREATE TABLE Branch
--(
--	[IdBranch] INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
--	[Adress] NVARCHAR(20) NOT NULL,
--	[IdTown] INT NOT NULL,
--	[IdBank] INT NOT NULL,

--	CONSTRAINT branch_Town_FK
--		FOREIGN KEY (IdTown) REFERENCES Town (IdTown),
--	CONSTRAINT branch_Bank_FK
--		FOREIGN KEY (IdBank) REFERENCES Banks (IdBank),
--);

--CREATE TABLE Client
--(
--	[IdClient] INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
--	[Surname] NVARCHAR(15) NOT NULL,
--	[Name] NVARCHAR(15) NOT NULL,
--	[LastName] NVARCHAR(15) NOT NULL,
--	[PassportData] NVARCHAR(15) NOT NULL,
--);

--CREATE TABLE Account
--(
--	[IdAccount] INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
--	[Balance] INT NOT NULL,
--	[IdStatus] INT NOT NULL,
--	[IdBranch] INT NOT NULL,
--	[IdClient] INT NOT NULL,

--	CONSTRAINT accounts_SocialStatus_FK
--		FOREIGN KEY (IdStatus) REFERENCES SocialStatus (IdStatus),
--	CONSTRAINT accounts_Branch_FK
--		FOREIGN KEY (IdBranch) REFERENCES Branch (IdBranch),
--	CONSTRAINT accounts_Client_FK
--		FOREIGN KEY (IdClient) REFERENCES Client (IdClient)
--);

--CREATE TABLE ClientCard
--(
--	[IdClientCard] INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
--	[Balance] INT NOT NULL,
--	[IdAccount] INT NOT NULL,

--	CONSTRAINT clientCards_Client_FK
--	FOREIGN KEY (IdAccount) REFERENCES Account(IdAccount)
--);



----Filing tables
--CREATE PROC AddDate
--AS
--BEGIN
----Banks
--INSERT INTO Banks 
--VALUES (N'Belarusbank'),
--		(N'Belinvestbank'),
--		(N'Alfabank'),
--		(N'Priorbank'),
--		(N'Tinkoff');
----Towns
--INSERT INTO Town 
--VALUES (N'Gomel'),
--		(N'Minsk'),
--		(N'Brest'),
--		(N'Vitebsk'),
--		(N'Grodno');
----Social Status
--INSERT INTO SocialStatus 
--VALUES (N'Retiree'),
--		(N'Invalid'),
--		(N'Worker'),
--		(N'NoWorker'),
--		(N'Minor');
----Branch
--INSERT INTO Branch 
--VALUES ('Golovatski', 1, 2),
--		('Lenina', 2, 1),
--		('Pobeda', 3, 1),
--		('Chehova', 3, 3),
--		('Mazyrova', 5, 4);
----Client
--INSERT INTO Client 
--VALUES (N'Bobrov', N'Nikita', N'Nickolaevich', N'HB3059903'),
--		(N'Piletskaya', N'Sonya', N'Alexandrovna', N'HB3352902'),
--		(N'Rysiy', N'Valentin', N'Vasilievich', N'HB1254904'),
--		(N'Fedorova', N'Polina', N'Vladimirovna', N'HB3203102'),
--		(N'Efremov', N'Vladislav', N'Michailovich', N'HB3049902');
----Account
--INSERT INTO Account 
--VALUES (100,5,1,1),
--		(50,1,1,2),
--		(300,3,3,3),
--		(142,1,4,4),
--		(70,1,5,5);
----Client's cards
--INSERT INTO ClientCard 
--VALUES (20, 1),
--		(30, 1),
--		(50, 2),
--		(0, 5),
--		(100, 4);
--END;

--Query 1
--SELECT Banks.Name
--FROM Banks 
--JOIN Branch ON Branch.IdBank = Banks.IdBank
--JOIN Town ON Town.IdTown = Branch.IdTown
--WHERE Town.Name = 'Brest';

----Qyery 2
--SELECT Client.Name, Client.Surname, Client.LastName, ClientCard.Balance, Banks.Name
--FROM ClientCard
--JOIN Account ON ClientCard.IdAccount = Account.IdAccount
--JOIN Client ON Account.IdClient = Client.IdClient
--JOIN Branch ON Branch.IdBranch = Account.IdBranch
--JOIN Banks ON Banks.IdBank = Branch.IdBank

----Query 3
--SELECT Client.Surname, 
--		Client.Name, Account.Balance, 
--		SUM(ClientCard.Balance) AS 'Card Balance', 
--		Account.Balance-SUM(ClientCard.Balance) AS 'Deference'
--FROM Account 
--JOIN ClientCard ON ClientCard.IdAccount = Account.IdAccount
--JOIN Client ON Client.IdClient = Account.IdAccount
--GROUP BY Client.Surname, Client.Name, Account.Balance
--HAVING SUM(ClientCard.Balance) != Account.Balance

----Query 4
----4.1
--SELECT SocialStatus.Name, COUNT(*) AS 'Count'
--FROM Account
--JOIN SocialStatus ON SocialStatus.IdStatus = Account.IdStatus
--JOIN ClientCard ON ClientCard.IdAccount = Account.IdAccount	
--GROUP BY SocialStatus.Name

------4.2
--SELECT DISTINCT SocialStatus.Name, 
--(
--	SELECT COUNT(*) 
--	FROM ClientCard 
--	WHERE ClientCard.IdAccount IN 
--		(
--			SELECT Account.IdAccount 
--			FROM account 
--			WHERE Account.IdStatus = SocialStatus.IdStatus
--		)
--) AS 'Count'
--FROM SocialStatus 
--WHERE SocialStatus.IdStatus IN 
--(
--	SELECT Account.IdStatus FROM  Account WHERE Account.IdAccount IN
--		(
--			SELECT ClientCard.IdAccount FROM ClientCard WHERE ClientCard.IdAccount = Account.IdAccount
--		)
--)
----Query 5
--CREATE PROC AddMoneyInBalance1
--@_Status INT
--AS
--BEGIN
--UPDATE Account SET Balance = Balance + 10
--WHERE Account.IdStatus = @_Status
--END;

--Query 6
--SELECT Client.Surname, 
--		Client.Name, 
--		(SUM(ClientCard.Balance)+Account.Balance) AS 'All balance',
--		SUM(ClientCard.Balance) AS 'available for translation'
--FROM Account 
--JOIN ClientCard ON Account.IdAccount = ClientCard.IdAccount
--RIGHT JOIN Client ON Client.IdClient = Account.IdClient
--GROUP BY Client.Name, Client.Surname, Account.Balance

----Query 7
--CREATE PROC AddTenDollarsInCandAndRemove10DollarsInBalance
--@IdAccount INT,
--@IdAccountCard INT,
--@Sum INT
--AS
--BEGIN
--BEGIN TRY
--BEGIN TRANSACTION 

--UPDATE Account 
--SET Balance = Balance-@Sum 
--WHERE Account.IdAccount = @IdAccount;
--UPDATE ClientCard 
--SET Balance = Balance+@Sum
--WHERE ClientCard.IdClientCard = @IdAccountCard
--END TRY
--BEGIN CATCH 
--	ROLLBACK TRANSACTION
--	RETURN
--END CATCH
--COMMIT TRANSACTION
--END;
--SELECT * FROM Account
--SELECT * FROM ClientCard
--EXEC AddTenDollarsInCandAndRemove10DollarsInBalance 1,1,20
--SELECT * FROM Account
--SELECT * FROM ClientCard

--Query 8                                                                           �� ��������

CREATE TRIGGER ControlEnterDataInAccount
	ON Account
	AFTER INSERT, UPDATE
AS
DECLARE @msg_error NVARCHAR(50) = 'Data Invalid'
BEGIN 
	BEGIN TRANSACTION
	BEGIN TRY
		IF(EXISTS(
			SELECT * FROM inserted
			LEFT JOIN ClientCard ON ClientCard.IdAccount = inserted.IdAccount
			GROUP BY inserted.IdAccount
			HAVING MAX(inserted.Balance) < SUM(ClientCard.Balance)
		))
		BEGIN
			RAISERROR(@msg_error,16,1) --I still dont understand what the last parameter is for.
		END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH
END
SELECT SUM(ClientCard.Balance) FROM ClientCard WHERE ClientCard.IdAccount = 1
SELECT * FROM Account WHERE Account.IdAccount = 1

UPDATE Account SET Balance = 190 WHERE Account.IdAccount = 1
DROP TRIGGER ControlEnterDataInClientCard
CREATE TRIGGER ControlEnterDataInClientCard
ON ClientCard
	AFTER INSERT, UPDATE
AS
DECLARE @msg_error NVARCHAR(50) = 'Invalid Data'
BEGIN
	BEGIN TRANSACTION
		BEGIN TRY
			IF(EXISTS(
				SELECT * FROM inserted
				LEFT JOIN Account ON Account.IdAccount = inserted.IdAccount
				LEFT JOIN ClientCard ON ClientCard.IdAccount = Account.IdAccount
				GROUP BY inserted.IdAccount
				HAVING SUM((ClientCard.Balance)) > MIN(Account.Balance)
			))
			BEGIN
				RAISERROR(@msg_error,16,1);
			END
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
		END CATCH
END

SELECT Sum(ClientCard.Balance) FROM ClientCard WHERE ClientCard.IdAccount = 1
SELECT * FROM Account WHERE Account.IdAccount = 1

SELECT * FROM ClientCard WHERE ClientCard.IdAccount = 1

INSERT INTO ClientCard 
VALUES (40, 1)
