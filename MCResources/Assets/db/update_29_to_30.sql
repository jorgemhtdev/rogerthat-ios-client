CREATE TRIGGER tr_message_thread_dirtyness_after_update AFTER UPDATE OF needs_my_answer, dirty ON message FOR EACH ROW
BEGIN
    UPDATE message
    SET thread_dirty = 
    CASE WHEN (
        SELECT sum(m1.dirty) + sum(m1.needs_my_answer) 
        FROM message m1 INNER JOIN message m2 ON m1.sortid = m2.sortid 
        WHERE m2.key = NEW.key
    ) > 0 THEN 1 ELSE 0 END
    WHERE sortid = NEW.sortid; END;

CREATE TRIGGER tr_message_thread_dirtyness_after_insert AFTER INSERT ON message FOR EACH ROW
BEGIN
    UPDATE message
	SET thread_dirty = 
    CASE WHEN (
        SELECT sum(m1.dirty) + sum(m1.needs_my_answer) 
        FROM message m1 INNER JOIN message m2 ON m1.sortid = m2.sortid 
        WHERE m2.key = NEW.key
    ) > 0 THEN 1 ELSE 0 END
    WHERE sortid = NEW.sortid; END;

-- iOS-only stuff

ALTER TABLE message ADD COLUMN visible_reply_count INTEGER DEFAULT 0;

UPDATE message SET visible_reply_count = (SELECT count(*) FROM message m1 WHERE m1.sortid = message.sortid AND m1.show_in_message_list = 1);

--

DROP TRIGGER tr_message_show_in_list_after_insert;

CREATE TRIGGER tr_message_show_in_list_after_insert AFTER INSERT ON message FOR EACH ROW 
BEGIN 
	UPDATE message 
	SET show_in_message_list = 
		CASE 
			WHEN parent_key IS NULL OR needs_my_answer == 1 OR dirty == 1 OR key = last_thread_message THEN 1 
			ELSE 0 
		END 
	WHERE key = NEW.key;

    UPDATE message
    SET visible_reply_count = 
        (SELECT count(*) FROM message m1 WHERE m1.sortid = NEW.sortid AND m1.show_in_message_list = 1) 
    WHERE message.sortid = NEW.sortid;

    END;

--

DROP TRIGGER tr_message_show_in_list_after_update;

CREATE TRIGGER tr_message_show_in_list_after_update AFTER UPDATE OF needs_my_answer, dirty, last_thread_message ON message FOR EACH ROW 
BEGIN 
	UPDATE message
	SET show_in_message_list = 
		CASE
			WHEN NEW.parent_key IS NULL OR NEW.needs_my_answer == 1 OR NEW.dirty == 1 OR NEW.key = NEW.last_thread_message THEN 1
			ELSE 0
		END
	WHERE key = NEW.key;

    UPDATE message
    SET visible_reply_count = 
        (SELECT count(*) FROM message m1 WHERE m1.sortid = NEW.sortid AND m1.show_in_message_list = 1) 
    WHERE message.sortid = NEW.sortid;

    END;
