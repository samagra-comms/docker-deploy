CREATE TABLE testkeyspace.xmessage (
    userid text,
    fromid text,
    timestamp timestamp,
    app text,
    auxdata text,
    botuuid uuid,
    causeid text,
    channel text,
    id uuid,
    messageid text,
    messagestate text,
    ownerid text,
    ownerorgid text,
    provider text,
    remarks text,
    replyid text,
    respmsgid text,
    sessionid uuid,
    xmessage text,
    tags list<text>,
    PRIMARY KEY ((userid, fromid), timestamp)
) WITH CLUSTERING ORDER BY (timestamp DESC)
    AND additional_write_policy = '99p'
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'NONE'}
    AND cdc = false
    AND comment = ''
    AND compaction = {'class': 'org.apache.cassandra.db.compaction.SizeTieredCompactionStrategy', 'max_threshold': '32', 'min_threshold': '4'}
    AND compression = {'chunk_length_in_kb': '16', 'class': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND memtable = 'default'
    AND crc_check_chance = 1.0
    AND default_time_to_live = 0
    AND extensions = {}
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair = 'BLOCKING'
    AND speculative_retry = '99p';