From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][v4][PATCH 7/7]: Define clone_extended() syscall
Date: Thu, 6 Aug 2009 11:16:17 -0500
Message-ID: <20090806161616.GA1472@us.ibm.com>
References: <20090806061056.GA1044@us.ibm.com>
	<20090806062505.GG5619@us.ibm.com>
	<20090806133847.GA28392@us.ibm.com> <4A7AF8AD.4070805@librato.com>
	<20090806155520.GA904@us.ibm.com> <4A7AFF61.8050802@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A7AFF61.8050802-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> >>>> The proposed interface for clone_extended() is:
> >>>>
> >>>> 	struct clone_tid_info {
> >>>> 		void *parent_tid; 	/* parent_tid_ptr parameter */
> >>>> 		void *child_tid; 	/* child_tid_ptr parameter */
> >>>> 	};
> >>>>
> >>>> 	struct pid_set {
> >>>> 		int num_pids;
> >>>> 		pid_t *pids;
> >>>> 	};
> >>>>
> >>>> 	int clone_extended(int flags_low, int flags_high, void *child_stack,
> >>>> 			void *unused, struct clone_tid_info *tid_ptrs,
> >>>> 			struct pid_set *pid_setp);
> >>> I was thinking additional flags would be passed in the (renamed)
> >>> struct pid_set.
> >> Yes.
> >>
> >> But maybe in (renamed) 'struct clone_info' instead of 'struct pid_set' ?
> >>
> >> I vaguely recall a strong preference to not require copy-from-user
> >> during a fast-path clone, because it may hurt performance.
> >>
> >> *If* this is the case, then maybe place extra flags among the
> >> "base" args, or at least a CLONE_EXTRA would indicate that more
> >> arguments need to be pulled from user-space ?
> > 
> > Wouldn't passing NULL for struct clone_info suffice?
> 
> :o
> 
> Actually, I misread the original prototype, and I prefer Suka's
> current suggestion.

I think Suka's suggestion is again inherently limited (in # of
clone flags) and will force even uglier syscalls for each arch than the
previous one already does.

-serge
