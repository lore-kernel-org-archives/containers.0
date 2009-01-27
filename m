From: KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Tue, 27 Jan 2009 19:40:58 +0900 (JST)
Message-ID: <20090127193058.D48B.KOSAKI.MOTOHIRO__9810.99474379352$1233053073$gmane$org@jp.fujitsu.com>
References: <alpine.DEB.2.00.0901262350110.14525@chino.kir.corp.google.com>
	<20090127093105.GB2646@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090127093105.GB2646-i6C2adt8DTjR7s880joybQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>
Cc: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arve Hj?nnev?g <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Chris Snook <csnook-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Evgeniy,

> On Mon, Jan 26, 2009 at 11:51:27PM -0800, David Rientjes (rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org) wrote:
> > Yeah, I proposed /dev/mem_notify being made as a client of cgroups there 
> > in http://marc.info/?l=linux-kernel&m=123200623628685
> > 
> > How do you replace the oom killer's capability of giving a killed task 
> > access to memory reserves with TIF_MEMDIE in userspace?
> 
> /dev/mem_notify is a great idea, but please do not limit existing
> oom-killer in its ability to do the job and do not rely on application's
> ability to send a SIGKILL which will not kill tasks in unkillable state
> contrary to oom-killer.

I'd like to respect your requiremnt. but I also would like to know
why you like deterministic hierarchy oom than notification.

I think one of problem is, current patch description is a bit poor
and don't describe from administrator view.

Could you please sort the discssion out and explain your requirement detail?
otherwise (I guess) this discussion don't reach people agreement.

I don't like the implementation idea vs another idea discussion.
it often don't make productive discussion.
I'd like to sort out people requrement.
otherwise I can't review the patch fill requirement or not.
