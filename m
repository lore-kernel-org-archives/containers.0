From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: [ProbableSpam]Re: [PATCH 2/5] Container Freezer: Make
	refrigerator always available
Date: Wed, 13 Aug 2008 16:31:48 +0200
Message-ID: <200808131631.49889.rjw__45989.307788159$1218652888$gmane$org@sisk.pl>
References: <20080811235323.872291138@us.ibm.com>
	<200808122249.27553.rjw@sisk.pl>
	<1218589300.19008.135.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1218589300.19008.135.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wednesday, 13 of August 2008, Matt Helsley wrote:
> 
> On Tue, 2008-08-12 at 22:49 +0200, Rafael J. Wysocki wrote:
> > On Tuesday, 12 of August 2008, Matt Helsley wrote:
> > > Now that the TIF_FREEZE flag is available in all architectures,
> > > extract the refrigerator() and freeze_task() from kernel/power/process.c
> > > and make it available to all.
> > > 
> > > The refrigerator() can now be used in a control group subsystem
> > > implementing a control group freezer.
> > > 
> > > Signed-off-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> > > Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > > Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > > Tested-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > 
> > Your Signed-off-by implies your Tested-by (at least it should ;-)).
> 
> I wasn't sure that was always true so I added it just in case. I'll take
> it out of any future postings.
> 
> > > ---
> > [--snip--]
> > > Index: linux-2.6.27-rc1-mm1/kernel/power/Kconfig
> > > ===================================================================
> > > --- linux-2.6.27-rc1-mm1.orig/kernel/power/Kconfig
> > > +++ linux-2.6.27-rc1-mm1/kernel/power/Kconfig
> > > @@ -85,6 +85,9 @@ config PM_SLEEP
> > >  	depends on SUSPEND || HIBERNATION || XEN_SAVE_RESTORE
> > >  	default y
> > >  
> > > +config FREEZER
> > > +	def_bool PM_SLEEP
> > > +
> > 
> > I'd still prefer this to go into a Kconfig in the parent directory (ie. where
> > freezer.c and the Makefile building it are located).  Otherwise it's guaranteed
> > to confuse someone.
> 
> 	I'm thinking of making a patch moving the cgroups config variables into
> a kernel/Kconfig.cgroups file. Would moving config FREEZER to such a
> file be satisfactory? Paul, what do you think?

Well, in fact FREEZER is not directly dependent on cgroups, as it can also
depend on PM_SLEEP, even if cgroups are not used at all.

I would just add 'Kconfig.freezer' to 'kernel', put 'config FREEZER' in there
and make it depend on whatever needs it.  Of course,
'source "kernel/Kconfig.freezer"' would have to be added to top-level
Kconfigs for all architectures, but please note that only a few architectures
include 'kernel/power/Kconfig', so you'd have to change the top-level
Kconfigs anyway.

Alternatively, you can just add 'config FREEZER' directly to the top-level
Kconfigs.

Thanks,
Rafael
