alter system set fal_client = tst1 SCOPE=SPFILE;
alter system fal_server = tst2 SCOPE=SPFILE;
alter system SET log_archive_dest_1 = 'c:\oracle\oradata\tst1\archive' SCOPE=SPFILE;
alter system SER log_archive_dest_2 = 'SERVICE=TST2 ARCH SYNC NOAFFIRM REOPEN=60' SCOPE=SPFILE;


