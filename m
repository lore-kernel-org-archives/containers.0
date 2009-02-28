From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 4/8] file c/r: expose functions to query fs support
Date: Fri, 27 Feb 2009 17:33:02 -0800
Message-ID: <20090228013302.GC19872__44599.4666232311$1235784979$gmane$org@us.ibm.com>
References: <20090227203425.F3B51176@kernel> <20090227203429.6963AFC4@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090227203429.6963AFC4@kernel>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Dave Hansen [dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org] wrote:
| 
| This pair of functions will check to see whether a given
| 'struct file' can be checkpointed.  If it can't be, the
| "explain" function can also give a description why.
| 
| Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
| ---
| 
|  linux-2.6.git-dave/checkpoint/ckpt_file.c     |   46 ++++++++++++++++++++++++++
|  linux-2.6.git-dave/include/linux/checkpoint.h |   18 ++++++++++
|  2 files changed, 64 insertions(+)
| 
| diff -puN checkpoint/ckpt_file.c~cr-explain-unckpt-file checkpoint/ckpt_file.c
| --- linux-2.6.git/checkpoint/ckpt_file.c~cr-explain-unckpt-file	2009-02-27 12:07:38.000000000 -0800
| +++ linux-2.6.git-dave/checkpoint/ckpt_file.c	2009-02-27 12:07:38.000000000 -0800
| @@ -72,6 +72,52 @@ int cr_scan_fds(struct files_struct *fil
|  	return n;
|  }
| 
| +int fs_is_cr_able(struct file_system_type *fs_type)

Too many variations in naming ? "*cr_able(), *supported(), *checkpointable()'
all for a boolean result.

How about calling this cr_fs_checkpointable() ?

| +{
| +	if (fs_type->fs_flags & FS_CHECKPOINTABLE)
| +		return 1;
| +	/*
| +	 * We assume that all block-based filesystems that
| +	 * need devices work.  This covers all of the
| +	 * "important" fs's by default like ext*.  If this
| +	 * assumption becomes untrue, we may need a
| +	 * NOT_CHECKPOINTABLE flag in the future
| +	 */
| +	if (fs_type->fs_flags & FS_REQUIRES_DEV)
| +		return 1;
| +	return 0;
| +}
| +
| +int cr_explain_file(struct file *file, char *explain, int left)
| +{
| +	struct inode *inode = file->f_dentry->d_inode;
| +	struct file_system_type *fs_type = inode->i_sb->s_type;
| +
| +	if (!fs_is_cr_able(fs_type))
| +		return snprintf(explain, left,
| +				" (%s does not support checkpoint)",
| +				fs_type->name);
| +
| +	if (special_file(inode->i_mode))
| +		return snprintf(explain, left, " (special file)");
| +
| +	return 0;
| +}
| +
| +int cr_file_supported(struct file *file)

and this cr_file_checkpointable() ?

Sukadev
