From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH -mm] cgroups: fix failure path in cgroup_write_event_control()
Date: Wed, 24 Feb 2010 11:22:27 +0800
Message-ID: <4B849B73.1040106@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Menage <menage@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

How to reproduce:

  # mount -t cgroup -o memory xxx /cgroup
  # mkdir /cgroup/tmp
  # ./cgroup_event_listener /cgroup/tmp/cgroup.event_control abc
  ^C
  # rmdir /cgroup/tmp
  # cat /proc/cgroups | grep memory
  memory  2       2       1         (should be "2 1 1")
  # umount /cgroup
  (failed!)

Using a single goto label to cleanup multi failure paths can
get things wrong quite easily, while multi labels makes the
code cleaner.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 cgroup.c |   39 ++++++++++++++++++---------------------
 1 file changed, 18 insertions(+), 21 deletions(-)

diff --git a/kernel/cgroup.c.orig b/kernel/cgroup.c
index d142524..6ff40f6 100644
--- a/kernel/cgroup.c.orig
+++ b/kernel/cgroup.c
@@ -3029,10 +3029,10 @@ static void cgroup_event_ptable_queue_proc(struct file *file,
 static int cgroup_write_event_control(struct cgroup *cgrp, struct cftype *cft,
 				      const char *buffer)
 {
-	struct cgroup_event *event = NULL;
+	struct cgroup_event *event;
 	unsigned int efd, cfd;
-	struct file *efile = NULL;
-	struct file *cfile = NULL;
+	struct file *efile;
+	struct file *cfile;
 	char *endp;
 	int ret;
 
@@ -3058,46 +3058,46 @@ static int cgroup_write_event_control(struct cgroup *cgrp, struct cftype *cft,
 	efile = eventfd_fget(efd);
 	if (IS_ERR(efile)) {
 		ret = PTR_ERR(efile);
-		goto fail;
+		goto out_free_event;
 	}
 
 	event->eventfd = eventfd_ctx_fileget(efile);
 	if (IS_ERR(event->eventfd)) {
 		ret = PTR_ERR(event->eventfd);
-		goto fail;
+		goto out_put_efile;
 	}
 
 	cfile = fget(cfd);
 	if (!cfile) {
 		ret = -EBADF;
-		goto fail;
+		goto out_put_eventfd;
 	}
 
 	/* the process need read permission on control file */
 	ret = file_permission(cfile, MAY_READ);
 	if (ret < 0)
-		goto fail;
+		goto out;
 
 	event->cft = __file_cft(cfile);
 	if (IS_ERR(event->cft)) {
 		ret = PTR_ERR(event->cft);
-		goto fail;
+		goto out;
 	}
 
 	if (!event->cft->register_event || !event->cft->unregister_event) {
 		ret = -EINVAL;
-		goto fail;
+		goto out;
 	}
 
 	ret = event->cft->register_event(cgrp, event->cft,
 			event->eventfd, buffer);
 	if (ret)
-		goto fail;
+		goto out;
 
 	if (efile->f_op->poll(efile, &event->pt) & POLLHUP) {
 		event->cft->unregister_event(cgrp, event->cft, event->eventfd);
 		ret = 0;
-		goto fail;
+		goto out;
 	}
 
 	/*
@@ -3116,16 +3116,13 @@ static int cgroup_write_event_control(struct cgroup *cgrp, struct cftype *cft,
 
 	return 0;
 
-fail:
-	if (!cfile)
-		fput(cfile);
-
-	if (event && event->eventfd && !IS_ERR(event->eventfd))
-		eventfd_ctx_put(event->eventfd);
-
-	if (!IS_ERR_OR_NULL(efile))
-		fput(efile);
-
+out:
+	fput(cfile);
+out_put_eventfd:
+	eventfd_ctx_put(event->eventfd);
+out_put_efile:
+	fput(efile);
+out_free_event:
 	kfree(event);
 
 	return ret;
