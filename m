From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: [PATCH 7/9] blkio-cgroup-v13: The document of blkio-cgroup
Date: Fri, 02 Oct 2009 20:58:43 +0900 (JST)
Message-ID: <20091002.205843.183050041.ryov__2070.72232519767$1254484771$gmane$org@valinux.co.jp>
References: <20091002.205725.104059507.ryov@valinux.co.jp>
	<20091002.205748.189700030.ryov@valinux.co.jp>
	<20091002.205817.112597159.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091002.205817.112597159.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
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
 Documentation/cgroups/00-INDEX  |    2 +
 Documentation/cgroups/blkio.txt |   49 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 51 insertions(+)

Index: linux-2.6.32-rc1/Documentation/cgroups/00-INDEX
===================================================================
--- linux-2.6.32-rc1.orig/Documentation/cgroups/00-INDEX
+++ linux-2.6.32-rc1/Documentation/cgroups/00-INDEX
@@ -16,3 +16,5 @@ memory.txt
 	- Memory Resource Controller; design, accounting, interface, testing.
 resource_counter.txt
 	- Resource Counter API.
+blkio.txt
+	- Block I/O Tracking; description, interface and examples.
Index: linux-2.6.32-rc1/Documentation/cgroups/blkio.txt
===================================================================
--- /dev/null
+++ linux-2.6.32-rc1/Documentation/cgroups/blkio.txt
@@ -0,0 +1,49 @@
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
+4. Contact
+
+Linux Block I/O Bandwidth Control Project
+http://sourceforge.net/projects/ioband/
