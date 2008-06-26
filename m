From: Max Krasnyansky <maxk-zC7DfRvBq/JWk0Htik3J/w@public.gmane.org>
Subject: Re: v2.6.26-rc7/cgroups: circular locking dependency
Date: Thu, 26 Jun 2008 10:45:02 -0700
Message-ID: <4863D59E.3070604__5196.60987561128$1214502440$gmane$org@qualcomm.com>
References: <20080621173859.GA6846@damson.getinternet.no>	
	<2f11576a0806220834m3572ee80i72229cb9a1613558@mail.gmail.com>	
	<1214149823.3223.313.camel@lappy.programming.kicks-ass.net>	
	<48609441.2030901@qualcomm.com>
	<6599ad830806260025u27458a47j47175ad778ca48a9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830806260025u27458a47j47175ad778ca48a9-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, Vegard Nossum <vegard.nossum-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> Second idea - can we just punt the call to rebuild_sched_domains() to
> a workqueue thread if it's due to a flag or cpumask change? Does it
> matter if the call doesn't happen synchronously? The work handler
> could easily nest the cgroup_lock() call inside get_online_cpus() and
> then call rebuild_sched_domains()

I was thinking about exactly the same thing. I kind of don't like async 
nature of it. Maybe it's ok but there might be some interesting races 
with async domain updates.

Max
