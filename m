From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/6][v5] Protect cinit from unblocked SIG_DFL signals
Date: Mon, 5 Jan 2009 14:24:07 +0100
Message-ID: <20090105132407.GC3313@redhat.com>
References: <20081227204658.GA27197@us.ibm.com>
	<20081227205319.GC27337@us.ibm.com>
	<20081231001942.F35E2FC278@magilla.sf.frob.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081231001942.F35E2FC278-nL1rrgvulkc2UH6IwYuUx0EOCMrvLtNR@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On 12/30, Roland McGrath wrote:
>
> I'd just make the flag a parameter to send_signal() directly.
> Then you can just change kill_pid_info_as_uid (or its replacement)
> to call send_signal() with that new flag (and the 'group' flag)
> directly instead of using the trivial __group_send_sig_info wrapper.

Ah, good. Can't understand why I didn't think about this before!

But, perhaps, it is better to add the new helper, __send_signal()
or whatever which has the new "from_ancestor_ns" argument. Then,

	static int send_signal(...)
	{
		bool from_ancestor_ns = 0;

	#ifdef CONFIG_PID_NS
		if (!is_si_special(info) && SI_FROMUSER(info)) {
			from_ancestor_ns = !task_pid_nr_ns(current, task_active_pid_ns(t));
		}
	#endif

		return __send_signal(..., from_ancestor_ns);
	}

but this is cosmetic issue.

Oleg.
