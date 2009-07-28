From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: [PATCH 5/7] blkio-cgroup-v10: The document of blkio-cgroup
Date: Tue, 28 Jul 2009 21:19:22 +0900 (JST)
Message-ID: <20090728.211922.189712796.ryov__6189.74165195159$1248783611$gmane$org@valinux.co.jp>
References: <20090728.211754.226789461.ryov@valinux.co.jp>
	<20090728.211820.71102079.ryov@valinux.co.jp>
	<20090728.211850.104046372.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090728.211850.104046372.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
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

The document of blkio-cgroup.

Signed-off-by: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Signed-off-by: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>

---
 Documentation/cgroups/00-INDEX  |    2 
 Documentation/cgroups/blkio.txt |  289 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 291 insertions(+)

Index: linux-2.6.31-rc3-mm1/Documentation/cgroups/00-INDEX
===================================================================
--- linux-2.6.31-rc3-mm1.orig/Documentation/cgroups/00-INDEX
+++ linux-2.6.31-rc3-mm1/Documentation/cgroups/00-INDEX
@@ -16,3 +16,5 @@ memory.txt
 	- Memory Resource Controller; design, accounting, interface, testing.
 resource_counter.txt
 	- Resource Counter API.
+blkio.txt
+	- Block I/O Tracking; description, interface and examples.
Index: linux-2.6.31-rc3-mm1/Documentation/cgroups/blkio.txt
===================================================================
--- /dev/null
+++ linux-2.6.31-rc3-mm1/Documentation/cgroups/blkio.txt
@@ -0,0 +1,289 @@
+Block I/O Cgroup
+
+1. Overview
+
+Using this feature the owners of any type of I/O can be determined.
+This allows dm-ioband to control block I/O bandwidth even when it is
+accepting delayed write requests. dm-ioband can find the cgroup of
+each request. It is also for possible that others working on I/O
+bandwidth throttling to use this functionality to control asynchronous
+I/O with a little enhancement.
+
+2. Setting up blkio-cgroup
+
+Note: If dm-ioband is to be used with blkio-cgroup, then the dm-ioband
+patch needs to be applied first.
+
+The following kernel config options are required.
+
+CONFIG_CGROUPS=y
+CONFIG_CGROUP_BLKIO=y
+
+Selecting the options for the cgroup memory subsystem is also recommended
+as it makes it possible to give some I/O bandwidth and memory to a selected
+cgroup to control delayed write requests. The amount of dirty pages is
+limited within the cgroup even if the allocated bandwidth is narrow.
+
+CONFIG_RESOURCE_COUNTERS=y
+CONFIG_CGROUP_MEM_RES_CTLR=y
+
+3. User interface
+
+3.1 Mounting the cgroup filesystem
+
+First, mount the cgroup filesystem in order to enable observation and
+modification of the blkio-cgroup settings.
+
+# mount -t cgroup -o blkio none /cgroup
+
+3.2 The blkio.id file
+
+After mounting the cgroup filesystem the blkio.id file will be visible
+in the cgroup directory. This file contains a unique ID number for
+each cgroup. When an I/O operation starts, blkio-cgroup sets the
+page's ID number on the page cgroup. The cgroup of I/O can be
+determined by retrieving the ID number from the page cgroup, because
+the page cgroup is associated with the page which is involved in the
+I/O.
+
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
+    |   LVM volume groups  |  vg0 on /dev/sda  |  vg1 on /dev/sdb  |
+    |----------------------|-------------------|-------------------|
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
+    |-----------------------|      |-----------------------|
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
+    |   LVM volume groups  |  vg0 on /dev/sda  |  vg1 on /dev/sdb  |
+    |----------------------|-------------------|-------------------|
+    |  LVM logical volume  |   lv0   |   lv1   |   lv0   |   lv1   |
+    |----------------------|-------------------|-------------------|
+    |   bandwidth control  |     relative      |     absolute      |
+    |        policy        |      weight       |  bandwidth limit  |
+    |----------------------|-------------------|-------------------|
+    |         unit         | weight value (*1) | throughput [KB/s] |
+    |----------------------|-------------------|-------------------|
+    | settings for cgroup1 | 40 (16) | 90 (36) |   400   |   900   |
+    |----------------------|---------|---------|---------|---------|
+    | settings for cgroup2 | 20  (8) | 60 (24) |   200   |   600   |
+    |----------------------|---------|---------|---------|---------|
+    |   for other cgroups  | 10  (4) | 30 (12) |   100   |   300   |
+     --------------------------------------------------------------
+
+        *1: The values enclosed in () denote the preceding weight
+            as a percentage of the total weight. The bandwidth of
+            vg0 is distributed proportional to the total weight.
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
+# echo vg0-lv0 10 > /cgroup/bklio.settings
+# echo vg0-lv1 30 > /cgroup/bklio.settings
+# echo vg1-lv0 100:100 > /cgroup/blkio.settings
+# echo vg1-lv1 300:300 > /cgroup/blkio.settings
+
+The settings can be verified by reading the blkio.settings file.
+
+# cat /cgroup/blkio.settings
+vg0-lv0 weight=10
+vg0-lv1 weight=30
+vg1-lv0 range-bw=100:100
+vg1-lv1 range-bw=300:300
+
+4) Set up cgroup1 and cgroup2
+
+New cgroups are set up in the same manner as the root cgroup.
+
+Settings for cgroup1
+# echo vg0-lv0 40 > /cgroup/1/blkio.settings
+# echo vg0-lv1 90 > /cgroup/1/bklio.settings
+# echo vg1-lv0 400:400 > /cgroup/1/blkio.settings
+# echo vg1-lv1 900:900 > /cgroup/1/bklio.settings
+
+Settings for cgroup2
+# echo vg0-lv0 20 > /cgroup/2/blkio.settings
+# echo vg0-lv1 60 > /cgroup/2/bklio.settings
+# echo vg1-lv0 200:200 > /cgroup/2/blkio.settings
+# echo vg1-lv1 600:600 > /cgroup/2/bklio.settings
+
+Again, the settings can be verified by reading the appropriate
+blkio.settings file.
+
+# cat /cgroup/1/blkio.settings
+vg0-lv0 weight=40
+vg0-lv1 weight=90
+vg1-lv0 range-bw=400:400
+vg1-lv1 range-bw=900:900
+
+If only the logical volume name is specified, the entry for the
+logical volume is removed.
+
+# echo vg0-lv1 > /cgroup/1/vlkio.setting
+# cat /cgroup/1/blkio.settings
+vg0-lv0 weight=40
+vg0-lv1 weight=90
+vg1-lv0 range-bw=400:400
+
+5. Contact
+
+Linux Block I/O Bandwidth Control Project
+http://sourceforge.net/projects/ioband/
