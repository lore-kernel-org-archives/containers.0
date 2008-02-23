From: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 02/10] CGroup API files: Add res_counter_read_u64()
Date: Sat, 23 Feb 2008 14:47:27 -0800
Message-ID: <20080223232617.472024000__34831.0905545533$1203809920$gmane$org@menage.corp.google.com>
References: <20080223224725.115590000@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=resource_counter_read_uint.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, balbir-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, pj-sJ/iWh9BUns@public.gmane.org, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, YAMAMOTO
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Adds a function for returning the value of a resource counter member,
in a form suitable for use in a cgroup read_u64 control file method.

Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---
 include/linux/res_counter.h |    5 ++++-
 kernel/res_counter.c        |    5 +++++
 2 files changed, 9 insertions(+), 1 deletion(-)

Index: cgroup-2.6.25-rc2-mm1/include/linux/res_counter.h
===================================================================
--- cgroup-2.6.25-rc2-mm1.orig/include/linux/res_counter.h
+++ cgroup-2.6.25-rc2-mm1/include/linux/res_counter.h
@@ -39,8 +39,9 @@ struct res_counter {
 	spinlock_t lock;
 };
 
-/*
+/**
  * Helpers to interact with userspace
+ * res_counter_read_u64() - returns the value of the specified member.
  * res_counter_read/_write - put/get the specified fields from the
  * res_counter struct to/from the user
  *
@@ -51,6 +52,8 @@ struct res_counter {
  * @pos:     and the offset.
  */
 
+u64 res_counter_read_u64(struct res_counter *counter, int member);
+
 ssize_t res_counter_read(struct res_counter *counter, int member,
 		const char __user *buf, size_t nbytes, loff_t *pos,
 		int (*read_strategy)(unsigned long long val, char *s));
Index: cgroup-2.6.25-rc2-mm1/kernel/res_counter.c
===================================================================
--- cgroup-2.6.25-rc2-mm1.orig/kernel/res_counter.c
+++ cgroup-2.6.25-rc2-mm1/kernel/res_counter.c
@@ -92,6 +92,11 @@ ssize_t res_counter_read(struct res_coun
 			pos, buf, s - buf);
 }
 
+u64 res_counter_read_u64(struct res_counter *counter, int member)
+{
+	return *res_counter_member(counter, member);
+}
+
 ssize_t res_counter_write(struct res_counter *counter, int member,
 		const char __user *userbuf, size_t nbytes, loff_t *pos,
 		int (*write_strategy)(char *st_buf, unsigned long long *val))

--
