use demo
go

declare @MinVersion bigint = change_tracking_min_valid_version(OBJECT_ID('dbo.Product'));

exec dbo._SetChangeTrackingVersion @tablename = 'dbo.Product', @currentversion = @MinVersion;