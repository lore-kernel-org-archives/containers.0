From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC cr-pipe-v13][PATCH 3/3] Restore open pipes
Date: Tue, 03 Feb 2009 08:23:21 -0800
Message-ID: <87bptj7ame.fsf@caffeine.danplanet.com>
References: <1233091395-24582-1-git-send-email-orenl@cs.columbia.edu>
	<1233091395-24582-5-git-send-email-orenl@cs.columbia.edu>
	<87k5887n16.fsf@caffeine.danplanet.com>
	<498789B1.80601@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <498789B1.80601-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> (Oren Laadan's message of "Mon,
	02 Feb 2009 19:02:57 -0500")
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

OL> So the implementation of the logic above is ... inaccurate :( I
OL> can reproduce it here; will take a closer look at it soon.

Indeed.  I think fixing the following typo makes my test case work as
expected for me:

diff --git a/checkpoint/ckpt_file.c b/checkpoint/ckpt_file.c
index 9ff401a..71aafb4 100644
--- a/checkpoint/ckpt_file.c
+++ b/checkpoint/ckpt_file.c
@@ -215,7 +215,7 @@ static int cr_write_fd_data(struct cr_ctx *ctx, struct file *file, int parent)
 		return fd_type;
 	}
 
-	hh->fd_objref = cr_inode_to_objref(ctx, inode, hh->fd_type, &new);
+	hh->fd_objref = cr_inode_to_objref(ctx, inode, fd_type, &new);
 	pr_debug("type %d objref %d (%d)\n", hh->fd_type, hh->fd_objref, new);
 	if (!new)
 		fd_type = CR_FD_OBJREF;


-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
