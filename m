From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Memory controller test results (v6)
Date: Sun, 19 Aug 2007 15:16:58 +0530
Message-ID: <20070819094658.654.84837.sendpatchset@balbir-laptop>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Nick Piggin <npiggin-l3A5Bk7waGM@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux MM Mailing List <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Eric W Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi, Andrew,

Here are more test results for v6 of the memory controller posted at
	http://lkml.org/lkml/2007/8/17/69

The tests were run under three different configurations

1. disabled - the memory controller was not compiled in
2. notmnted - the memory controller was compiled in, but the container
   filesystem was not mounted (one could view this configuration as
   a memory controller with no limits enforced)
3. limit400 - the memory controller was compiled in and the container
   running the tests was limited to 400 MB of memory usage.

Tests run
----------
1. lmbench
2. ltp
3. vmmstress
4. aim9
5. memtest (succeeded)

Results posted
--------------
1. lmbench
2. ltp
3. vmmstress
4. aim9


Lmbench
-------


                 L M B E N C H  2 . 0   S U M M A R Y
                 ------------------------------------


Basic system parameters
----------------------------------------------------
Host                 OS Description              Mhz
                                                    
--------- ------------- ----------------------- ----
disabled  Linux 2.6.23-        x86_64-linux-gnu 1993
limit400  Linux 2.6.23-        x86_64-linux-gnu 1993
notmnted  Linux 2.6.23-        x86_64-linux-gnu 1993

Processor, Processes - times in microseconds - smaller is better
----------------------------------------------------------------
Host                 OS  Mhz null null      open selct sig  sig  fork exec sh  
                             call  I/O stat clos TCP   inst hndl proc proc proc
--------- ------------- ---- ---- ---- ---- ---- ----- ---- ---- ---- ---- ----
disabled  Linux 2.6.23- 1993 0.08 0.27 2.74 3.96  16.0 0.23 1.55 128. 479. 5572
limit400  Linux 2.6.23- 1993 0.08 0.30 3.00 4.54  17.7 0.23 1.74 139. 537. 5825
notmnted  Linux 2.6.23- 1993 0.08 0.27 2.78 4.23  16.0 0.23 1.57 129. 527. 5809

Context switching - times in microseconds - smaller is better
-------------------------------------------------------------
Host                 OS 2p/0K 2p/16K 2p/64K 8p/16K 8p/64K 16p/16K 16p/64K
                        ctxsw  ctxsw  ctxsw ctxsw  ctxsw   ctxsw   ctxsw
--------- ------------- ----- ------ ------ ------ ------ ------- -------
disabled  Linux 2.6.23- 3.380 4.5900 5.5200 5.4100 8.7800 5.68000 8.89000
limit400  Linux 2.6.23- 4.180 4.3400 5.1100 4.7900 7.7200 5.36000 8.18000
notmnted  Linux 2.6.23- 4.100 3.3600 5.1100 5.0200 8.9200 5.08000 9.02000

*Local* Communication latencies in microseconds - smaller is better
-------------------------------------------------------------------
Host                 OS 2p/0K  Pipe AF     UDP  RPC/   TCP  RPC/ TCP
                        ctxsw       UNIX         UDP         TCP conn
--------- ------------- ----- ----- ---- ----- ----- ----- ----- ----
disabled  Linux 2.6.23- 3.380  11.8 18.6  20.0  23.2  23.3  26.8 34.5
limit400  Linux 2.6.23- 4.180  11.0 21.0  22.3  23.7  23.1  24.7 37.9
notmnted  Linux 2.6.23- 4.100  11.1 18.7  18.4  22.7  22.8  26.4 41.0

File & VM system latencies in microseconds - smaller is better
--------------------------------------------------------------
Host                 OS   0K File      10K File      Mmap    Prot    Page	
                        Create Delete Create Delete  Latency Fault   Fault 
--------- ------------- ------ ------ ------ ------  ------- -----   ----- 
disabled  Linux 2.6.23-   18.4   14.9  228.2   73.2   2998.0 0.375 1.00000
limit400  Linux 2.6.23-   17.9   17.6  240.0   77.6   1874.0 0.496 2.00000
notmnted  Linux 2.6.23-   18.9   18.0  188.6   74.9   3044.0 0.467 2.00000

*Local* Communication bandwidths in MB/s - bigger is better
-----------------------------------------------------------
Host                OS  Pipe AF    TCP  File   Mmap  Bcopy  Bcopy  Mem   Mem
                             UNIX      reread reread (libc) (hand) read write
--------- ------------- ---- ---- ---- ------ ------ ------ ------ ---- -----
disabled  Linux 2.6.23- 740. 1210 816. 1276.0 2534.0  907.8  877.4 2152 1247.
limit400  Linux 2.6.23- 591. 1186 826. 1280.4 2457.4 1117.8  861.7 2634 1536.
notmnted  Linux 2.6.23- 691. 1196 800. 1434.1 1761.6  854.2  827.9 1876 1258.

Memory latencies in nanoseconds - smaller is better
    (WARNING - may not be correct, check graphs)
