CREATE SCHEMA client;

CREATE TABLE client.user_device (
	id serial NOT NULL,
	user_id varchar NOT NULL,
	fcm_token varchar NOT NULL,
	platform varchar NOT NULL,
	updated_at timestamp without time zone NULL DEFAULT  (now() at time zone 'utc'),
	CONSTRAINT user_device_pk PRIMARY KEY (id)
);
COMMENT ON TABLE client.user_device IS 'Holds user and their devices';

-- Column comments

COMMENT ON COLUMN client.user_device.id IS 'Row ID';
COMMENT ON COLUMN client.user_device.user_id IS 'User ID';
COMMENT ON COLUMN client.user_device.fcm_token IS 'FCM Registration Token';
COMMENT ON COLUMN client.user_device.platform IS 'It can be android, ios, or web';
COMMENT ON COLUMN client.user_device.updated_at IS 'Used to clean up staled tokens';
