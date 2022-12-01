CREATE OR REPLACE PROCEDURE SP_Insert_User(
    _username   TEXT,
    _nickname   TEXT,
    _email      TEXT,
    _password   TEXT
)
LANGUAGE PLPGSQL
AS $$
    DECLARE
        new_id BIGINT := next_id();
    BEGIN
        -- Constraints
        IF LENGTH(_password) < 8 THEN
            RAISE EXCEPTION 'password length must be at least 8 characters';
        ELSIF LENGTH(_password) > 500 THEN
            RAISE EXCEPTION 'password length cannot exceed 500 characters';
        END IF;

        INSERT INTO users(
            user_id,
            user_code,
            username,
            nickname,
            email,
            password,
            role,
            visibility,
            profile,
            settings,
            modified_by
        ) VALUES(
            new_id,
            enc_64bit_crock32(new_id),
            _username,
            _nickname,
            _email,
            CRYPT(_password, GEN_SALT('bf')),
            'user',
            'public',
            '[{'
                '"profile": {'
                    '"status": "",'
                    '"pic_URL": ""'
                '}'
            '}]'::JSONB,
            '[{'
                '"preferences": {'
                    '"theme": "light"'
                '}'
            '}]'::JSONB,
            'system'
        );
    END;
$$;


-- TODO: Make modified_by a variable to log who bans someone
-- TODO: require admin session for this SP to execute! Get modby from session_user_id

SELECT username FROM users
WHERE
    user_id = 382211732036492393
    AND is_active = TRUE;

SELECT st.session_id, st.admin, ut.username FROM sessions st
    LEFT JOIN users ut ON st.session_user_id = ut.user_id
WHERE
    st.session_id = '040d9f37-e4c1-496a-b32b-5d44b6596ca1';
-- 382211732036492393, 0N6Y-72WN-0PE, hhack
-- 382263484644725872, 0N71-579C-V8A, mmary


CREATE OR REPLACE PROCEDURE SP_Ban_User(
    _session_id         UUID,
    _banned_user_id    BIGINT
)
LANGUAGE PLPGSQL
AS $$
    DECLARE
        banned_uid  UUID;
        session_uid UUID;
    BEGIN
        -- Validate that the session has admin rights
        session_uid := (SELECT FN_Validate_Admin_Session(_session_id));

        -- Update profile role and visibility
        UPDATE users
        SET
            is_active = FALSE,
            role = 'banned',
            visibility = 'hidden',
            modified_date = CLOCK_TIMESTAMP(),
            modified_by = session_uid
        WHERE
            user_id = _banned_user_id
            AND role <> 'banned'
        RETURNING user_id INTO banned_uid;

        -- Validate that the user has not already been banned
        IF banned_uid IS NULL THEN
            RAISE EXCEPTION 'user is already banned';
        END IF;

        -- Delete all posts
        UPDATE posts
        SET
            deleted = TRUE,
            modified_date = CLOCK_TIMESTAMP(),
            modified_by = session_uid
        WHERE poster_user_id = banned_uid;

        -- Remove all following / followers
        UPDATE followers
        SET
            following = FALSE,
            unfollowed_date = CLOCK_TIMESTAMP()
        WHERE
            followed_user_id = banned_uid
            OR follower_user_id = banned_uid;
    END;
$$;


-- TODO: Create SP_User_Logout
-- Inputs
--      - Session_ID
-- Deletes the user's session
-- TODO: Create SP_User_Logout_All to remove all sessions? In future might want to be able to have multiple devices logged in