---------------------------------------------------
Host                 OS   Mhz  L1 $   L2 $    Main mem    Guesses
--------- -------------  ---- ----- ------    --------    -------
disabled  Linux 2.6.23-  1993 1.506 6.0270   97.5
limit400  Linux 2.6.23-  1993 1.506 6.0280   97.5
notmnted  Linux 2.6.23-  1993 1.507 6.0280   97.5

LTP
---

Note, only ltp failures are posted (no new failures were seen due
to the memory controller)

disabled
--------


clone06     0  WARN  :  sprintf() failed
clone06     1  BROK  :  Unexpected signal 11 received.
fcntl27     1  BROK  :  Unexpected signal 11 received.
fcntl28     1  BROK  :  Unexpected signal 11 received.
kill05      0  INFO  :  WARNING: shared memory deletion failed.
mincore01    4  FAIL  :  call succeeded unexpectedly
setrlimit03    1  FAIL  :  call succeeded unexpectedly
swapon02    0  WARN  :  Failed swapon for file swapfile31 returned -96
swapon02    0  WARN  :  Failed to turn off swap files. system reboot after execution of LTP test suite is recommended
swapon02    0  WARN  :  Failed to turn off swap files. system reboot after execution of LTP test suite is recommended
swapon02    3  BROK  :  Cleanup failed, quitting the test
swapon02    4  BROK  :  Remaining cases broken
INFO: pan reported some tests FAIL

limit400
--------

clone06     0  WARN  :  sprintf() failed
clone06     1  BROK  :  Unexpected signal 11 received.
fcntl27     1  BROK  :  Unexpected signal 11 received.
fcntl28     1  BROK  :  Unexpected signal 11 received.
kill05      0  INFO  :  WARNING: shared memory deletion failed.
mincore01    4  FAIL  :  call succeeded unexpectedly
setrlimit03    1  FAIL  :  call succeeded unexpectedly
swapon02    0  WARN  :  Failed swapon for file swapfile31 returned -96
swapon02    0  WARN  :  Failed to turn off swap files. system reboot after execution of LTP test suite is recommended
swapon02    0  WARN  :  Failed to turn off swap files. system reboot after execution of LTP test suite is recommended
swapon02    3  BROK  :  Cleanup failed, quitting the test
swapon02    4  BROK  :  Remaining cases broken
INFO: pan reported some tests FAIL

notmnted
--------

clone06     0  WARN  :  sprintf() failed
clone06     1  BROK  :  Unexpected signal 11 received.
fcntl27     1  BROK  :  Unexpected signal 11 received.
fcntl28     1  BROK  :  Unexpected signal 11 received.
kill05      0  INFO  :  WARNING: shared memory deletion failed.
mincore01    4  FAIL  :  call succeeded unexpectedly
setrlimit03    1  FAIL  :  call succeeded unexpectedly
swapon02    0  WARN  :  Failed swapon for file swapfile31 returned -96
swapon02    0  WARN  :  Failed to turn off swap files. system reboot after execution of LTP test suite is recommended
swapon02    0  WARN  :  Failed to turn off swap files. system reboot after execution of LTP test suite is recommended
swapon02    3  BROK  :  Cleanup failed, quitting the test
swapon02    4  BROK  :  Remaining cases broken
INFO: pan reported some tests FAIL

VMMSTRESS
---------

The vmmstress function calls the following ltp tests: mmstress, mmap1.c,
mmap2.c and mmap3.c. 

disabled
--------

vmmstress1
----------

Test Start Time: Sat Aug 18 13:06:26 2007
-----------------------------------------
Testcase                       Result     Exit Value
--------                       ------     ----------
mmstress                       PASS       0    
mmap1                          PASS       0    
mmap2                          PASS       0    
mmap3                          PASS       0    

-----------------------------------------------
Total Tests: 4
Total Failures: 0
Kernel Version: 2.6.23-rc2-mm2-autokern1
Machine Architecture: x86_64

vmmstress2
----------

Test Start Time: Sat Aug 18 12:06:23 2007
-----------------------------------------
Testcase                       Result     Exit Value
--------                       ------     ----------
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        FAIL       14   

-----------------------------------------------
Total Tests: 1
Total Failures: 1
Kernel Version: 2.6.23-rc2-mm2-autokern1
Machine Architecture: x86_64


limit400
--------

vmmstress1
----------

Test Start Time: Sat Aug 18 08:37:36 2007
-----------------------------------------
Testcase                       Result     Exit Value
--------                       ------     ----------
mmstress                       PASS       0    
mmap1                          PASS       0    
mmap2                          PASS       0    
mmap3                          PASS       0    

-----------------------------------------------
Total Tests: 4
Total Failures: 0
Kernel Version: 2.6.23-rc2-mm2-autokern1
Machine Architecture: x86_64


vmmstress2
----------

Test Start Time: Sat Aug 18 07:37:29 2007
-----------------------------------------
Testcase                       Result     Exit Value
--------                       ------     ----------
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        FAIL       14   

-----------------------------------------------
Total Tests: 1
Total Failures: 1
Kernel Version: 2.6.23-rc2-mm2-autokern1
Machine Architecture: x86_64


