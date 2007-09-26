From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Add cgroup write_uint() helper method
Date: Tue, 25 Sep 2007 20:12:22 -0700
Message-ID: <46F9CE16.9080302__28726.9974746325$1190776522$gmane$org@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
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
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Add write_uint() helper method for cgroup subsystems

This helper is analagous to the read_uint() helper method for
reporting u64 values to userspace. It's designed to reduce the amount
of boilerplate requierd for creating new cgroup subsystems.

Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---
 include/linux/cgroup.h |    8 ++++++++
 kernel/cgroup.c        |   42 ++++++++++++++++++++++++++++++++++++++----
 2 files changed, 46 insertions(+), 4 deletions(-)

Index: container-2.6.23-rc8-mm1/include/linux/cgroup.h
===================================================================
--- container-2.6.23-rc8-mm1.orig/include/linux/cgroup.h
+++ container-2.6.23-rc8-mm1/include/linux/cgroup.h
@@ -196,6 +196,14 @@ struct cftype {
 	ssize_t (*write) (struct cgroup *cont, struct cftype *cft,
 			  struct file *file,
 			  const char __user *buf, size_t nbytes, loff_t *ppos);
+
+	/*
+	 * write_uint() is a shortcut for the common case of accepting
+	 * a single integer (as parsed by simple_strtoull) from
+	 * userspace. Use in place of write(); return 0 or error.
+	 */
+	int (*write_uint) (struct cgroup *cont, struct cftype *cft, u64 val);
+
 	int (*release) (struct inode *inode, struct file *file);
 };
 
Index: container-2.6.23-rc8-mm1/kernel/cgroup.c
===================================================================
--- container-2.6.23-rc8-mm1.orig/kernel/cgroup.c
+++ container-2.6.23-rc8-mm1/kernel/cgroup.c
@@ -1274,6 +1274,39 @@ enum cgroup_filetype {
 	FILE_RELEASE_AGENT,
 };
 
+static ssize_t cgroup_write_uint(struct cgroup *cont, struct cftype *cft,
+				 struct file *file,
+				 const char __user *userbuf,
+				 size_t nbytes, loff_t *unused_ppos)
+{
+	char buffer[64];
+	int retval = 0;
+	u64 val;
+	char *end;
+
+	if (!nbytes)
+		return -EINVAL;
+	if (nbytes >= sizeof(buffer))
+		return -E2BIG;
+	if (copy_from_user(buffer, userbuf, nbytes))
+		return -EFAULT;
+
+	buffer[nbytes] = 0;     /* nul-terminate */
+
+	/* strip newline if necessary */
+	if (nbytes && (buffer[nbytes-1] == '\n'))
+		buffer[nbytes-1] = 0;
+	val = simple_strtoull(buffer, &end, 0);
+	if (*end)
+		return -EINVAL;
+
+	/* Pass to subsystem */
+	retval = cft->write_uint(cont, cft, val);
+	if (!retval)
+		retval = nbytes;
+	return retval;
+}
+
 static ssize_t cgroup_common_file_write(struct cgroup *cont,
 					   struct cftype *cft,
 					   struct file *file,
@@ -1357,10 +1390,11 @@ static ssize_t cgroup_file_write(struct 
 
 	if (!cft)
 		return -ENODEV;
-	if (!cft->write)
-		return -EINVAL;
-
-	return cft->write(cont, cft, file, buf, nbytes, ppos);
+	if (cft->write)
+		return cft->write(cont, cft, file, buf, nbytes, ppos);
+	if (cft->write_uint)
+		return cgroup_write_uint(cont, cft, file, buf, nbytes, ppos);
+	return -EINVAL;
 }
 
 static ssize_t cgroup_read_uint(struct cgroup *cont, struct cftype *cft,
