From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH RFC] Define CAP_SYSLOG
Date: Fri, 5 Mar 2010 14:56:07 -0600
Message-ID: <20100305205607.GA31791@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
To: linux-security-module@vger.kernel.org
Cc: Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Privileged syslog operations currently require CAP_SYS_ADMIN.  Split
this off into a new CAP_SYSLOG privilege which we can sanely take away
from a container through the capability bounding set.

With this patch, an lxc container can be prevented from messing with
the host's syslog.

There is one downside to this patch:  If some site or distro currently
has syslogd/whatever running as a non-root user with cap_sys_admin+pe,
then it will need to be changed to run with cap_syslog+pe.  I don't
know if there are such sites, or if that concern means we should take
a different approach to introducing this change, or simply refuse this
change.

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
---
 include/linux/capability.h |    7 +++++--
 security/commoncap.c       |    2 +-
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/linux/capability.h b/include/linux/capability.h
index 39e5ff5..837a55c 100644
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -249,7 +249,6 @@ struct cpu_vfs_cap_data {
 /* Allow configuration of the secure attention key */
 /* Allow administration of the random device */
 /* Allow examination and configuration of disk quotas */
-/* Allow configuring the kernel's syslog (printk behaviour) */
 /* Allow setting the domainname */
 /* Allow setting the hostname */
 /* Allow calling bdflush() */
@@ -355,7 +354,11 @@ struct cpu_vfs_cap_data {
 
 #define CAP_MAC_ADMIN        33
 
-#define CAP_LAST_CAP         CAP_MAC_ADMIN
+/* Allow configuring the kernel's syslog (printk behaviour) */
+
+#define CAP_SYSLOG           34
+
+#define CAP_LAST_CAP         CAP_SYSLOG
 
 #define cap_valid(x) ((x) >= 0 && (x) <= CAP_LAST_CAP)
 
diff --git a/security/commoncap.c b/security/commoncap.c
index 6166973..018985e 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -899,7 +899,7 @@ int cap_syslog(int type, bool from_file)
 	if (type != SYSLOG_ACTION_OPEN && from_file)
 		return 0;
 	if ((type != SYSLOG_ACTION_READ_ALL &&
-	     type != SYSLOG_ACTION_SIZE_BUFFER) && !capable(CAP_SYS_ADMIN))
+	     type != SYSLOG_ACTION_SIZE_BUFFER) && !capable(CAP_SYSLOG))
 		return -EPERM;
 	return 0;
 }
-- 
1.6.1

