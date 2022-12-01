SELECT FN_Validate_Session('3459d630-b5ee-4e22-b627-d9c51341eaf');

CREATE OR REPLACE PROCEDURE SP_Upsert_Follower(
    _session_id         UUID,
    _followed_user_id   BIGINT,
    _following          BOOLEAN
)
LANGUAGE PLPGSQL
AS $$
    DECLARE
        session_uid BIGINT := (SELECT FN_Validate_Session(_session_id));
    BEGIN
        RAISE EXCEPTION 'suid: %', session_uid;

        -- Constraints
        IF session_uid = _followed_user_id THEN
            RAISE EXCEPTION 'users cannot follow themselves';
        ELSIF NOT EXISTS(SELECT user_id FROM users WHERE user_id = _followed_user_id AND is_active = TRUE) THEN
            RAISE EXCEPTION 'the account you are trying to follow is disabled';
        END IF;

        -- Update a follower record that already exists if there is a change detected
        IF EXISTS(
            SELECT followed_user_id FROM followers
            WHERE
                followed_user_id = _followed_user_id
                AND follower_user_id = session_uid
        ) THEN
            UPDATE followers
            SET
                following = _following,
                followed_date = (CASE WHEN _following = TRUE THEN CLOCK_TIMESTAMP() ELSE followed_date END),
                unfollowed_date = (CASE WHEN _following = TRUE THEN unfollowed_date ELSE CLOCK_TIMESTAMP() END)
            WHERE
                following = NOT _following
                AND followed_user_id = _followed_user_id
                AND follower_user_id = session_uid;

        -- Create a new follower record
        ELSIF _following = TRUE THEN
            INSERT INTO followers(
                followed_user_id,
                follower_user_id
            ) VALUES(
                _followed_user_id,
                session_uid
            );
        END IF;
    END;
$$;
