From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v14-rc2][PATCH 10/29] actually use f_op in checkpoint code
Date: Tue, 07 Apr 2009 01:36:25 -0400
Message-ID: <49DAE659.9020301@cs.columbia.edu>
References: <1238477349-11029-1-git-send-email-orenl@cs.columbia.edu>
	<1238477349-11029-11-git-send-email-orenl@cs.columbia.edu>
	<20090407032912.GF12316@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090407032912.GF12316-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org



Sukadev Bhattiprolu wrote:
> A minor comment and a nit.
> 
> Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
> | From d832bfba9a50789fbfadf8486fbdfbd8b498a9ea Mon Sep 17 00:00:00 2001
> | From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> | Date: Fri, 27 Mar 2009 12:50:47 -0700
> | Subject: [PATCH 10/29] actually use f_op in checkpoint code
> | 
> | 
> | Right now, we assume all normal files and directories
> | can be checkpointed.  However, as usual in the VFS, there
> | are specialized places that will always need an ability
> | to override these defaults.  We could do this completely
> | in the checkpoint code, but that would bitrot quickly.
> | 
> | This adds a new 'file_operations' function for
> | checkpointing a file.  I did this under the assumption
> | that we should have a dirt-simple way to make something
> | (un)checkpointable that fits in with current code.
> | 
> | As you can see in the ext[234] and /proc patches, all
> | that we have to do to make something simple be
> | supported is add a single "generic" f_op entry.

[...]

> |  /* cr_write_file - dump the state of a given file pointer */
> |  static int cr_write_file(struct cr_ctx *ctx, struct file *file)
> |  {
> |  	struct cr_hdr_file *hh;
> | -	struct dentry *dent = file->f_dentry;
> | -	struct inode *inode = dent->d_inode;
> |  	int ret;
> |  
> |  	hh = cr_hbuf_get(ctx, sizeof(*hh));
> | @@ -116,21 +125,11 @@ static int cr_write_file(struct cr_ctx *ctx, struct file *file)
> |  	hh->f_version = file->f_version;
> |  	/* FIX: need also file->uid, file->gid, file->f_owner, etc */
> |  
> | -	/*
> | -	 * FIXME: when we'll add support for unlinked files/dirs, we'll
> | -	 * need to distinguish between unlinked filed and unlinked dirs.
> | -	 */
> | -	switch (inode->i_mode & S_IFMT) {
> | -	case S_IFREG:
> | -	case S_IFDIR:
> | -		ret = cr_write_file_generic(ctx, file, hh);
> | -		break;
> | -	default:
> | -		ret = -EBADF;
> | -		break;
> | -	}
> | -	cr_hbuf_put(ctx, sizeof(*hh));
> | +	ret = -EBADF;
> | +	if (file->f_op->checkpoint)
> | +		ret = file->f_op->checkpoint(ctx, file, hh);
> 
> Minor: not bisect safe for checkpoint - fwiw, with previous patch we could
> checkpoint a process with open file, but with this change, we can't ? How
> about merge patches 10 and 11 ?

It will will remain not-bisect-safe for anyone who is using other than
ext2/3/4 file systems.

I think it's a good way of separating the concept and it's implementation.

[...]

Oren.
