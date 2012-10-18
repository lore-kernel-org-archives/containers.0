From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Is not locking task_lock in cgroup_fork() safe?
Date: Thu, 18 Oct 2012 22:53:47 +0200
Message-ID: <CAFTL4hy7g4e11OUOyoihrEU8hiVgZoV1=141UtUpj9a72SNs_Q@mail.gmail.com>
References: <20121008020000.GB2575@localhost>
	<CAFTL4hzXWtzp7megsCAEuak5=_2SWmp9age-+wrpyQAU4BRZ0w@mail.gmail.com>
	<20121016193341.GD16166@google.com>
	<CAFTL4hzo_w7HTgC9ApTk113X8WdZSpV+D+VSEe=604YEJFmKsg@mail.gmail.com>
	<20121018200705.GG13370@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121018200705.GG13370-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

2012/10/18 Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>:
> Hello, Frederic.
>
> On Thu, Oct 18, 2012 at 04:50:59PM +0200, Frederic Weisbecker wrote:
>> Ah right I was confused. Hmm, indeed we have a race here on
>> cgroup_fork(). How about using css_try_get() in cgroup_fork() and
>> refetch the parent's css until we succeed? This requires rcu_read_lock
>> though, and freeing the css_set under RCU.
>>
>> Don't know which is better.
>
> For now, I'll revert the patches and cc stable.  Let's think about
> improving it later.

Ok for reverting in cgroup_fork(). Is it necessary for the
cgroup_post_fork() thing? I don't immediately see any race involved
there.

>> Different problem but I really would like we sanitize the cgroup hooks
>> in fork. There is cgroup_fork(), cgroup_post_fork() which takes that
>> big css_set_lock, plus the big threadgroup lock... I hope we can
>> simplify the mess there.
>
> Oh yeah, I've been looking at that one too.  There are a few problems
> in that area.  I think all we need is clearing ->cgroups to NULL on
> copy_process() and all the rest can be moved to cgroup_post_fork().
> I'd also like to make it very explicit that migration can't happen
> before post_fork is complete.

Sounds right.

>
>> > I really don't know.  Why isn't it locking the threadgroup to begin
>> > with?
>>
>> No idea, sounds like something to fix.
>
> Alrighty.

Ok thanks.

> Thanks.
>
> --
> tejun
