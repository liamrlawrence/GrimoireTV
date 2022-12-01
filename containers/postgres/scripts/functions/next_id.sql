CREATE SEQUENCE next_id_seq
INCREMENT 1
MINVALUE 0
MAXVALUE 1023
START 0
CYCLE;

-- Generate a 64-bit randomized timestamp, with a max throughput of 1024/ms
CREATE OR REPLACE FUNCTION next_id(OUT result BIGINT)
LANGUAGE PLPGSQL
AS $$
    DECLARE
        our_epoch   BIGINT := 1577836800000;  -- January 1, 2020 12:00:00 AM
        now_millis  BIGINT;
        shard_id    BIGINT := (SELECT(FLOOR(RANDOM() * 4096))::BIGINT);
        seq_id      BIGINT := NEXTVAL('next_id_seq'::REGCLASS);
    BEGIN
        SELECT FLOOR(EXTRACT(EPOCH FROM CLOCK_TIMESTAMP()) * 1000) INTO now_millis;
        -- 64 bits
        result := (now_millis - our_epoch) << 22;   -- 42-bit Timestamp
        result := result | (shard_id << 10);        -- 12-bit Shard ID
        result := result | (seq_id);                -- 10-bit Sequence ID
    END
$$;
