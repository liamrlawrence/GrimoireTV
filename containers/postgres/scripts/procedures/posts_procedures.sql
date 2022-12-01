CREATE OR REPLACE PROCEDURE SP_Insert_Post(
    _session_id UUID,
    _message    TEXT
)
LANGUAGE PLPGSQL
AS $$
    DECLARE
        new_id      BIGINT := next_id();
        session_uid BIGINT := (SELECT FN_Validate_Session(_session_id));
    BEGIN
        -- Constraints
        IF LENGTH(_message) > 280 THEN
            RAISE EXCEPTION 'message length cannot exceed 280 characters';
        END IF;

        INSERT INTO posts(
            post_id,
            post_code,
            poster_user_id,
            content,
            modified_by
        ) VALUES(
            new_id,
            enc_64bit_crock32(new_id),
            session_uid,
            CONCAT(
                '[{'
                    '"body": {'
                        '"message": "', _message, '"'
                    '}'
                '}]')::JSONB,
            session_uid
        );
    END;
$$;
