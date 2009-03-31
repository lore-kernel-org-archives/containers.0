From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v14-rc2][PATCH 10/29] actually use f_op in checkpoint code
Date: Tue, 31 Mar 2009 14:31:15 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0903311428570.26966@takamine.ncl.cs.columbia.edu>
References: <1238477349-11029-1-git-send-email-orenl@cs.columbia.edu>
	<1238477349-11029-11-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1238477349-11029-11-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org


If ext2/3/4 is compiled as a kernel module, apply this patch to
successfully compile this c/r patchset.

Oren.

diff --git a/checkpoint/ckpt_file.c b/checkpoint/ckpt_file.c
index 0fe68bf..df6bb3d 100644
--- a/checkpoint/ckpt_file.c
+++ b/checkpoint/ckpt_file.c
@@ -109,6 +109,8 @@ int generic_file_checkpoint(struct cr_ctx *ctx, struct file *file,
 	return cr_write_file_generic(ctx, file, hh);
 }
 
+EXPORT_SYMBOL(generic_file_checkpoint);
+
 /* cr_write_file - dump the state of a given file pointer */
 static int cr_write_file(struct cr_ctx *ctx, struct file *file)
 {


On Tue, 31 Mar 2009, Oren Laadan wrote:

> From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> 
> Right now, we assume all normal files and directories
> can be checkpointed.  However, as usual in the VFS, there
> are specialized places that will always need an ability
> to override these defaults.  We could do this completely
> in the checkpoint code, but that would bitrot quickly.
> 
> This adds a new 'file_operations' function for
> checkpointing a file.  I did this under the assumption
> that we should have a dirt-simple way to make something
> (un)checkpointable that fits in with current code.
> 
> As you can see in the ext[234] and /proc patches, all
> that we have to do to make something simple be
> supported is add a single "generic" f_op entry.
> 
> Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
