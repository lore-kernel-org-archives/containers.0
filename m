From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 2/4] signals: send_signal: use si_fromuser() to detect
	from_ancestor_ns
Date: Mon, 5 Oct 2009 19:34:01 -0700
Message-ID: <20091006023401.GA10132@us.ibm.com>
References: <4AC608BE.9020805@fr.ibm.com> <20091003171029.GA30442@us.ibm.com>
	<20091004021844.GA21006@redhat.com>
	<20091004021954.GC21006@redhat.com>
	<20091005181255.GE30442@us.ibm.com>
	<20091005182536.GA943@redhat.com>
	<20091005193738.GF30442@us.ibm.com>
	<20091005194415.GA4560@redhat.com>
	<20091006000631.GA4390@us.ibm.com>
	<20091006010956.GA28233@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091006010956.GA28233-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
| > | Sorry for confusion.
| > |
| > | > But sure, we could use force_sig_info() in caller.
| > |
| > | Yes, because this makes the code more explicit imho. And we can avoid
| > | the further complicatiions in send_signal() path.
| >
| > Although, one small drawback would be the different behavior for the
| > SIGKILL in load_aout_binary() to the container-init itself calling:
| >
| > 	kill(getpid(), SIGKILL);
| 
| could you clarify? load_aout_binary(), like other ->load_binary()
| methods does send_sig(SIGKILL, current, 0) ?

Yes sorry for being cryptic.

If we use force_sig_info() in ->load_binary() methods for the SIGKILL,
they will, correctly, kill the container-init.

But if the container-init itself calls kill(getpid(), SIGKILL), the
container-init will not be killed.

I was just pointing out the small difference in behavior for the
same signal (when we use force_sig_info()).

Thanks for fixing the bug.

Sukadev
