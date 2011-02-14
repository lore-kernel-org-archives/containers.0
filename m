From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 1/1, v7] cgroup/freezer: add per freezer duty ratio control
Date: Mon, 14 Feb 2011 15:07:30 -0800
Message-ID: <20110214150730.058319a5.akpm__40653.5102324144$1297733939$gmane$org@linux-foundation.org>
References: <1297451444-15277-1-git-send-email-jacob.jun.pan@linux.intel.com>
	<20110212232907.GN16432@count0.beaverton.ibm.com>
	<20110214094402.4eefe70d.kamezawa.hiroyu@jp.fujitsu.com>
	<4D58A01E.9000203@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D58A01E.9000203-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
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
Cc: Cedric Le Goater <clg-DhXWPJtHtuFWk0Htik3J/w@public.gmane.org>, jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, container cgroup <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, 13 Feb 2011 19:23:10 -0800
Arjan van de Ven <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org> wrote:

> On 2/13/2011 4:44 PM, KAMEZAWA Hiroyuki wrote:
> > On Sat, 12 Feb 2011 15:29:07 -0800
> > Matt Helsley<matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>  wrote:
> >
> >> On Fri, Feb 11, 2011 at 11:10:44AM -0800, jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org wrote:
> >>> From: Jacob Pan<jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> >>>
> >>> Freezer subsystem is used to manage batch jobs which can start
> >>> stop at the same time. However, sometime it is desirable to let
> >>> the kernel manage the freezer state automatically with a given
> >>> duty ratio.
> >>> For example, if we want to reduce the time that backgroup apps
> >>> are allowed to run we can put them into a freezer subsystem and
> >>> set the kernel to turn them THAWED/FROZEN at given duty ratio.
> >>>
> >>> This patch introduces two file nodes under cgroup
> >>> freezer.duty_ratio_pct and freezer.period_sec
> >> Again: I don't think this is the right approach in the long term.
> >> It would be better not to add this interface and instead enable the
> >> cpu cgroup subsystem for non-rt tasks using a similar duty ratio
> >> concept..
> >>
> >> Nevertheless, I've added some feedback on the code for you here :).
> >>
> > AFAIK, there was a work for bandwidth control in CFS.
> >
> > http://linux.derkeiler.com/Mailing-Lists/Kernel/2010-10/msg04335.html
> >
> > I tested this and worked fine. This schduler approach seems better for
> > my purpose to limit bandwidth of apprications rather than freezer.
> 
> for our purpose, it's not about bandwidth.
> it's about making sure the class of apps don't run for a long period 
> (30-second range) of time.
> 

The discussion about this patchset seems to have been upside-down: lots
of talk about a particular implementation, with people walking back
from the implemetnation trying to work out what the requirements were,
then seeing if other implementations might suit those requirements. 
Whatever they were.

I think it would be helpful to start again, ignoring (for now) any
implementation.


What are the requirements here, guys?  What effects are we actually
trying to achieve?  Once that is understood and agreed to, we can
think about implementations.


And maybe you people _are_ clear about the requirements.  But I'm not and
I'm sure many others aren't too.  A clear statement of them would help
things along and would doubtless lead to better code.  This is pretty
basic stuff!
