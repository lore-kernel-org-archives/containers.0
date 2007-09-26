From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Fix cgroup_create_dir() comments
Date: Tue, 25 Sep 2007 20:19:48 -0700
Message-ID: <46F9CFD4.3020001__1710.23218795217$1190776932$gmane$org@google.com>
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

Comment fixed, to match the actual arguments.

Signed-off-by: Balaji Rao <balajirao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---
 kernel/cgroup.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: container-2.6.23-rc8-mm1/kernel/cgroup.c
===================================================================
--- container-2.6.23-rc8-mm1.orig/kernel/cgroup.c
+++ container-2.6.23-rc8-mm1/kernel/cgroup.c
@@ -1569,7 +1569,7 @@ static int cgroup_create_file(struct den
  *	cont:	the cgroup we create the directory for.
  *		It must have a valid ->parent field
  *		And we are going to fill its ->dentry field.
- *	name:	The name to give to the cgroup directory. Will be copied.
+ *	dentry: dentry of the new container
  *	mode:	mode to set on new directory.
  */
 static int cgroup_create_dir(struct cgroup *cont, struct dentry *dentry,
