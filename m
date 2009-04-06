From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] stop rootless containers from messing with host mounts
Date: Mon, 6 Apr 2009 16:27:24 -0500
Message-ID: <20090406212724.GA30355@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

If a container has no root, lxc still remounts /proc.  If the
system had marked / as MS_SHARED, as is the case in Fedora 11,
then even though the container is in a new mounts namespace, the
mount event is propagated back to the host mounts ns, overmounting
the host's /proc.  After that, ps -ef will no longer show host
processes for a host admin.

So mark / as MS_SLAVE in a container after spawning a new mounts
namespace, and before actually chrooting.  This way the container
will still receive mount events from the host.

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 src/lxc/conf.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/src/lxc/conf.c b/src/lxc/conf.c
index 6c3476a..d807ae3 100644
--- a/src/lxc/conf.c
+++ b/src/lxc/conf.c
@@ -60,6 +60,10 @@
 #define MS_REC 16384
 #endif
 
+#ifndef MS_SLAVE
+#define MS_SLAVE 1<<19
+#endif
+
 typedef int (*instanciate_cb)(const char *directory,
 			      const char *file, pid_t pid);
 
@@ -1847,6 +1851,12 @@ int lxc_setup(const char *name, const char *cons,
 		return -LXC_ERROR_SETUP_TTY;
 	}
 
+	/* Make sure we don't end up forwarding mount events back to parent */
+	if (mount("", "/", NULL, MS_SLAVE|MS_REC, NULL) < 0) {
+		lxc_log_error("Failed to set host / as slave for '%s'", name);
+		return -LXC_ERROR_SETUP_ROOTFS;
+	}
+
 	if (conf_is_set(flags, rootfs) && setup_rootfs(name)) {
 		lxc_log_error("failed to set rootfs for '%s'", name);
 		return -LXC_ERROR_SETUP_ROOTFS;
-- 
1.6.2
