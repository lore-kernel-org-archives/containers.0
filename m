From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Signals to cinit
Date: Mon, 10 Nov 2008 18:38:39 +0100
Message-ID: <20081110173839.GA11121@redhat.com>
References: <20081101180505.GA24268@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081101180505.GA24268-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On 11/01, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org wrote:
>
> Other approaches to try ?

I think we should try to do something simple, even if not perfect. Because
most users do not care about this problem since they do not use containers
at all. It would be very sad to add intrusive changes to the code.

I think we should fix another problem first. send_signal()->copy_siginfo()
path must be changed anyway, when the signal comes from the parent ns we
report the "wrong" si_code/si_pid, yes? So, somehow send_signal() must
have "bool from_parent_ns" (or whatever) annyway.

Now, let's forget forget for a moment that send_signal()->__sigqueue_alloc()
can fail.

I think we should encode this "from_parent_ns" into "struct siginfo". I do
not think it is good idea to extend this structure, I think we can introduce
SI_FROM_PARENT_NS or we perhaps can use "SI_FROMUSER(info) && info->si_pid == 0".
Or something. yes, sys_rt_sigqueueinfo() is problematic...

Now, copy_process(CLONE_NEWPID) sets child->signal |= SIGNAL_UNKILLABLE, this
protects cinit from unwanted signals. Then we change get_signal_to_deliver()

	-	if (unlikely(signal->flags & SIGNAL_UNKILLABLE) &&
	+	if (unlikely(signal->flags & SIGNAL_UNKILLABLE) && !siginfo_from_parent_ns(info)

and now we can kill cinit from parent ns. This needs more checks if we want
to stop/strace it, but perhaps this is enough for the start. Note that we
do not need to change complete_signal(), at least for now, the code under
"if (sig_fatal(p, sig)" is just optimization.


So, afaics, the only real problem is how we can handle the case when
__sigqueue_alloc() fails. I think for the start we can just return
-ENOMEM in this case (when from_parent_ns == T). Then we can improve
this behaviour. We can change complete_signal() to ensure that the
fatal signal from the upper ns always kills cinit, and in this case
we ignore the the failed __sigqueue_alloc(). This way at least SIGKILL
always works.

Yes, this is not perfect, and it is very possible I missed something
else. But simple.

Oleg.
