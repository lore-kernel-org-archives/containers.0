From: Mark Nelson <markn-8fk3Idey6ehBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] namespaces: introduce sys_hijack (v8)
Date: Mon, 05 Nov 2007 16:18:50 +1100
Message-ID: <472EA7BA.3030401@au1.ibm.com>
References: <20071102203226.GA10475@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071102203226.GA10475-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Serge,

Quick fix (feel free to just fold it into your patch). There may be
a smarter way of fixing this, but this worked for -lxc...

Thanks!

Mark.


ERR_PTR is now used in cgroup code so we need to include err.h

This fixes the build error with CGROUPS disabled:

In file included from include/linux/cpuset.h:14,
                 from mm/slub.c:19:
include/linux/cgroup.h: In function 'task_from_cgroup_fd':
include/linux/cgroup.h:329: error: implicit declaration of function 'ERR_PTR'
include/linux/cgroup.h:329: warning: return makes pointer from integer without a cast
make[2]: *** [mm/slub.o] Error 1
make[1]: *** [mm] Error 2
make: *** [sub-make] Error 2

Signed-off-by: Mark Nelson <markn-8fk3Idey6ehBDgjK7y7TUQ@public.gmane.org>
---
 include/linux/cgroup.h |    1 +
 1 file changed, 1 insertion(+)

Index: linux/include/linux/cgroup.h
===================================================================
--- linux.orig/include/linux/cgroup.h
+++ linux/include/linux/cgroup.h
@@ -14,6 +14,7 @@
 #include <linux/nodemask.h>
 #include <linux/rcupdate.h>
 #include <linux/cgroupstats.h>
+#include <linux/err.h>
 
 #ifdef CONFIG_CGROUPS
