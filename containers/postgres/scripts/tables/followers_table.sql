-- Followers table
CREATE TABLE followers(
    followed_user_id    BIGINT      REFERENCES users(user_id),
    follower_user_id    BIGINT      REFERENCES users(user_id),
    following           BOOLEAN     NOT NULL DEFAULT TRUE,
    followed_date       TIMESTAMPTZ NOT NULL DEFAULT CLOCK_TIMESTAMP(),
    unfollowed_date     TIMESTAMPTZ NOT NULL DEFAULT TIMESTAMPTZ 'epoch',
    PRIMARY KEY (followed_user_id, follower_user_id)
);
