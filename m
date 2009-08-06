From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][v4][PATCH 7/7]: Define clone_extended() syscall
Date: Thu, 6 Aug 2009 13:35:15 -0500
Message-ID: <20090806183515.GA4280@us.ibm.com>
References: <20090806061056.GA1044@us.ibm.com>
	<20090806062505.GG5619@us.ibm.com>
	<20090806133847.GA28392@us.ibm.com> <4A7AF8AD.4070805@librato.com>
	<20090806155520.GA904@us.ibm.com> <4A7AFF61.8050802@librato.com>
	<20090806161616.GA1472@us.ibm.com>
	<20090806182340.GA2579@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090806182340.GA2579-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> | I think Suka's suggestion is again inherently limited (in # of
> | clone flags) and will force even uglier syscalls for each arch than the
> | previous one already does.
> | 
> 
> Yes other architectures are forced to ignore the flags_high and copy-in the
> tid pointers.
> 
> But if we want more than 64 bit flags, we may need follow the sigset_t 
> model ?
> 
> Also, I am listing three approaches below. Do you prefer #2 below ?

I prefer #2 with 'struct pid_set' renamed to clone_ext_data or something,
and either a version # or int num_clone_words so we can add clone flags
later.  I know, adding more then 32 more clone flags seems unlikely, but...

> 1. =====
> 
>         struct clone_tid_info {
>                 void *parent_tid;       /* parent_tid_ptr parameter */
>                 void *child_tid;        /* child_tid_ptr parameter */
>         };
> 
>         struct pid_set {
>                 int num_pids;
>                 pid_t *pids;
>         };
> 
>         int clone_extended(int flags_low, int flags_high, void *child_stack,
>                         void *unused, struct clone_tid_info *tid_ptrs,
>                         struct pid_set *pid_setp);
> 
> 2. ======
> 
> 	struct clone_info {
> 		int flags_high;
> 		struct pid_set pid_set;
> 	}
> 
>         int clone_extended(int flags_low, void *child_stack, void *unused,
> 		int *parent_tid, int *child_tid, struct clone_info *clone_info);
> 
> 
> 	Pros:
> 		- copy_from_user() needed only for new flags and pid_set
> 
> 	Cons:
> 		- splitting the high and low clone-flags is awkward ?
> 
> 3. =====
> 
> 	typedef struct {
> 		unsigned long flags[N_CLONE_FLAGS];
> 	} clone_flags_t;
> 
> 	int clone_extended(clone_flags_t *flags, void *child_stack, int *unused,
> 		int *parent_tid, int *child_tid, struct pid_set *pid_set);
> 
> 
> 	Pros:
> 		- extendible clone_flags (like sigset_t)
> 		- no copy_from_user() when we have 32 clone-flags
> 		- no copy_from_user for tids
> 
> 	Cons:
> 		- copy_from_user() needed on 32-bit architectures for all flags
> 		  when they exceed 32.
> 
> 
> Sukadev
