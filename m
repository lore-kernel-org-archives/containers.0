From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: [PATCH 9/9] blkio-cgroup-v13: The document of a cgroup support for
	dm-ioband
Date: Fri, 02 Oct 2009 20:59:30 +0900 (JST)
Message-ID: <20091002.205930.59680180.ryov__13613.1804822528$1254484938$gmane$org@valinux.co.jp>
References: <20091002.205817.112597159.ryov@valinux.co.jp>
	<20091002.205843.183050041.ryov@valinux.co.jp>
	<20091002.205904.39183199.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091002.205904.39183199.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org
List-Id: containers.vger.kernel.org

The document of a cgroup support for dm-ioband.

Signed-off-by: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Signed-off-by: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>

---
 Documentation/cgroups/blkio.txt |  314 +++++++++++++++++++++++++++++++++++++++-
 1 file changed, 313 insertions(+), 1 deletion(-)

Index: linux-2.6.32-rc1/Documentation/cgroups/blkio.txt
===================================================================
--- linux-2.6.32-rc1.orig/Documentation/cgroups/blkio.txt
+++ linux-2.6.32-rc1/Documentation/cgroups/blkio.txt
@@ -11,6 +11,9 @@ I/O with a little enhancement.
 
 2. Setting up blkio-cgroup
 
+Note: If dm-ioband is to be used with blkio-cgroup, then the dm-ioband
+patch needs to be applied first.
+
 The following kernel config options are required.
 
 CONFIG_CGROUPS=y
@@ -43,7 +46,316 @@ determined by retrieving the ID number f
 the page cgroup is associated with the page which is involved in the
 I/O.
 
