-- Posts table
CREATE TABLE posts(
    post_id         BIGINT      PRIMARY KEY,
    post_code       TEXT        NOT NULL UNIQUE,
    poster_user_id  BIGINT      NOT NULL REFERENCES users(user_id) ,
    content         JSONB       NOT NULL,
    deleted         BOOLEAN     NOT NULL DEFAULT FALSE,
    modified_date   TIMESTAMPTZ NOT NULL DEFAULT TIMESTAMPTZ 'epoch',
    modified_by     TEXT        NOT NULL,
    created_date    TIMESTAMPTZ NOT NULL DEFAULT CLOCK_TIMESTAMP()
);
