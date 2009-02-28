From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 8/8] check files for checkpointability
Date: Fri, 27 Feb 2009 18:57:43 -0800
Message-ID: <20090228025743.GA22451__29835.1578102031$1235790042$gmane$org@us.ibm.com>
References: <20090227203425.F3B51176@kernel> <20090227203435.98735E54@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090227203435.98735E54@kernel>
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
| Introduce a files_struct counter to indicate whether a particular
| file_struct has ever contained a file which can not be
| checkpointed.  This flag is a one-way trip; once it is set, it may
| not be unset.
| 
| We assume at allocation that a new files_struct is clean and may
| be checkpointed.  However, as soon as it has had its files filled
| from its parent's, we check it for real in __scan_files_for_cr().
| At that point, we mark it if it contained any uncheckpointable
| files.

Hmm. Why not just copy ->may_checkpoint setting from parent (or old)
files_struct ? If parent is not checkpointable, then child won't be
and vice-versa - no ?

| 
| We also check each 'struct file' when it is installed in a fd
| slot.  This way, if anyone open()s or managed to dup() an
| unsuppored file, we can catch it.
| 
| Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
| ---
| 
|  linux-2.6.git-dave/fs/file.c                  |   19 +++++++++++++++++++
|  linux-2.6.git-dave/fs/open.c                  |    5 +++++
|  linux-2.6.git-dave/include/linux/checkpoint.h |   14 ++++++++++++++
|  linux-2.6.git-dave/include/linux/fdtable.h    |    3 +++
|  4 files changed, 41 insertions(+)
| 
| diff -puN fs/file.c~track-files_struct-checkpointability fs/file.c
| --- linux-2.6.git/fs/file.c~track-files_struct-checkpointability	2009-02-27 12:07:41.000000000 -0800
| +++ linux-2.6.git-dave/fs/file.c	2009-02-27 12:07:41.000000000 -0800
| @@ -15,6 +15,7 @@
|  #include <linux/file.h>
|  #include <linux/fdtable.h>
|  #include <linux/bitops.h>
| +#include <linux/checkpoint.h>
|  #include <linux/interrupt.h>
|  #include <linux/spinlock.h>
|  #include <linux/rcupdate.h>
| @@ -285,6 +286,20 @@ static int count_open_files(struct fdtab
|  	return i;
|  }
| 
| +static void __scan_files_for_cr(struct files_struct *files)
| +{
| +	int i;
| +
| +	for (i = 0; i < files->fdtab.max_fds; i++) {
| +		struct file *f = fcheck_files(files, i);
| +		if (!f)
| +			continue;
| +		if (cr_file_supported(f))
| +			continue;
| +		files_deny_checkpointing(files);
| +	}
| +}
| +

A version of __scan_files_for_cr() for CONFIG_CHECKPOINT_RESTART=n or...

|  /*
|   * Allocate a new files structure and copy contents from the
|   * passed in files structure.
| @@ -303,6 +318,9 @@ struct files_struct *dup_fd(struct files
|  		goto out;
| 
|  	atomic_set(&newf->count, 1);
| +#ifdef CONFIG_CHECKPOINT_RESTART
| +	newf->may_checkpoint = 1;
| +#endif
| 
|  	spin_lock_init(&newf->file_lock);
|  	newf->next_fd = 0;
| @@ -396,6 +414,7 @@ struct files_struct *dup_fd(struct files
| 
|  	rcu_assign_pointer(newf->fdt, new_fdt);
| 
| +	__scan_files_for_cr(newf);

... #ifdef CONFIG_CHECKPOINT_RESTART here ?

Sukadev
