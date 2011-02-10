From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1, v6] cgroup/freezer: add per freezer duty ratio control
Date: Thu, 10 Feb 2011 11:11:17 -0800
Message-ID: <20110210191117.GI16432__26240.4019864791$1297365209$gmane$org@count0.beaverton.ibm.com>
References: <1297213541-18156-1-git-send-email-jacob.jun.pan@linux.intel.com>
	<20110210030442.GG16432@count0.beaverton.ibm.com>
	<4D535627.9090606@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D535627.9090606-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Arjan van de Ven <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Cc: Cedric Le Goater <clg-DhXWPJtHtuFWk0Htik3J/w@public.gmane.org>, jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, container cgroup <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Wysocki Rafael Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>, rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Feb 09, 2011 at 07:06:15PM -0800, Arjan van de Ven wrote:
> On 2/9/2011 7:04 PM, Matt Helsley wrote:
> >On Tue, Feb 08, 2011 at 05:05:41PM -0800, jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org wrote:
> >>From: Jacob Pan<jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> >>
> >>Freezer subsystem is used to manage batch jobs which can start
> >>stop at the same time. However, sometime it is desirable to let
> >>the kernel manage the freezer state automatically with a given
> >>duty ratio.
> >>For example, if we want to reduce the time that backgroup apps
> >>are allowed to run we can put them into a freezer subsystem and
> >>set the kernel to turn them THAWED/FROZEN at given duty ratio.
> >>
> >>This patch introduces two file nodes under cgroup
> >>freezer.duty_ratio_pct and freezer.period_sec
> >>
> >>Usage example: set period to be 5 seconds and frozen duty ratio 90%
> >>[root@localhost aoa]# echo 90>  freezer.duty_ratio_pct
> >>[root@localhost aoa]# echo 5000>  freezer.period_ms
> >I kept wondering how this was useful when we've got the "cpu" subsystem
> >because for some reason "duty cycle" made me think this was a scheduling
> >policy knob. In fact, I'm pretty sure it is -- it just happens to
> >sometimes reduce power consumption.
> >
> >Have you tried using the cpu cgroup subsystem's share to see if it can
> >have a similar effect?
> 
> does the cpu cgroup system work on a 20 to 30 second time window?

I don't think so -- it works directly with the scheduler IIRC.

> the objective is to have the CPU idle, without wakeups, for that long...
> (to save power)

Hmm. Maybe these need some "scheduler slack" so that when they're
runnable they'll either run with other scheduled entities that are
keeping the cpu awake or wait until the slack runs out before doing
a wakeup. Then you can toss this in the cgroup timer slack subsystem
and rename it to the "wakeup slack" subsystem or something. That
will probably get you better race-to-idle behavior, avoid/reduce 
latencies added by duty cycles, and avoid shoehorning into the cgroup
freezer subsystem. Of course it would require some scheduler hacking
which will probably be much more controversial than modifying a cgroup
subsystem :).

Cheers,
	-Matt Helsley
