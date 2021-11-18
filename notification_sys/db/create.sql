/* create with the postgres user */
CREATE DATABASE notification_grpc_db;

/* change connection to the new created database */
CREATE SCHEMA client_schema;

CREATE TABLE client_schema.user_device (
	fcm_token varchar NOT NULL,
	user_id varchar NOT NULL,
	platform varchar NOT NULL,
	updated_at timestamp without time zone NULL DEFAULT  (now() at time zone 'utc'),
	CONSTRAINT user_device_pk PRIMARY KEY (fcm_token, user_id)
);
COMMENT ON TABLE client_schema.user_device IS 'Holds user and their devices';
COMMENT ON COLUMN client_schema.user_device.user_id IS 'User ID';
COMMENT ON COLUMN client_schema.user_device.fcm_token IS 'FCM Registration Token';
COMMENT ON COLUMN client_schema.user_device.platform IS 'It can be android, ios, or web';
COMMENT ON COLUMN client_schema.user_device.updated_at IS 'Used to clean up staled tokens';

CREATE TABLE client_schema.notification (
	id int NOT NULL GENERATED ALWAYS AS IDENTITY,
	title varchar NOT NULL,	
	message varchar NOT NULL,	
	sender_id varchar NOT NULL,
	recipient_id varchar NOT NULL,
	created_at timestamp without time zone NULL DEFAULT  (now() at time zone 'utc'),
	is_read boolean default false,
	read_at timestamp without time zone NULL,
	CONSTRAINT notification_pk PRIMARY KEY (id)
);

COMMENT ON TABLE client_schema.notification IS 'Holds notification data';
COMMENT ON COLUMN client_schema.notification.id IS 'Notification ID';
COMMENT ON COLUMN client_schema.notification.title IS 'Notification title';
COMMENT ON COLUMN client_schema.notification.message IS 'Notification message';
COMMENT ON COLUMN client_schema.notification.sender_id IS 'Who sent the notification';
COMMENT ON COLUMN client_schema.notification.recipient_id IS 'Who received the notification';
COMMENT ON COLUMN client_schema.notification.created_at IS 'When the notification was created at';
COMMENT ON COLUMN client_schema.notification.is_read IS 'Whether the notification was read or not';
COMMENT ON COLUMN client_schema.notification.read_at IS 'When the notification was read at';

/* run clients this user instead */
CREATE USER notification_grpc_user WITH PASSWORD '<<USER_PASSWORD>>';

alter role notification_grpc_user set client_encoding to 'utf-8'; 
alter role notification_grpc_user set default_transaction_isolation to 'read committed';
alter role notification_grpc_user set timezone to 'utc';
grant all privileges on database notification_grpc_db to notification_grpc_user;
grant execute on all functions in schema client_schema to notification_grpc_user;
grant usage on schema client_schema to notification_grpc_user;
grant all on all tables in schema client_schema to notification_grpc_user;

