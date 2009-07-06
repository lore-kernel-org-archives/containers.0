From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [libvirt] Re: kernel summit topic - 'containers end-game'
Date: Mon, 6 Jul 2009 13:48:48 -0500
Message-ID: <20090706184848.GA23819@us.ibm.com>
References: <20090623145611.GB19332@us.ibm.com>
	<4A4CFEAB.5080507@cs.columbia.edu>
	<20090706143401.GA16868@us.ibm.com>
	<4A5234D1.4010805@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <libvir-list-bounces@redhat.com>
Content-Disposition: inline
In-Reply-To: <4A5234D1.4010805@cs.columbia.edu>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/libvir-list>,
	<mailto:libvir-list-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/libvir-list>
List-Post: <mailto:libvir-list@redhat.com>
List-Help: <mailto:libvir-list-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/libvir-list>,
	<mailto:libvir-list-request@redhat.com?subject=subscribe>
Sender: libvir-list-bounces@redhat.com
Errors-To: libvir-list-bounces@redhat.com
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Linux Containers <containers@lists.osdl.org>, libvir-list@redhat.com
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl@cs.columbia.edu):
> 
> 
> Serge E. Hallyn wrote:
> > Quoting Oren Laadan (orenl@cs.columbia.edu):
> >>
> >> Serge E. Hallyn wrote:
> >>> A topic on ksummit agenda is 'containers end-game and how do we
> >>> get there'.
> >>>
> >>> So for starters, looking just at application (and system) containers, what do
> >>> the libvirt and liblxc projects want to see in kernel support that is currently
> >>> missing?  Are there specific things that should be done soon to make containers
> >>> more useful and usable?
> >>>
> >>> More generally, the topic raises the question... what 'end-games' are there?
> >>> A few I can think of off-hand include:
> >>>
> >>> 	1. resource control
> >>> 	2. lightweight virtual servers
> >>> 	3. (or 2.5) unprivileged containers/jail-on-steroids
> >>> 		(lightweight virtual servers in which you might, just
> >>> 		maybe, almost, be able to give away a root account, at
> >>> 		least as much as you could do so with a kvm/qemu/xen
> >>> 		partition)
> >>> 	4. checkpoint, restart, and migration
> >>>
> >>> For each end-game, what kernel pieces do we think are missing?  For instance,
> >>> people seem agreed that resource control needs io control :)  Containers imo
> >>> need a user namespace.  I think there are quite a few network namespace
> >>> exploiters who require sysfs directory tagging (or some equivalent) to
> >>> allow us to migrate physical devices into network namespaces.  And
> >>> checkpoint/restart needs... checkpoint/restart.
> >> Heh ... it does need ... checkpoint/restart; and a few issues
> >> which we should think about sometime --
> > 
> > Yup, these are all things we need to discuss.  For some of them we might
> > just need to flail about and code a few approaches until we figure out an
> > answer, but then I think that everyone has thought about a few of these
> > in some detail, so there probably is much we could gain from talking.
> > 
> > ...  Does this mean we should try to have a mini-summit in the next 6
> > months or so?  I'd recommend having one right before kernel summit so
> > we can get our act together, but getting everyone to tokyo to chat seems
> > uneconomical :)  It'd be good to chat about at least the first two items
> > before the summit, though.
> > 
> 
> How about linux plumbers ?

Well it seems like an appropriate place for it.  Alas there is almost no chance
of my being there, but let's hear a roll call - how many people (interested in
checkpoint/restart) will be or can be at plumber's?

I'm pretty sure Suka and Dave will be there.

-serge
