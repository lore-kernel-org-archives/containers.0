From: Dong-Jae Kang <baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/2] range-bw documentation
Date: Mon, 4 May 2009 19:56:59 +0900
Message-ID: <2891419e0905040356x26b1ffc8y73c20414629482fc__32735.6297443204$1241434834$gmane$org@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
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
To: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
List-Id: containers.vger.kernel.org

This is the patch file for range-bw documentation

From: Dong-Jae Kang <djkang-mINagvnPBMnWF1p7bDn8Kw@public.gmane.org> or  <baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Range-BW is an I/O controller supports the process group-based range bandwidth
according to the priority or importance of the group.
Range bandwidth means the predicable I/O bandwidth with minimum and
maximum value
defined by administrator.

Signed-off-by: Dong-Jae Kang <baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Chei-Yol Kim <gauri-mINagvnPBMnWF1p7bDn8Kw@public.gmane.org>

===========================================================================================

diff -urN linux-2.6.29-orig/Documentation/device-mapper/range-bw.txt
linux-2.6.29-patch/Documentation/device-mapper/range-bw.txt
--- linux-2.6.29-orig/Documentation/device-mapper/range-bw.txt	1970-01-01
09:00:00.000000000 +0900
+++ linux-2.6.29-patch/Documentation/device-mapper/range-bw.txt	2009-05-04
15:38:02.000000000 +0900
@@ -0,0 +1,91 @@
+Range-BW I/O controller by Dong-Jae Kang <djkang-mINagvnPBMnWF1p7bDn8Kw@public.gmane.org>
+
+
+1. Introduction
+===============
+
+The design of Range-BW is related with three another parts, Cgroup,
bio-cgroup (or blkio-cgroup) and dm-ioband
+and it was implemented as an additional controller for dm-ioband.
+Cgroup framework is used to support process grouping mechanism and
bio-cgroup is used to control delayed I/O or
+non-direct I/O. Finally, dm-ioband is a kind of I/O controller
allowing the proportional I/O bandwidth
+to process groups based on its priority.
+The supposed controller supports the process group-based range
bandwidth according to the priority or
+importance of the group. Range bandwidth means the predicable I/O
bandwidth with minimum and maximum value
+defined by administrator.
+
+Minimum I/O bandwidth should be guaranteed for stable performance or
reliability of specific service
+and I/O bandwidth over maximum should be throttled to protect the
limited I/O resource from over-provisioning
+in unnecessary usage or to reserve the I/O bandwidth for another use.
+So, Range-BW was implemented to include the two concepts,
guaranteeing of minimum I/O requirement
+and limitation of unnecessary bandwidth depending on its priority.
+And it was implemented as device mapper driver such like dm-ioband.
+So, it is independent of the underlying specific I/O scheduler, for
example, CFQ, AS, NOOP, deadline and so on.
+
+Range-BW has two kinds of operation modes, min-max and max mode.
Min-max mode is to supports guaranteeing
+the minimum I/O requirement and limitation of unnecessary I/O
bandwidth at the same time.
+And max mode is to support only limitation. So in case of min-max
mode, you need to configure min-bw
+and max-bw values and in case of max mode, configure only max-bw.
+
+* Attention
+Range-BW supports the predicable I/O bandwidth, but it should be
configured in the scope of total I/O bandwidth
+of the I/O system to guarantee the minimum I/O requirement. For
example, if total I/O bandwidth is 40Mbytes/sec,
+the summary of I/O bandwidth configured in each process group should
be equal or smaller than 40Mbytes/sec.
+So, we need to check total I/O bandwidth before set it up.
+
+2. Setup and Installation
+=========================
+
+This part is same with dm-ioband,
../../Documentation/device-mapper/ioband.txt or
+http://people.valinux.co.jp/~ryov/dm-ioband/manual/setup.html
+You must first install the appropriate bio-cgroup and dm-ioband
patches before using range-bw patch.
+
+3. Usage
+========
+
+It is very useful to refer the documentation for dm-ioband in
../../Documentation/device-mapper/ioband.txt or
+http://people.valinux.co.jp/~ryov/dm-ioband/, because Range-BW
follows the basic semantics of dm-ioband.
+This example is for min-max mode.
+
+# mount the cgroup
+mount -t cgroup -o bio none /root/cgroup/bio
+
+# create the process groups (3 groups)
+mkdir /root/cgroup/bio/bgroup1
+mkdir /root/cgroup/bio/bgroup2
+mkdir /root/cgroup/bio/bgroup3
+
+# create the ioband device ( name : ioband1 )
+echo "0 $(blockdev --getsize /dev/sdb2) ioband /dev/sdb2 1 0 0 none
+range-bw 0 :0" | dmsetup create ioband1
+: device name (/dev/sdb2) should be modified depending on your system
+
+# init ioband device ( type and policy )
+dmsetup message ioband1 0 type cgroup
+dmsetup message ioband1 0 policy range-bw
+
+# attach the groups to the ioband device
+dmsetup message ioband1 0 attach 2
+dmsetup message ioband1 0 attach 3
+dmsetup message ioband1 0 attach 4
+: group number can be referred in /root/cgroup/bio/bgroup1/bio.id
+
+# allocate the values ( min-bw and max-bw ) : XXX Kbytes
+: the sum of minimum I/O bandwidth in each group should be equal or
smaller than total bandwidth
+  to be supported by your system
+
+# range : about 100~500 Kbytes
+dmsetup message ioband1 0 min-bw 2:100
+dmsetup message ioband1 0 max-bw 2:500
+
+# range : about 700~1000 Kbytes
+dmsetup message ioband1 0 min-bw 3:700
+dmsetup message ioband1 0 max-bw 3:1000
+
+# range : about 50~60Mbytes
+dmsetup message ioband1 0 min-bw 4:50000
+dmsetup message ioband1 0 max-bw 4:60000
+
+You can confirm the configuration of range-bw by using this command :
+[root@localhost range-bw]# dmsetup table --target ioband
+ioband1: 0 305235000 ioband 8:18 1 4 128 cgroup range-bw 16384 :0
2:100:500 3:700:1000 4:30000:60000
+

-- 
Best Regards,
Dong-Jae Kang
