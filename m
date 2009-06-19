From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org: [PATCH 1/9] cred: #include init.h in cred.h]
Date: Fri, 19 Jun 2009 13:48:11 -0500
Message-ID: <20090619184811.GA28045@us.ibm.com>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Oren,

until you rebase onto a newer Linus tree (which has this fix), I still
need this patch in order for s390 to compile.  Can you keep it in the
patchset for now?

----- Forwarded message from "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> -----

Date:  Fri, 29 May 2009 17:32:48 -0500
From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
	Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Morgan <morgan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Subject: [PATCH 1/9] cred: #include init.h in cred.h

cred.h can't be included as first header because it uses __init and
doesn't include init.h which is enough to break compilation on at least
ia64.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/cred.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/cred.h b/include/linux/cred.h
index 3282ee4..4fa9996 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -13,6 +13,7 @@
 #define _LINUX_CRED_H

 #include <linux/capability.h>
+#include <linux/init.h>
 #include <linux/key.h>
 #include <asm/atomic.h>

-- 
1.6.1

--
To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

----- End forwarded message -----
