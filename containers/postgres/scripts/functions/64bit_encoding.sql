-- Encodes a 64 bit number in Base-32, returning a 16 character string
CREATE OR REPLACE FUNCTION enc_64bit_base32(x BIGINT) RETURNS VARCHAR(16)
LANGUAGE PLPGSQL
AS $$
    DECLARE
        encoding CHAR(1) [] := ARRAY[
            'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
            'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
            'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
            'Y', 'Z', '2', '3', '4', '5', '6', '7'
        ];

        n BIT(64) := x::BIT(64);        -- 64-bit copy of the input
        b1 BIT(40);                     -- 40-bit block 1
        b2 BIT(40);                     -- 40-bit block 2

        s VARCHAR(16) := '';            -- String to be returned
        s_len INT := 16;                -- Size of s

        align INT := 64;                -- The number of bits to left-shift the input for it to be properly aligned
        pad INT := 5;                   -- The number of padding bytes required at the end of the last block
        c INT;                          -- Used for looking up the encoded character
    BEGIN
        -- Align the input
        WHILE x != 0 LOOP
            x := x >> 8;
            align := align - 8;
        END LOOP;
        n := n << align;

        -- Pack the bits into two 40-bit blocks
        b1 := (n >> 24)::BIGINT::BIT(40);
        b2 := (n << 40)::BIT(40);

        -- Count the number of 5-bit padding bytes needed at the end of block 2
        WHILE b2 != b'0'::BIT(40) LOOP
            b2 := b2 << 8;
            pad := pad - 1;
        END LOOP;
        b2 := (n << 40)::BIT(40);

        -- Process block 1
        FOR _ IN 1..8 LOOP
            c := ((b1 & b'11111'::BIT(40)) >> 35)::BIGINT;
            s := CONCAT(s, encoding[c+1]);
            b1 := b1 << 5;
        END LOOP;

        -- Process block 2
        FOR _ IN 1..8 LOOP
            c := ((b2 & b'11111'::BIT(40)) >> 35)::BIGINT;
            s := CONCAT(s, encoding[c+1]);
            b2 := b2 << 5;
        END LOOP;

        -- Return the final string with proper padding
        CASE
            WHEN pad = 1 THEN
                RETURN CONCAT(SUBSTR(s, 1, s_len - 1), '=');
            WHEN pad = 2 THEN
                RETURN CONCAT(SUBSTR(s, 1, s_len - 3), '===');
            WHEN pad = 3 THEN
                RETURN CONCAT(SUBSTR(s, 1, s_len - 4), '====');
            WHEN pad = 4 THEN
                RETURN CONCAT(SUBSTR(s, 1, s_len - 6), '======');
            ELSE
                RETURN s;
        END CASE;
    END;
$$;


-- Encodes a 64 bit number in Crockford-32, returning a string
-- TODO BUG: Sometimes bytes at the end are dropped (input: 381508387442752512) - 18Nov2022
CREATE OR REPLACE FUNCTION enc_64bit_crock32(x BIGINT) RETURNS TEXT
LANGUAGE PLPGSQL
AS $$
    DECLARE
        encoding CHAR(1) [] := ARRAY[
            '0', '1', '2', '3', '4', '5', '6', '7',
            '8', '9', 'A', 'B', 'C', 'D', 'E', 'F',
            'G', 'H', 'J', 'K', 'M', 'N', 'P', 'Q',
            'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z'
        ];

        n BIT(64) := x::BIT(64);        -- 64-bit copy of the input
        b1 BIT(40);                     -- 40-bit block 1
        b2 BIT(40);                     -- 40-bit block 2

        s TEXT := '';                   -- String to be returned
        s_len INT := 16;                -- Size of s

        align INT := 64;                -- Stores the number of bits to left-shift the input for it to be properly aligned
        pad INT := 5;                   -- Stores the number of padding bytes required at the end of the last block
        c INT;                          -- Used for looking up the encoded character
    BEGIN
        -- Align the input
        WHILE x != 0 LOOP
            x := x >> 8;
            align := align - 8;
        END LOOP;
        n := n << align;

        -- Pack the bits into two 40-bit blocks
        b1 := (n >> 24)::BIGINT::BIT(40);
        b2 := (n << 40)::BIT(40);

        -- Count the number of 5-bit padding bytes needed at the end of block 2
        WHILE b2 != b'0'::BIT(40) LOOP
            b2 := b2 << 8;
            pad := pad - 1;
        END LOOP;
        b2 := (n << 40)::BIT(40);

        -- Process block 1
        FOR i IN 1..8 LOOP
            c := ((b1 & b'11111'::BIT(40)) >> 35)::BIGINT;
            s := CONCAT(s, encoding[c+1]);
            b1 := b1 << 5;
            IF i = '4' OR i = '8' THEN
                s := CONCAT(s, '-');
            END IF;
        END LOOP;

        -- Process block 2
        FOR _ IN 1..8 LOOP
            c := ((b2 & b'11111'::BIT(40)) >> 35)::BIGINT;
            s := CONCAT(s, encoding[c+1]);
            b2 := b2 << 5;
        END LOOP;

        -- Ignoring trailing null bytes and return the final string
        CASE
            WHEN pad = 1 THEN
                RETURN CONCAT(SUBSTR(s, 1, s_len - 1), '');
            WHEN pad = 2 THEN
                RETURN CONCAT(SUBSTR(s, 1, s_len - 3), '');
            WHEN pad = 3 THEN
                RETURN CONCAT(SUBSTR(s, 1, s_len - 4), '');
            WHEN pad = 4 THEN
                RETURN CONCAT(SUBSTR(s, 1, s_len - 6), '');
            ELSE
                RETURN s;
        END CASE;
    END;
$$;
