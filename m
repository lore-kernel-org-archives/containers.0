From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 2/4] signals: send_signal: use si_fromuser() to detect
	from_ancestor_ns
Date: Mon, 5 Oct 2009 12:37:38 -0700
Message-ID: <20091005193738.GF30442@us.ibm.com>
References: <4AC608BE.9020805@fr.ibm.com> <20091003171029.GA30442@us.ibm.com>
	<20091004021844.GA21006@redhat.com>
	<20091004021954.GC21006@redhat.com>
	<20091005181255.GE30442@us.ibm.com>
	<20091005182536.GA943@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091005182536.GA943-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Oleg Nesterov [oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org] wrote:
| On 10/05, Sukadev Bhattiprolu wrote:
| >
| > Oleg Nesterov [oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org] wrote:
| > |
| > | --- TTT_32/kernel/signal.c~FU_2_SEND_SIGNAL	2009-10-04 02:21:55.000000000 +0200
| > | +++ TTT_32/kernel/signal.c	2009-10-04 03:09:44.000000000 +0200
| > | @@ -928,9 +928,8 @@ static int send_signal(int sig, struct s
| > |  	int from_ancestor_ns = 0;
| > |
| > |  #ifdef CONFIG_PID_NS
| > | -	if (!is_si_special(info) && SI_FROMUSER(info) &&
| > | -			task_pid_nr_ns(current, task_active_pid_ns(t)) <= 0)
| > | -		from_ancestor_ns = 1;
| > | +	from_ancestor_ns = si_fromuser(info) &&
| > | +			   !task_pid_nr_ns(current, task_active_pid_ns(t));
| >
| > Makes sense. And we had mentioned earlier that container-init is immune
| > to suicide but should we add a check for 'current == t' above to cover the
| >
| > 	send_sig(SIGKILL, current, 0);
| >
| > in load_aout_binary() and friends
| >
| > 	from_ancestor_ns = si_fromuser(info) && (current == t ||
| > 				!task_pid_nr_ns(current, task_active_pid_ns(t)));
| 
| I don't think so.
| 
| First of all, this is just ugly. If we need this check we should change
| the callers, not send_signal().

Well, all I am saying is that the check

	!task_pid_nr_ns(current, task_active_pid_ns(t)))

excludes container-init sending signal to itself - task_pid_nr_ns() above
would return 1 for container-init and 'from_ancestor_ns' would be 0.

But sure, we could use force_sig_info() in caller.

| 
| But more importantly, I disagree with "container-init is immune to suicide"
| above. This is another issue I was going to discuss later, lets do this now.

Ok :-)

| 
| When load_elf_binary() does send_sig(SIGKILL, current) init must die, because
| we have no option. Exec failed, but we can't return to user-space with the
| error code, it is too late.
| 

Hence the SIGKILL - I agree with this.


| So, imho this patch also fixes this case by accident,

This part I am not sure.  But as mentioned above, from_ancestor_ns is 0
and the SIGKILL will not queued right ?


| but I think it would
| be better to change load_aout_binary/etc to use force_sig_info() to make
| the code more explicit.
| 
| What do you think?
| 
| Oleg.
