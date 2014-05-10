From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH V2 3/6] namespaces: expose namespace instance serial number in
	proc_ns_operations
Date: Fri,  9 May 2014 20:27:24 -0400
Message-ID: <7fcf5794689302e990b3f4aa73b72968eec72295.1399681022.git.rgb@redhat.com>
References: <cover.1399681022.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1399681022.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <cover.1399681022.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
References: <cover.1399681022.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Expose the namespace instance serial number for each namespace type in the proc
namespace operations structure to make it available for the proc filesystem.

Signed-off-by: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 fs/namespace.c           |    7 +++++++
 include/linux/proc_ns.h  |    1 +
 ipc/namespace.c          |    8 ++++++++
 kernel/pid_namespace.c   |    7 +++++++
 kernel/user_namespace.c  |    7 +++++++
 kernel/utsname.c         |    8 ++++++++
 net/core/net_namespace.c |    7 +++++++
 7 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index b4a31aa..69d269f 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -3014,6 +3014,12 @@ static unsigned int mntns_inum(void *ns)
 	return mnt_ns->proc_inum;
 }
 
+static unsigned long long mntns_snum(void *ns)
+{
+	struct mnt_namespace *mnt_ns = ns;
+	return mnt_ns->serial_num;
+}
+
 const struct proc_ns_operations mntns_operations = {
 	.name		= "mnt",
 	.type		= CLONE_NEWNS,
@@ -3021,4 +3027,5 @@ const struct proc_ns_operations mntns_operations = {
 	.put		= mntns_put,
 	.install	= mntns_install,
 	.inum		= mntns_inum,
+	.snum		= mntns_snum,
 };
diff --git a/include/linux/proc_ns.h b/include/linux/proc_ns.h
index 34a1e10..aebb3a2 100644
--- a/include/linux/proc_ns.h
+++ b/include/linux/proc_ns.h
@@ -14,6 +14,7 @@ struct proc_ns_operations {
 	void (*put)(void *ns);
 	int (*install)(struct nsproxy *nsproxy, void *ns);
 	unsigned int (*inum)(void *ns);
+	unsigned long long (*snum)(void *ns);
 };
 
 struct proc_ns {
diff --git a/ipc/namespace.c b/ipc/namespace.c
index 76dac5c..0669c2d 100644
--- a/ipc/namespace.c
+++ b/ipc/namespace.c
@@ -191,6 +191,13 @@ static unsigned int ipcns_inum(void *vp)
 	return ns->proc_inum;
 }
 
+static unsigned long long ipcns_snum(void *vp)
+{
+	struct ipc_namespace *ns = vp;
+
+	return ns->serial_num;
+}
+
 const struct proc_ns_operations ipcns_operations = {
 	.name		= "ipc",
 	.type		= CLONE_NEWIPC,
@@ -198,4 +205,5 @@ const struct proc_ns_operations ipcns_operations = {
 	.put		= ipcns_put,
 	.install	= ipcns_install,
 	.inum		= ipcns_inum,
+	.snum		= ipcns_snum,
 };
diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index c24f207..1dd2eb2 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -368,6 +368,12 @@ static unsigned int pidns_inum(void *ns)
 	return pid_ns->proc_inum;
 }
 
+static unsigned long long pidns_snum(void *ns)
+{
+	struct pid_namespace *pid_ns = ns;
+	return pid_ns->serial_num;
+}
+
 const struct proc_ns_operations pidns_operations = {
 	.name		= "pid",
 	.type		= CLONE_NEWPID,
@@ -375,6 +381,7 @@ const struct proc_ns_operations pidns_operations = {
 	.put		= pidns_put,
 	.install	= pidns_install,
 	.inum		= pidns_inum,
+	.snum		= pidns_snum,
 };
 
 static __init int pid_namespaces_init(void)
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 750241c..0b1ba1c 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -890,6 +890,12 @@ static unsigned int userns_inum(void *ns)
 	return user_ns->proc_inum;
 }
 
+static unsigned long long userns_snum(void *ns)
+{
+	struct user_namespace *user_ns = ns;
+	return user_ns->serial_num;
+}
+
 const struct proc_ns_operations userns_operations = {
 	.name		= "user",
 	.type		= CLONE_NEWUSER,
@@ -897,6 +903,7 @@ const struct proc_ns_operations userns_operations = {
 	.put		= userns_put,
 	.install	= userns_install,
 	.inum		= userns_inum,
+	.snum		= userns_snum,
 };
 
 static __init int user_namespaces_init(void)
diff --git a/kernel/utsname.c b/kernel/utsname.c
index d0cf7b5..c8ca860 100644
--- a/kernel/utsname.c
+++ b/kernel/utsname.c
@@ -132,6 +132,13 @@ static unsigned int utsns_inum(void *vp)
 	return ns->proc_inum;
 }
 
+static unsigned long long utsns_snum(void *vp)
+{
+	struct uts_namespace *ns = vp;
+
+	return ns->serial_num;
+}
+
 const struct proc_ns_operations utsns_operations = {
 	.name		= "uts",
 	.type		= CLONE_NEWUTS,
@@ -139,4 +146,5 @@ const struct proc_ns_operations utsns_operations = {
 	.put		= utsns_put,
 	.install	= utsns_install,
 	.inum		= utsns_inum,
+	.snum		= utsns_snum,
 };
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index e0b8528..e16dc0e 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -667,6 +667,12 @@ static unsigned int netns_inum(void *ns)
 	return net->proc_inum;
 }
 
+static unsigned long long netns_snum(void *ns)
+{
+	struct net *net = ns;
+	return net->serial_num;
+}
+
 const struct proc_ns_operations netns_operations = {
 	.name		= "net",
 	.type		= CLONE_NEWNET,
@@ -674,5 +680,6 @@ const struct proc_ns_operations netns_operations = {
 	.put		= netns_put,
 	.install	= netns_install,
 	.inum		= netns_inum,
+	.snum		= netns_snum,
 };
 #endif
-- 
1.7.1
