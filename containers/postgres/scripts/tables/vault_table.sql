-- Table that holds information related to files stored on disk
CREATE TABLE vaults(
    vault_id            BIGINT  PRIMARY KEY,
    vault_user_id       BIGINT  REFERENCES users(user_id),
    permission_level    INT     NOT NULL,       -- TODO: Setup perms for max storage, max file size, transfer speed, and bandwidth limit
    vault_name          TEXT    NOT NULL,
    vault_visibility    BOOL NOT NULL           -- TODO: Create visibility enum for all, not just user
);


CREATE TABLE vault_entries(
    vault_entry_id  BIGINT      PRIMARY KEY,
    vault_id        BIGINT      REFERENCES vaults(vault_id),
    vault_code      TEXT        NOT NULL UNIQUE,
    file_name       TEXT        NOT NULL,
    file_path       TEXT        NOT NULL,
    file_size       BIGINT      NOT NULL,
    modified_date   TIMESTAMPTZ NOT NULL DEFAULT CLOCK_TIMESTAMP(),
    modified_by     TEXT        NOT NULL,
    created_date    TIMESTAMPTZ NOT NULL DEFAULT CLOCK_TIMESTAMP(),
    created_by      TEXT        NOT NULL
);
