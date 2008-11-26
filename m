From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH][v2] Define/use siginfo_from_ancestor_ns()
Date: Tue, 25 Nov 2008 19:16:19 -0800
Message-ID: <20081126031619.GA19756@us.ibm.com>
References: <20081115212133.GA32140@us.ibm.com> <20081118175336.GA14178@redhat.com> <20081119012207.GA19092@us.ibm.com> <20081123231014.GA2424@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754020AbYKZDQo@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081123231014.GA2424@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: ebiederm@xmission.com, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Oleg Nesterov [oleg@redhat.com] wrote:
| On 11/18, Sukadev Bhattiprolu wrote:
| >
| > |
| > | > +static inline int siginfo_from_ancestor_ns(siginfo_t *info)
| > | > +{
| > | > +	return SI_FROMUSER(info) && (info->si_pid == 0);
| > | > +}
| > |
| > | Yes, this is problem... I doubt we can rely on !si_pid here.
| > | More on this later.
| >
| > BTW, rather than clearing SIG_FROM_USER in send_signal(), can we
| > keep it till we dequeue the signal ? Yes, collect_signal() would
| > need to consider this flag. But when we dequeue, we can note that
| > it was from user and use that in the siginfo_from_ancestor() ?
| 
| Yes! I thought about this too. As a last resort this should work
| afaics. But we should be carefull, we have to fix rm_from_queue_full()
| for example as well.
| 
| Another note. We can split SIG_FROM_USER (if we are going to use this
| hack) into 2 flags: SIG_KILL_SUB_NS and SIG_MANGLE_SI_PID. We can
| even put "struct pid *pid" into si_signo along with these bits if
| we find some strange user which sends the signal on behalve of
| the different task.
| 
| But personally, I'd prefer to make 3 simple patches for the start.
| Then we can continue with these complications if needed. Sukadev,
| please feel free to disagree with me. I am just trying to make
| the first step reviewable and simple. No changes on dequeue path,
| no -ENOMEM in send_signal().

Yes, I think this is simple and addresses most common problems
and specially bypasses the blocked signals issues. And since
we don't have to pass any state to get_signal_deliver(), we
don't have worry about the -ENOMEM.

| 
| 1. Introduce SIG_FROM_USER (or whatever). Basically, the patch I
|    sent. Except I'd relly like to see this code under CONFIG_
|    just for documentation, but please feel free to ignore.
| 
|    So, with this patch send_signal() has "bool from_ancestor", which
|    is not used so far. And we the fixup code after copy_siginfo()
|    which clears the flags, or better yet just sets .si_signo = sig.

I am just clearing the SIG_FROM_USER flag for now - just in case
we need to overload it for something else later ?

| 
| 2. Now we change send_signal()
| 
| 	+	if (from_ancestor && sig == SIGKILL)
| 	+		t->signal->flags &= ~SIGNAL_UNKILLABLE;
| 		if (!prepare_signal(...))
| 			return;
| 
|    and change copy_signal() to set SIGNAL_UNKILLABLE for
|    cinit.
| 
|    From now cinit is protected from unwanted signals from
|    its namespace, and the parent can always kill it with
|    SIGKILL.
| 
|    Actually, I think this is enough to solve most problems,
|    the further changes can be discussed later. OK, the only
|    "real" problem is SIGSTOP, afaics. This looks solveable.

Yes, SIGSTOP even from parent is ignored due to the SIGNAL_UNKILLABLE
check in get_signal_to_deliver.

| 
| 3. mangle .si_pid in send_signal(). Again, it is not clear
|    what should we do with sys_rt_sigqueueinfo(), but there
|    is no "obviously right" solution.

Agree.

| 
| And I am really sorry for delay.

No problem. This issue has been around for over a year :-)

I will send the patches out in a bit.

Thanks,

Sukadev
