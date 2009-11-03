From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [v10][PATCH 8/9] Define clone_with_pids() syscall
Date: Mon, 2 Nov 2009 22:44:54 -0800
Message-ID: <20091103064454.GA22483@us.ibm.com>
References: <20091101204132.GA22116@us.ibm.com>
	<20091101204548.GG23168@us.ibm.com> <4AEF2077.5080107@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AEF2077.5080107-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Oren Laadan [orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org] wrote:
| 
| > +	/*
| > +	 * TODO: If size of clone_args is not what the kernel expects, it
| > +	 * 	 could be that kernel is newer and has an extended structure.
| > +	 * 	 When that happens, this check needs to be smarter (and we
| > +	 * 	 need an additional copy_from_user()). For now, assume exact
| > +	 * 	 match.
| > +	 */
| > +	if (kcs.clone_args_size != sizeof(kcs))
| > +		return -EINVAL;
| 
| I wonder if this is a reason to move the clone_args_size outside the
| structure and pass it as a regular argument ?  This will rid the
| (futuristic) additional copy-from-user (in case it causes a concern
| for clone performance ?)

Your idea makes sense to me. 

Roland, Peter Arnd: do you have any concerns with removing clone_args_size
from the structure and making it a parameter ?

	struct clone_args {
		u64 clone_flags_high;
		u64 child_stack_base;
		u64 child_stack_size;
		u64 parent_tid_ptr;
		u64 child_tid_ptr;
		u32 nr_pids;
		u32 reserved0;
		u64 reserved1;
	};

	sys_clone_with_pids(u32 flags_low, struct clone_args *cargs,
			u32 nr_pids, u32 clone_args_size)

Sukadev