-4. Contact
+If the dm-ioband support patch was applied then the blkio.devices and
+blkio.settings files will also be present.
+
+4. Using dm-ioband and blkio-cgroup
+
+This section describes how to set up dm-ioband and blkio-cgroup in
+order to control bandwidth on a per cgroup per logical volume basis.
+The example used in this section assumes that there are two LVM volume
+groups on individual hard disks and two logical volumes on each volume
+group.
+
+                         Table. LVM configurations
+
+     --------------------------------------------------------------
+    |   LVM volume group   |  vg0 on /dev/sda  |  vg1 on /dev/sdb  |
+    |----------------------+-------------------+-------------------|
+    |  LVM logical volume  |   lv0   |   lv1   |   lv0   |   lv1   |
+     --------------------------------------------------------------
+
+4.1. Creating a dm-ioband logical device
+
+A dm-ioband logical device needs to be created and stacked on the
+device that is to bandwidth controlled. In this example the dm-ioband
+logical devices are stacked on each of the existing LVM logical
+volumes. By using the LVM facilities there is no need to unmount any
+logical volumes, even in the case of a volume being used as the root
+device. The following script is an example of how to stack and remove
+dm-ioband devices.
+
+==================== cut here (ioband.sh) ====================
+#!/bin/sh
+#
+# NOTE: You must run "ioband.sh stop" to restore the device-mapper
+# settings before changing logical volume settings, such as activate,
+# rename, resize and so on. These constraints would be eliminated by
+# enhancing LVM tools to support dm-ioband.
+
+logvols="vg0-lv0 vg0-lv1 vg1-lv0 vg1-lv1"
+
+start()
+{
+	for lv in $logvols; do
+		volgrp=${lv%%-*}
+		orig=${lv}-orig
+
+		# clone an existing logical volume.
+		/sbin/dmsetup table $lv | /sbin/dmsetup create $orig
+
+		# stack a dm-ioband device on the clone.
+		size=$(/sbin/blockdev --getsize /dev/mapper/$orig)
+		cat<<-EOM | /sbin/dmsetup load ${lv}
+	0 $size ioband /dev/mapper/${orig} ${volgrp} 0 0 cgroup weight 0 :100
+		EOM
+
+		# activate the new setting.
+		/sbin/dmsetup resume $lv
+	done
+}
+
+stop()
+{
+	for lv in $logvols; do
+		orig=${lv}-orig
+
+		# restore the original setting.
+		/sbin/dmsetup table $orig | /sbin/dmsetup load $lv
+
+		# activate the new setting.
+		/sbin/dmsetup resume $lv
+
+		# remove the clone.
+		/sbin/dmsetup remove $orig
+	done
+}
+
+case "$1" in
+	start)
+		start
+        ;;
+	stop)
+		stop
+        ;;
+esac
+exit 0
+==================== cut here (ioband.sh) ====================
+
+The following diagram shows how dm-ioband devices are stacked on and
+removed from the logical volumes.
+
+           Figure. stacking and removing dm-ioband devices
+
+                     run "ioband.sh start"
+                              ===>
+
+     -----------------------        -----------------------
+    |    lv0    |    lv1    |      |    lv0    |    lv1    |
+    |(dm-linear)|(dm-linear)|      |(dm-ioband)|(dm-ioband)|
+    |-----------------------|      |-----------+-----------|
+    |         vg0           |      | lv0-orig  | lv1-orig  |
+     -----------------------       |(dm-linear)|(dm-linear)|
+                                   |-----------------------|
+                                   |          vg0          |
+                                    -----------------------
+                              <===
+                      run "ioband.sh stop"
+
+After creating the dm-ioband devices, the settings can be observed by
+reading the blkio.devices file.
+
+# cat /cgroup/blkio.devices
+vg0 policy=weight io_throttle=4 io_limit=192 token=768 carryover=2
+  vg0-lv0
+  vg0-lv1
+vg1 policy=weight io_throttle=4 io_limit=192 token=768 carryover=2
+  vg1-lv0
+  vg1-lv1
+
+The first field in the first line is the symbolic name for an ioband
+device group, and the subsequent fields are settings for the ioband
+device group. The settings can be changed by writing to the
+blkio.devices, for example:
+
+# echo vg1 policy range-bw > /cgroup/blkio.devices
+
+Please refer to Document/device-mapper/ioband.txt which describes the
+details of the ioband device group settings.
+
+The second and the third indented lines "vg0-lv0" and "vg0-lv1" are
+the names of the dm-ioband devices that belong to the ioband device
+group. Typically, dm-ioband devices that reside on the same hard disk
+should belong to the same ioband device group in order to share the
+bandwidth of the hard disk.
+
+dm-ioband is not restricted to working with LVM, it may work in
+conjunction with any type of block device. Please refer to
+Documentation/device-mapper/ioband.txt for more details.
+
+4.2 Setting up dm-ioband through the blkio-cgroup interface
+
+The following table shows the given settings for this example. The
+bandwidth will be assigned on a per cgroup per logical volume basis.
+
+                   Table. Settings for each cgroup
+
+     --------------------------------------------------------------
+    |   LVM volume group   |  vg0 on /dev/sda  |  vg1 on /dev/sdb  |
+    |----------------------+-------------------+-------------------|
+    |  LVM logical volume  |   lv0   |   lv1   |   lv0   |   lv1   |
+    |----------------------+-------------------+-------------------|
+    |   bandwidth control  |     relative      |     absolute      |
+    |        policy        |      weight       |  bandwidth limit  |
+    |----------------------+-------------------+-------------------|
+    |         unit         |     weight [%]    | throughput [KB/s] |
+    |----------------------+-------------------+-------------------|
+    | settings for cgroup1 |    30   |    50   |   400   |   900   |
+    |----------------------+---------+---------+---------+---------|
+    | settings for cgroup2 |    60   |    20   |   200   |   600   |
+    |----------------------+---------+---------+---------+---------|
+    |    for root cgroup   |    70   |    30   |   100   |   300   |
+     --------------------------------------------------------------
+
+The set-up is described step-by-step below.
+
+1) Create new cgroups using the mkdir command
+
+# mkdir /cgroup/1
+# mkdir /cgroup/2
+
+2) Set bandwidth control policy on each ioband device group
+
+The set-up of bandwidth control policy is done by writing to
+blkio.devices file.
+
+# echo vg0 policy weight > /cgroup/blkio.devices
+# echo vg1 policy range-bw > /cgroup/blkio.devices
+
+3) Set up the root cgroup
+
+The root cgroup represents the default blkio-cgroup. If an I/O is
+performed by a process in a cgroup and the cgroup is not set up by
+blkio-cgroup, the I/O is charged to the root cgroup.
+
+The set-up of the root cgroup is done by writing to blkio.settings
+file in the cgroup's root directory. The following commands write
+the settings of each logical volume to that file.
+
+# echo vg0-lv0 70 > /cgroup/bklio.settings
+# echo vg0-lv1 30 > /cgroup/bklio.settings
+# echo vg1-lv0 100:100 > /cgroup/blkio.settings
+# echo vg1-lv1 300:300 > /cgroup/blkio.settings
+
+The settings can be verified by reading the blkio.settings file. The
+first field is the symbolic name for an ioband device group, and the
+second field is an ioband device name. The following example shows
+that vg0-lv0 and vg0-lv1 belong to the same ioband device group and
+share the bandwidth of sda according to their weights.
+
+# cat /cgroup/blkio.settings
+sda vg0-lv0 weight=70%
+sda vg0-lv1 weight=30%
+sdb vg1-lv0 range-bw=100:100
+sdb vg1-lv1 range-bw=300:300
+
+4) Set up cgroup1 and cgroup2
+
+New cgroups are set up in the same manner as the root cgroup.
+
+Settings for cgroup1
+# echo vg0-lv0 30 > /cgroup/1/blkio.settings
+# echo vg0-lv1 50 > /cgroup/1/bklio.settings
+# echo vg1-lv0 400:400 > /cgroup/1/blkio.settings
+# echo vg1-lv1 900:900 > /cgroup/1/bklio.settings
+
+Settings for cgroup2
+# echo vg0-lv0 60 > /cgroup/2/blkio.settings
+# echo vg0-lv1 20 > /cgroup/2/bklio.settings
+# echo vg1-lv0 200:200 > /cgroup/2/blkio.settings
+# echo vg1-lv1 600:600 > /cgroup/2/bklio.settings
+
+Again, the settings can be verified by reading the appropriate
+blkio.settings file.
+
+# cat /cgroup/1/blkio.settings
+vg0-lv0 weight=30%
+vg0-lv1 weight=50%
+vg1-lv0 range-bw=400:400
+vg1-lv1 range-bw=900:900
+
+If only the logical volume name is specified, the entry for the
+logical volume is removed.
+
+# echo vg0-lv1 > /cgroup/1/vlkio.setting
+# cat /cgroup/1/blkio.settings
+vg0-lv0 weight=30%
+vg0-lv1 weight=50%
+vg1-lv0 range-bw=400:400
+
+4.3 How bandwidth is distributed in the weight policy.
+
+The weight policy assigns bandwidth proportional to the weight of each
+cgroup in a hierarchical manner. The bandwidth assigned to a parent
+cgroup is distributed among the parent and its children according to
+their weight. For example, if there are two child cgroups under the
+parent cgroup, cgroup1 is assigned 60% of the parent bandwidth, and
+cgroup2 is assigned 30%, then 10% (100% - 60% + 30%) remains for the
+parent cgroup.
+
+        Figure. bandwidth distribution among a parent and children
+
+                    (100% - 30% - 60% = 10%)
+                            parent
+                           /      \
+                       cgroup1    cgroup2
+                        (30%)      (60%)
+
+The followings show how the bandwidth is calculated ans assigned to
+each cgroup in the given settings which are shown above.
+
+           Figure. hierarchical settings by the weight policy
+
+                (70%)  ---  /dev/sda ---  (30%)
+
+               vg0/lv0                   vg0/lv1
+
+                (10%)                     (30%)
+             root(parent)              root(parent)
+              /      \                  /      \
+          cgroup1    cgroup2        cgroup1    cgroup2
+           (30%)      (60%)          (50%)      (20%)
+
+
+             Table. actual bandwidth assigned to each cgroup
+
+        ------------------------------------------------------------
+       |          |         | weight     | actual bandwidth         |
+       | shared   | logical | for a root | assigned to each cgroup  |
+       | device   | volume  | group      | against /dev/sda         |
+       |----------+---------+------------+--------------------------|
+       |          |         |            | parent   70% * 10% =  7% |
+       |          | vg0/lv0 |     70%    | cgroup1  70% * 30% = 21% |
+       |          |         |            | cgroup2  70% * 60% = 42% |
+       | /dev/sda |---------+------------+--------------------------|
+       |          |         |            | parent   30% * 30% =  9% |
+       |          | vg1/lv1 |     30%    | cgroup1  30% * 50% = 15% |
+       |          |         |            | cgruop2  30% * 20% =  6% |
+        ------------------------------------------------------------
+
+4.4 Getting IO statistics per cgroup.
+
+The blkio.stats file provides IO statistics per dm-ioband per cgroup.
+This file consists of 12 fields separated by whitespace. The format is
+almost the same as /proc/diskstats and /sys/block/dev/stat files, but
+some fields are reserved for future use and they always return 0.
+
+Field #   Name            units         description
+-------   ----            -----         -----------
+1         device name                   name of dm-ioband device
+2         read I/Os       requests      number of read I/Os processed
+3                                       *reserved*
+4         read sectors    sectors       number of sectors read
+5                                       *reserved*
+6         write I/Os      requests      number of write I/Os processed
+7                                       *reserved*
+8         write sectors   sectors       number of sectors written
+9                                       *reserved*
+10        in_flight       requests      number of I/Os currently in flight
+11                                      *reserved*
+12                                      *reserved*
+
+5. Contact
 
 Linux Block I/O Bandwidth Control Project
 http://sourceforge.net/projects/ioband/
