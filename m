From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Why is cpuset_cpus_allowed_fallback() necessary?
Date: Tue, 27 Nov 2012 19:41:17 +0100
Message-ID: <20121127184117.GA8937__39734.7946571701$1354041687$gmane$org@redhat.com>
References: <20121126223249.GB15930@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121126223249.GB15930-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Tejun,

On 11/26, Tejun Heo wrote:
>
> I'm wondering why cpuset_cpus_allowed_fallback() is necessary.  This
> is called from, e.g., try_to_wake_up()->select_task_rq() when none of
> the cpus in ->cpus_allowed is useable.  The cpuset callback invokes
> do_set_cpus_allowed() w/ the cpuset's cpus_allowed.  This was added by
> the following commit,
>
>   commit 9084bb8246ea935b98320554229e2f371f7f52fa
>   Author: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>   Date:   Mon Mar 15 10:10:27 2010 +0100
>
>
>   sched: Make select_fallback_rq() cpuset friendly
>
>   Introduce cpuset_cpus_allowed_fallback() helper to fix the cpuset problems
>   with select_fallback_rq(). It can be called from any context and can't use
>   any cpuset locks including task_lock(). It is called when the task doesn't
>   have online cpus in ->cpus_allowed but ttwu/etc must be able to find a
>   suitable cpu.
>   ....
>
> The problem is, nothing's explaining what "the cpuset problems with
> select_fallback_rq()" are.

Cough. You are right, the changelog is confusing and I no can not
understand it too.

> Oleg, do you remember?  Why do we need
> this?

No, I forgot. And this code was changed after that, the fat comment in
cpuset_cpus_allowed_fallback() tried to explain the code below which
was removed.



I am starting to recall what this patch tried to do after I looked into
git history. This patch was the last (probably) change in series.

Please look at
	897f0b3c3ff40b443c84e271bef19bd6ae885195
	sched: Kill the broken and deadlockable cpuset_lock/cpuset_cpus_allowed_locked code

In particular it removes cpuset_cpus_allowed_locked() from
select_fallback_rq() because this was very wrong. IOW, this patch
simply removes the code which didn't really work

And after some other changes, this comment tried to add the supposed
behaviour back: we shouldn't simply use cpu_possible_mask, we should
consult cpuset.

Oleg.
