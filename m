From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: kernel summit topic - 'containers end-game'
Date: Tue, 7 Jul 2009 11:14:40 -0500
Message-ID: <20090707161440.GA16152@us.ibm.com>
References: <20090623145611.GB19332@us.ibm.com>
	<4A4CFEAB.5080507@cs.columbia.edu>
	<20090706143401.GA16868@us.ibm.com>
	<4A5234D1.4010805@cs.columbia.edu>
	<20090706184848.GA23819@us.ibm.com>
	<4A536B91.5010205@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A536B91.5010205-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> 
> Serge E. Hallyn wrote:
> > Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> >>
> >> Serge E. Hallyn wrote:
> >>> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> >>>> Serge E. Hallyn wrote:
> >>>>> A topic on ksummit agenda is 'containers end-game and how do we
> >>>>> get there'.
> >>>>>
> >>>>> So for starters, looking just at application (and system) containers, what do
> >>>>> the libvirt and liblxc projects want to see in kernel support that is currently
> >>>>> missing?  Are there specific things that should be done soon to make containers
> >>>>> more useful and usable?
> >>>>>
> >>>>> More generally, the topic raises the question... what 'end-games' are there?
> >>>>> A few I can think of off-hand include:
> >>>>>
> >>>>> 	1. resource control
> >>>>> 	2. lightweight virtual servers
> >>>>> 	3. (or 2.5) unprivileged containers/jail-on-steroids
> >>>>> 		(lightweight virtual servers in which you might, just
> >>>>> 		maybe, almost, be able to give away a root account, at
> >>>>> 		least as much as you could do so with a kvm/qemu/xen
> >>>>> 		partition)
> >>>>> 	4. checkpoint, restart, and migration
> >>>>>
> >>>>> For each end-game, what kernel pieces do we think are missing?  For instance,
> >>>>> people seem agreed that resource control needs io control :)  Containers imo
> >>>>> need a user namespace.  I think there are quite a few network namespace
> >>>>> exploiters who require sysfs directory tagging (or some equivalent) to
> >>>>> allow us to migrate physical devices into network namespaces.  And
> >>>>> checkpoint/restart needs... checkpoint/restart.
> >>>> Heh ... it does need ... checkpoint/restart; and a few issues
> >>>> which we should think about sometime --
> >>> Yup, these are all things we need to discuss.  For some of them we might
> >>> just need to flail about and code a few approaches until we figure out an
> >>> answer, but then I think that everyone has thought about a few of these
> >>> in some detail, so there probably is much we could gain from talking.
> >>>
> >>> ...  Does this mean we should try to have a mini-summit in the next 6
> >>> months or so?  I'd recommend having one right before kernel summit so
> >>> we can get our act together, but getting everyone to tokyo to chat seems
> >>> uneconomical :)  It'd be good to chat about at least the first two items
> >>> before the summit, though.
> >>>
> >> How about linux plumbers ?
> > 
> > Well it seems like an appropriate place for it.  Alas there is almost no chance
> > of my being there, but let's hear a roll call - how many people (interested in
> > checkpoint/restart) will be or can be at plumber's?
> > 
> > I'm pretty sure Suka and Dave will be there.
> 
> Seems like I can make it.

Alexey, are you planning on being at the plumber's conf this year?

-serge
