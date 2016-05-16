From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH RFC 0/3] sched/fair: cpu time reserves for cgroups
Date: Mon, 16 May 2016 14:26:45 +0200
Message-ID: <20160516122645.GO3193__13139.2352087007$1463401646$gmane$org@twins.programming.kicks-ass.net>
References: <146339085068.25295.7687045977863852568.stgit@buzz>
	<20160516111849.GN3193@twins.programming.kicks-ass.net>
	<5739BB7E.8010902@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5739BB7E.8010902-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, May 16, 2016 at 03:22:22PM +0300, Konstantin Khlebnikov wrote:

> >You forgot to explain why I should care about this.
>
> As I told this works as low-limit or high-limit which allow to
> control cpu time distribution without hard limits and throttling.

That's what it does; I get that. However nothing tells me why I should
care about it. IOW, its a solution without a problem, and I tend to
ignore those -- saves a lot of time on my end.

> Present quota/hard limit has well known problems when it throttle task
> inside kernel where it holds mutexes. Also it's too strict and doesn't
> allow utilization of unused cpu time.

See; now you're starting to make sense. You cannot have a patch if you
don't have a problem. And this series didn't have a problem to solve.

As for the latter; that's a feature for many people I'm told.
