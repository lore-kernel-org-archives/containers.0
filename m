From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH 0/6][v3] Container-init signal semantics
Date: Mon, 22 Dec 2008 16:27:32 -0800
Message-ID: <m1aban68i3.fsf@frodo.ebiederm.org>
References: <20081221005106.GA4912@us.ibm.com>
	<m1wsds5vij.fsf@frodo.ebiederm.org> <20081222194737.GC9085@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081222194737.GC9085-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Sukadev Bhattiprolu's message
	of "Mon, 22 Dec 2008 11:47:37 -0800")
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:

> Eric W. Biederman [ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org] wrote:
>
> | 
> | - container-init is responsible for setting the rest of the signals
> |   to SIG_IGN.
>
> Oleg pointed out that we could drop SIG_DFL signals to global init early
> to ensure wait_for_completion_killable/lock_page_killable don't incorrectly
> believe that a fatal signal is pending. (patch 2/6).
>
> If that patch is valid regardless of containers, it would be a minor
> extension to get container-inits to drop SIG_DFL signals too, right ?

Yes.

> So the bigger problem/unknown for me is the sig_from_user() in patch 4/6
> (i.e determining if it safe to deref the pid-ns of sender). We went from
> !in_interrupt() to the SIG_FROM_USER flag to this.
>
> If that is correct, I am hoping it would come down to opitmizing the code
> if possible (eg: can/should we avoid passing same_ns into sig_ignored()
>
> There is probably some ugliness :-) but do you see any other correctness 
> issues ?

I haven't dug in too deep but right now my concern are user space semantics,
I don't want to wind up with something ugly there because we can not change
it later.

So if we can write a description of what happens to signals to cinit
that is right 100% of the time.  Something we can write a test case
for that tests all of the corner cases and it always get the same
results. I am happy.

I don't mind dropping signals early as an optimization, but if it
is just an optimization we can't count on it in cinit.

So I would rather deliver less and make user space deal with it,
then deliver more cause problems for user space.

Eric
