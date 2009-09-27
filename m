From: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Sun, 27 Sep 2009 08:55:00 +0200
Message-ID: <1254034500.7933.6.camel__34646.9060554684$1254034572$gmane$org@marge.simson.net>
References: <1253820332-10246-1-git-send-email-vgoyal@redhat.com>
	<4ABC28DE.7050809@datenparkplatz.de>
	<20090925202636.GC15007@redhat.com>
	<1253976676.7005.40.camel@marge.simson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1253976676.7005.40.camel-YqMYhexLQo1vAv1Ojkdn7Q@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Ulrich Lukas <stellplatz-nr.13a-7vBoImwI/YtIVYojq0lqJrNAH6kLmebB@public.gmane.org>, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

My dd vs load non-cached binary woes seem to be coming from backmerge.

#if 0 /*MIKEDIDIT sand in gearbox?*/
        /*
         * See if our hash lookup can find a potential backmerge.
         */
        __rq = elv_rqhash_find(q, bio->bi_sector);
        if (__rq && elv_rq_merge_ok(__rq, bio)) {
                *req = __rq;
                return ELEVATOR_BACK_MERGE;
        }
#endif

- = stock = 0
+ = /sys/block/sdb/queue/nomerges = 1
x = backmerge disabled

quantum = 1                                                  Avg
dd pre         58.4     52.5     56.1     61.6     52.3     56.1-  MB/s   virgin/foo
               59.6     54.4     53.0     56.1     58.6     56.3+           1.003
               53.8     56.6     54.7     50.7     59.3     55.0x            .980
perf stat      2.87     0.91     1.64     1.41     0.90      1.5-  Sec
               2.61     1.14     1.45     1.43     1.47      1.6+           1.066
               1.07     1.19     1.20     1.24     1.37      1.2x            .800
dd post        56.6     61.0     66.3     64.7     60.9     61.9-
               54.0     59.3     61.1     58.3     58.9     58.3+            .941
               54.3     60.2     59.6     60.6     60.3     59.0x            .953

quantum = 2
dd pre         59.7     62.4     58.9     65.3     60.3     61.3-
               49.4     51.9     58.7     49.3     52.4     52.3+            .853
               58.3     52.8     53.1     50.4     59.9     54.9x            .895
perf stat      5.81     6.09     6.24    10.13     6.21      6.8-
               2.48     2.10     3.23     2.29     2.31      2.4+            .352
               2.09     2.73     1.72     1.96     1.83      2.0x            .294
dd post        64.0     62.6     64.2     60.4     61.1     62.4-
               52.9     56.2     49.6     51.3     51.2     52.2+            .836
               54.7     60.9     56.0     54.0     55.4     56.2x            .900

quantum = 3
dd pre         65.5     57.7     54.5     51.1     56.3     57.0-
               58.1     53.9     52.2     58.2     51.8     54.8+            .961
               60.5     56.5     56.7     55.3     54.6     56.7x            .994
perf stat     14.01    13.71     8.35     5.35     8.57      9.9-
               1.84     2.30     2.14     2.10     2.45      2.1+            .212
               2.12     1.63     2.54     2.23     2.29      2.1x            .212
dd post        59.2     49.1     58.8     62.3     62.1     58.3-
               59.8     53.2     55.2     50.9     53.7     54.5+            .934
               56.1     61.9     51.9     54.3     53.1     55.4x            .950

quantun = 4
dd pre         57.2     52.1     56.8     55.2     61.6     56.5-
               48.7     55.4     51.3     49.7     54.5     51.9+            .918
               55.8     54.5     50.3     56.4     49.3     53.2x            .941
perf stat     11.98     1.61     9.63    16.21    11.13     10.1-
               2.29     1.94     2.68     2.46     2.45      2.3+            .227
               3.01     1.84     2.11     2.27     2.30      2.3x            .227
dd post        57.2     52.6     62.2     49.3     50.2     54.3-
               50.1     54.5     58.4     54.1     49.0     53.2+            .979
               52.9     53.2     50.6     53.2     50.5     52.0x            .957
