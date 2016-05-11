-- Backlog table
CREATE TABLE Backlog(
	callid TEXT PRIMARY KEY, 
	calltype INTEGER, 
	timestamp INTEGER, 
    has_priority INTEGER DEFAULT +0,
    last_resend_timestamp INTEGER DEFAULT +0,
    retention_timeout INTEGER DEFAULT +0,
    response_handler BLOB,
    function TEXT NOT NULL DEFAULT "no function recorded",
	callbody TEXT);

CREATE INDEX ix_Backlog_timestamp ON Backlog(timestamp);
CREATE INDEX ix_Backlog_has_priority ON Backlog (has_priority);
CREATE INDEX ix_Backlog_last_resend_timestamp ON Backlog (last_resend_timestamp);
CREATE INDEX ix_Backlog_retention_timeout ON Backlog (retention_timeout);
CREATE INDEX ix_backlog_single_call ON Backlog (calltype, last_resend_timestamp, function);
