-- Add index for friends by existence, type, organization_type
CREATE INDEX ix_friend_by_organization_type ON friend (existence, type, organization_type);
