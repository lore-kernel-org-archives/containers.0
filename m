From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 1/1][RFC] do not sys_reboot when not in init_pid_ns
Date: Sun, 02 Nov 2008 01:00:32 +0100
Message-ID: <490CEDA0.6020800@fr.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020401040007090503010608"
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
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a multi-part message in MIME format.
--------------020401040007090503010608
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



--------------020401040007090503010608
Content-Type: text/x-diff;
 name="do-not-shutdown-when-not-init-pid-ns.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="do-not-shutdown-when-not-init-pid-ns.patch"

Subject: disable sys_reboot when not in init_pid_ns
From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

This simple patch avoid to shutdown the host within a container. Without this
patch a call to the 'halt' inside a container will switch to the right runlevel
but finishing with 'shutdown -f' in the last init script with the effect of
shutting down the real host.

This patch has been tested with the lxc tools and a debian minimal container.
The 'init' process running inside the container does correctly call the 
different shutdown services and the container exits gracefully.

I didn't try with the 'init' from the upstart package. It uses an abstract
unix socket, that means this patch should work if the container is network 
isolated too.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
---
 kernel/sys.c |    3 +++
 1 file changed, 3 insertions(+)

Index: net-next-2.6/kernel/sys.c
===================================================================
--- net-next-2.6.orig/kernel/sys.c
+++ net-next-2.6/kernel/sys.c
@@ -355,6 +355,9 @@ asmlinkage long sys_reboot(int magic1, i
 	if (!capable(CAP_SYS_BOOT))
 		return -EPERM;
 
+	if (current->nsproxy->pid_ns != &init_pid_ns)
+		return 0;
+
 	/* For safety, we require "magic" arguments. */
 	if (magic1 != LINUX_REBOOT_MAGIC1 ||
 	    (magic2 != LINUX_REBOOT_MAGIC2 &&

--------------020401040007090503010608
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--------------020401040007090503010608--
