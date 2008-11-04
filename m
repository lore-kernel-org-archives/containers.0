From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v8][PATCH 0/12] Kernel based checkpoint/restart
Date: Tue, 4 Nov 2008 15:38:05 -0600
Message-ID: <20081104213805.GA14737__2101.09138065508$1225834919$gmane$org@us.ibm.com>
References: <1225374675-22850-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1225374675-22850-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linus Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> Basic checkpoint-restart [C/R]: v8 adds support for "external" checkpoint
> and improves documentation. Older announcements below.

Finally!

From 8edab186b605f7dddd612e581204f1ad8fd766be Mon Sep 17 00:00:00 2001
From: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Tue, 4 Nov 2008 15:28:01 -0600
Subject: [PATCH 1/1] cr: fix use of __d_path()

__d_path():
	1. should be used under dcache_lock
	2. can change root->{mnt,dentry} without changing refcounts
The second point was the cause of my BUGs.  The ctx->root was passed
in, and do_checkpoint() had taken a path_get on the vfsroot.  So now
at cleanup it was doing path_put() using another mnt+dentry.

(Why they are different, I'm not sure - but my guess would be that
stdin or stdout is inherited from the parent task in parent mntns,
hence file->mnt is different from root->mnt as it's a different
namespace.)

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/checkpoint.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 173b637..7f0c1e7 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -70,9 +70,20 @@ static char *
 cr_fill_fname(struct path *path, struct path *root, char *buf, int *n)
 {
 	char *fname;
+	struct path root2;
+
+	root2.mnt = root->mnt;
+	root2.dentry = root->dentry;
 
 	BUG_ON(!buf);
-	fname = __d_path(path, root, buf, *n);
+	spin_lock(&dcache_lock);
+	fname = __d_path(path, &root2, buf, *n);
+	spin_unlock(&dcache_lock);
+	if (root2.mnt != root->mnt)
+		printk(KERN_NOTICE "%s: mnt changed\n", __func__);
+	if (root2.dentry != root->dentry)
+		printk(KERN_NOTICE "%s: dentry changed\n", __func__);
+	fname = buf+10;
 	if (!IS_ERR(fname))
 		*n = (buf + (*n) - fname);
 	return fname;
-- 
1.5.6.3
