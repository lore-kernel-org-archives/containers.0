From: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/6] Makes procs file writable to move all threads by tgid
	at once
Date: Fri, 7 Aug 2009 18:41:21 -0700
Message-ID: <2f86c2480908071841h13009856hd8fcae167b1fadbf__14612.8771514215$1249695816$gmane$org@mail.gmail.com>
References: <20090803194555.GA10158@us.ibm.com>
	<6599ad830908041228w67bc6f7fh57e28f244e1923b3@mail.gmail.com>
	<20090805102057.GT29252@hawkmoon.kerlabs.com>
	<6599ad830908050911t6f23f810i65fe8fe17f3ee698@mail.gmail.com>
	<20090805164218.GB26446@hawkmoon.kerlabs.com>
	<2f86c2480908051701s57120404q475edbedb58cdca1@mail.gmail.com>
	<20090806095854.GD26446@hawkmoon.kerlabs.com>
	<6599ad830908060328y21a008c1pc5ed5c27e0ec905d@mail.gmail.com>
	<20090806112450.GF26446@hawkmoon.kerlabs.com>
	<6599ad830908060440g2f6cbed6xdc54c7096cd3745e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830908060440g2f6cbed6xdc54c7096cd3745e-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Aug 6, 2009 at 4:40 AM, Paul Menage<menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> On Thu, Aug 6, 2009 at 4:24 AM, Louis Rilling<Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org> wrote:
>>
>> You meant signal_struct, right? sighand_struct can be shared by several
>> thread groups, while signal_struct can't.
>>
>
> No, I meant sighand_struct. I realise that it *can* be shared between
> processes, but I didn't think that NPTL actually did so. (Are there
> common cases of this happening?) And in cases where it was shared, it
> wouldn't affect correctness, but simply create the potential for a
> little more contention.
>
> I agree that signal_struct might in principle be a better place for
> it, but the first cacheline of signal_struct appears to be occupied
> with performance-sensitive things (a couple of counters and a queue
> used in do_wait()) already, whereas the first cacheline of
> sighand_struct only appears to be used incremented/decremented during
> fork/exit, and when delivering a bunch of mostly-fatal signals.
>
> But having said that, if having it in signal_struct isn't considered a
> potential performance hit, it would be fine there too.
>
> Paul
>

I'm presently rewriting the locking scheme here to have the rwsem live
in sighand_struct, and writing two new functions lock_threadgroup_fork
and unlock_threadgroup_fork (for use in cgroup_attach_proc) which will
live in cgroup.c but are generic enough that they could be used by
anybody who wants to do threadgroup-wide fork-sensitive changes. I'm
also having the fork_lock under an #ifdef CONFIG_CGROUPS, which could
be expanded to, say, CONFIG_FORK_LOCK_THREADGROUP (which CGROUPS would
depend upon) if somebody else ever wanted to use this lock as well.
For genericness, I'll have the down_read and up_read on the lock in
do_fork() directly (instead of cgroup_fork and cgroup_post_fork as it
is in this version of the patch).

If there are no more comments/discussion on the locking scheme, I'll
resubmit the patch series with these changes approximately Monday.
