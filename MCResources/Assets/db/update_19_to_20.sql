
ALTER TABLE friend ADD COLUMN email_hash TEXT;
CREATE INDEX ix_friend_email_hash ON friend ("email_hash");
