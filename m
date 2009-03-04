From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 8/8] check files for checkpointability
Date: Wed, 04 Mar 2009 15:41:41 -0800
Message-ID: <1236210101.22399.55.camel__5539.8573437289$1236210328$gmane$org@nimitz>
References: <20090227203425.F3B51176@kernel>
	<20090227203435.98735E54@kernel>  <20090228025743.GA22451@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090228025743.GA22451-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2009-02-27 at 18:57 -0800, Sukadev Bhattiprolu wrote: 
> Dave Hansen [dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org] wrote:
> | 
> | Introduce a files_struct counter to indicate whether a particular
> | file_struct has ever contained a file which can not be
> | checkpointed.  This flag is a one-way trip; once it is set, it may
> | not be unset.
> | 
> | We assume at allocation that a new files_struct is clean and may
> | be checkpointed.  However, as soon as it has had its files filled
> | from its parent's, we check it for real in __scan_files_for_cr().
> | At that point, we mark it if it contained any uncheckpointable
> | files.
> 
> Hmm. Why not just copy ->may_checkpoint setting from parent (or old)
> files_struct ? If parent is not checkpointable, then child won't be
> and vice-versa - no ?

Because init does things that are uncheckpointable.  If we purely
inherit, we'll never be able to checkpoint.

> | +static void __scan_files_for_cr(struct files_struct *files)
> | +{
> | +	int i;
> | +
> | +	for (i = 0; i < files->fdtab.max_fds; i++) {
> | +		struct file *f = fcheck_files(files, i);
> | +		if (!f)
> | +			continue;
> | +		if (cr_file_supported(f))
> | +			continue;
> | +		files_deny_checkpointing(files);
> | +	}
> | +}
> | +
> 
> A version of __scan_files_for_cr() for CONFIG_CHECKPOINT_RESTART=n or...
> 
> |  /*
> |   * Allocate a new files structure and copy contents from the
> |   * passed in files structure.
> | @@ -303,6 +318,9 @@ struct files_struct *dup_fd(struct files
> |  		goto out;
> | 
> |  	atomic_set(&newf->count, 1);
> | +#ifdef CONFIG_CHECKPOINT_RESTART
> | +	newf->may_checkpoint = 1;
> | +#endif
> | 
> |  	spin_lock_init(&newf->file_lock);
> |  	newf->next_fd = 0;
> | @@ -396,6 +414,7 @@ struct files_struct *dup_fd(struct files
> | 
> |  	rcu_assign_pointer(newf->fdt, new_fdt);
> | 
> | +	__scan_files_for_cr(newf);
> 
> ... #ifdef CONFIG_CHECKPOINT_RESTART here ?

gcc isn't quite smart enough to figure out that this is a noop.  Please
see my new set for a new compiler helper to solve this problem.

-- Dave