notmnted
--------

vmmstress1
----------

Test Start Time: Sat Aug 18 03:05:16 2007
-----------------------------------------
Testcase                       Result     Exit Value
--------                       ------     ----------
mmstress                       PASS       0    
mmap1                          PASS       0    
mmap2                          PASS       0    
mmap3                          PASS       0    

-----------------------------------------------
Total Tests: 4
Total Failures: 0
Kernel Version: 2.6.23-rc2-mm2-autokern1
Machine Architecture: x86_64

vmmstress2
----------


Test Start Time: Sat Aug 18 02:05:14 2007
-----------------------------------------
Testcase                       Result     Exit Value
--------                       ------     ----------
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        PASS       0    
mtest01                        FAIL       14   

-----------------------------------------------
Total Tests: 1
Total Failures: 1
Kernel Version: 2.6.23-rc2-mm2-autokern1
Machine Architecture: x86_64


AIM9
----

disabled
--------

Starting time:      Sat Aug 18 14:06:53 2007
Projected Run Time: 0:08:00
Projected finish:   Sat Aug 18 14:14:53 2007



------------------------------------------------------------------------------------------------------------
 Test        Test        Elapsed  Iteration    Iteration          Operation
Number       Name      Time (sec)   Count   Rate (loops/sec)    Rate (ops/sec)
------------------------------------------------------------------------------------------------------------
     1 creat-clo           60.01       9150  152.47459       152474.59 File Creations and Closes/second
     2 page_test           60.00       6803  113.38333       192751.67 System Allocations & Pages/second
     3 brk_test            60.01       8479  141.29312      2401983.00 System Memory Allocations/second
     4 jmp_test            60.01     983432 16387.80203     16387802.03 Non-local gotos/second
     5 signal_test         60.01      27402  456.62390       456623.90 Signal Traps/second
     6 exec_test           60.02       2789   46.46784          232.34 Program Loads/second
     7 fork_test           60.03       2736   45.57721         4557.72 Task Creations/second
     8 link_test           60.05      45537  758.31807        47774.04 Link/Unlink Pairs/second
------------------------------------------------------------------------------------------------------------
Projected Completion time:  Sat Aug 18 14:14:53 2007
Actual Completion time:     Sat Aug 18 14:14:53 2007
Difference:                 0:00:00


limit400
--------


Starting time:      Sat Aug 18 09:38:02 2007
Projected Run Time: 0:08:00
Projected finish:   Sat Aug 18 09:46:02 2007



------------------------------------------------------------------------------------------------------------
 Test        Test        Elapsed  Iteration    Iteration          Operation
Number       Name      Time (sec)   Count   Rate (loops/sec)    Rate (ops/sec)
------------------------------------------------------------------------------------------------------------
     1 creat-clo           60.01       7878  131.27812       131278.12 File Creations and Closes/second
     2 page_test           60.00       5411   90.18333       153311.67 System Allocations & Pages/second
     3 brk_test            60.02       5098   84.93835      1443952.02 System Memory Allocations/second
     4 jmp_test            60.00     983192 16386.53333     16386533.33 Non-local gotos/second
     5 signal_test         60.01      28628  477.05382       477053.82 Signal Traps/second
     6 exec_test           60.02       2628   43.78540          218.93 Program Loads/second
     7 fork_test           60.01       2510   41.82636         4182.64 Task Creations/second
     8 link_test           60.02      39902  664.81173        41883.14 Link/Unlink Pairs/second
------------------------------------------------------------------------------------------------------------
Projected Completion time:  Sat Aug 18 09:46:02 2007
Actual Completion time:     Sat Aug 18 09:46:02 2007
Difference:                 0:00:00


notmnted
--------

Starting time:      Sat Aug 18 04:06:05 2007
Projected Run Time: 0:08:00
Projected finish:   Sat Aug 18 04:14:05 2007



------------------------------------------------------------------------------------------------------------
 Test        Test        Elapsed  Iteration    Iteration          Operation
Number       Name      Time (sec)   Count   Rate (loops/sec)    Rate (ops/sec)
------------------------------------------------------------------------------------------------------------
     1 creat-clo           60.02       9164  152.68244       152682.44 File Creations and Closes/second
     2 page_test           60.01       5767   96.10065       163371.10 System Allocations & Pages/second
     3 brk_test            60.01       6147  102.43293      1741359.77 System Memory Allocations/second
     4 jmp_test            60.01     983397 16387.21880     16387218.80 Non-local gotos/second
     5 signal_test         60.01      26970  449.42510       449425.10 Signal Traps/second
     6 exec_test           60.02       2638   43.95202          219.76 Program Loads/second
     7 fork_test           60.01       2575   42.90952         4290.95 Task Creations/second
     8 link_test           60.01      49737  828.81186        52215.15 Link/Unlink Pairs/second
------------------------------------------------------------------------------------------------------------
Projected Completion time:  Sat Aug 18 04:14:05 2007
Actual Completion time:     Sat Aug 18 04:14:05 2007
Difference:                 0:00:00

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
