From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: [PATCH 0/6] Container Freezer: Reuse Suspend Freezer
Date: Fri, 1 Aug 2008 15:04:02 +0200
Message-ID: <200808011504.03251.rjw__4246.57340995527$1217596047$gmane$org@sisk.pl>
References: <20080801050659.924495279@us.ibm.com>
	<1217567816.25300.197.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1217567816.25300.197.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Friday, 1 of August 2008, Matt Helsley wrote:
> 
> On Thu, 2008-07-31 at 22:06 -0700, Matt Helsley wrote:
> > This patch series introduces a cgroup subsystem that utilizes the swsusp
> > freezer to freeze a group of tasks. It's immediately useful for batch job
> > management scripts. It should also be useful in the future for implementing
> > container checkpoint/restart.
> 
> <snip>
> 
> > Andrew, since I hear Rafael doesn't have time to review these (again) at this
> > time, please consider these patches for -mm.
> 
> 	Argh -- that "(again)" is ripe for misinterpretation! Rafael has
> reviewed and commented on these patches often in the past but, from what
> I hear, lacks the time to do so now. Hence I'm sending these to -mm.
> 
> 	Sorry about the wording Rafael.

No problem.

If there are not too many new regressions reported today, I'll have a look at
the patches in the evening.

Thanks,
Rafael
