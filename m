From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC][PATCH 1/4] Remove useless utsname.h includes
Date: Mon, 05 Jan 2009 17:13:15 -0800
Message-ID: <20090106011314.800370762__36913.4535584182$1231204591$gmane$org@us.ibm.com>
References: <20090106011314.534653345@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=remove-useless-utsname-includes.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

As best I can tell these #includes aren't needed in these files.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>

---
 fs/lockd/xdr.c      |    1 -
 fs/lockd/xdr4.c     |    1 -
 fs/nfs/nfs2xdr.c    |    1 -
 fs/nfs/nfs3proc.c   |    1 -
 fs/nfs/nfs4proc.c   |    1 -
 fs/nfs/nfs4xdr.c    |    1 -
 fs/nfs/proc.c       |    1 -
 fs/nfsd/nfs4idmap.c |    1 -
 8 files changed, 8 deletions(-)

Index: linux-2.6.28/fs/lockd/xdr.c
===================================================================
--- linux-2.6.28.orig/fs/lockd/xdr.c
+++ linux-2.6.28/fs/lockd/xdr.c
@@ -8,7 +8,6 @@
 
 #include <linux/types.h>
 #include <linux/sched.h>
-#include <linux/utsname.h>
 #include <linux/nfs.h>
 
 #include <linux/sunrpc/xdr.h>
Index: linux-2.6.28/fs/lockd/xdr4.c
===================================================================
--- linux-2.6.28.orig/fs/lockd/xdr4.c
+++ linux-2.6.28/fs/lockd/xdr4.c
@@ -9,7 +9,6 @@
 
 #include <linux/types.h>
 #include <linux/sched.h>
-#include <linux/utsname.h>
 #include <linux/nfs.h>
 
 #include <linux/sunrpc/xdr.h>
Index: linux-2.6.28/fs/nfs/proc.c
===================================================================
--- linux-2.6.28.orig/fs/nfs/proc.c
+++ linux-2.6.28/fs/nfs/proc.c
@@ -32,7 +32,6 @@
 #include <linux/slab.h>
 #include <linux/time.h>
 #include <linux/mm.h>
-#include <linux/utsname.h>
 #include <linux/errno.h>
 #include <linux/string.h>
 #include <linux/in.h>
Index: linux-2.6.28/fs/nfs/nfs2xdr.c
===================================================================
--- linux-2.6.28.orig/fs/nfs/nfs2xdr.c
+++ linux-2.6.28/fs/nfs/nfs2xdr.c
@@ -13,7 +13,6 @@
 #include <linux/time.h>
 #include <linux/mm.h>
 #include <linux/slab.h>
-#include <linux/utsname.h>
 #include <linux/errno.h>
 #include <linux/string.h>
 #include <linux/in.h>
Index: linux-2.6.28/fs/nfs/nfs3proc.c
===================================================================
--- linux-2.6.28.orig/fs/nfs/nfs3proc.c
+++ linux-2.6.28/fs/nfs/nfs3proc.c
@@ -7,7 +7,6 @@
  */
 
 #include <linux/mm.h>
-#include <linux/utsname.h>
 #include <linux/errno.h>
 #include <linux/string.h>
 #include <linux/sunrpc/clnt.h>
Index: linux-2.6.28/fs/nfs/nfs4proc.c
===================================================================
--- linux-2.6.28.orig/fs/nfs/nfs4proc.c
+++ linux-2.6.28/fs/nfs/nfs4proc.c
@@ -36,7 +36,6 @@
  */
 
 #include <linux/mm.h>
-#include <linux/utsname.h>
 #include <linux/delay.h>
 #include <linux/errno.h>
 #include <linux/string.h>
Index: linux-2.6.28/fs/nfs/nfs4xdr.c
===================================================================
--- linux-2.6.28.orig/fs/nfs/nfs4xdr.c
+++ linux-2.6.28/fs/nfs/nfs4xdr.c
@@ -39,7 +39,6 @@
 #include <linux/time.h>
 #include <linux/mm.h>
 #include <linux/slab.h>
-#include <linux/utsname.h>
 #include <linux/errno.h>
 #include <linux/string.h>
 #include <linux/in.h>
Index: linux-2.6.28/fs/nfsd/nfs4idmap.c
===================================================================
--- linux-2.6.28.orig/fs/nfsd/nfs4idmap.c
+++ linux-2.6.28/fs/nfsd/nfs4idmap.c
@@ -38,7 +38,6 @@
 #include <linux/init.h>
 
 #include <linux/mm.h>
-#include <linux/utsname.h>
 #include <linux/errno.h>
 #include <linux/string.h>
 #include <linux/sunrpc/clnt.h>

-- 
