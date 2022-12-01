CREATE OR REPLACE FUNCTION FN_Validate_Session(
    _session_id UUID
) RETURNS BIGINT
LANGUAGE PLPGSQL
AS $$
    DECLARE
        session_uid TEXT;
        exp_time    TIMESTAMPTZ;
    BEGIN
        SELECT session_user_id, session_expiration INTO session_uid, exp_time FROM sessions
        WHERE
            session_id = _session_id;

        CASE
            WHEN session_uid IS NULL THEN
                RAISE EXCEPTION 'invalid session id';
            WHEN CLOCK_TIMESTAMP() >= exp_time THEN
                RAISE EXCEPTION 'session is expired';
            ELSE
                RETURN session_uid;
        END CASE;
    END;
$$;


-- Takes a session ID and returns a user_id if the session's user is an admin,
-- otherwise raise an exception.
CREATE OR REPLACE FUNCTION FN_Validate_Admin_Session(
    _session_id UUID
) RETURNS BIGINT
LANGUAGE PLPGSQL
AS $$
    DECLARE
        session_uid         TEXT;
        session_is_admin    BOOLEAN;
    BEGIN
        SELECT session_user_id, admin INTO session_uid, session_is_admin FROM sessions
        WHERE
            session_id = _session_id;

        CASE
            WHEN session_is_admin IS NULL THEN
                RAISE EXCEPTION 'invalid session id';
            WHEN session_is_admin = FALSE THEN
                RAISE EXCEPTION 'session does not have admin privileges';
            ELSE
                RETURN session_uid;
        END CASE;
    END;
$$;
