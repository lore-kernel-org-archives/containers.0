From: Max Krasnyansky <maxk-zC7DfRvBq/JWk0Htik3J/w@public.gmane.org>
Subject: Re: v2.6.26-rc7/cgroups: circular locking dependency
Date: Mon, 23 Jun 2008 23:29:21 -0700
Message-ID: <48609441.2030901__102.646955247288$1214289076$gmane$org@qualcomm.com>
References: <20080621173859.GA6846@damson.getinternet.no>	
	<2f11576a0806220834m3572ee80i72229cb9a1613558@mail.gmail.com>
	<1214149823.3223.313.camel@lappy.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1214149823.3223.313.camel-N9Ixq/CQ5vKdTX5a5knrm8zTDFooKrT+cvkQGrU6aU0@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Cc: Vegard Nossum <vegard.nossum-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Peter Zijlstra wrote:
> On Mon, 2008-06-23 at 00:34 +0900, KOSAKI Motohiro wrote:
>> CC'ed Paul Jackson
>>
>> it seems typical ABBA deadlock.
>> I think cpuset use cgrou_lock() by mistake.
>>
>> IMHO, cpuset_handle_cpuhp() sholdn't use cgroup_lock() and
>> shouldn't call rebuild_sched_domains().
> 
> Looks like Max forgot to test with lockdep enabled... 
Hmm, I don't think I actually changed any lock nesting/dependencies. Did I ?
Oh, I see rebuild_sched_domains() is now called from cpuset hotplug handler.
I just looked at the comment for rebuild_sched_domains() and it says
" * Call with cgroup_mutex held. ..." that's why I thought it's safe and it
worked on the test stations.

Anyway, we need definitely need to make rebuild_sched_domains() work from the
hotplug handler.

> Well, someone should when you change the online map.
> 
> Max, Paul, can we handle this in update_sched_domains() instead?

That'd be exactly the same as calling rebuild_sched_domains() outside of the
cgroup_lock(). So I do not think it'll help. Paul has more info in his reply
so I'll reply to his email.

Max
