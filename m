From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Devel] OLS paper topics
Date: Wed, 30 Jan 2008 09:40:43 -0600
Message-ID: <20080130154043.GB1206@sergelap.austin.ibm.com>
References: <20080123195736.GA7823@sergelap.austin.ibm.com>
	<47990BAB.4050106@openvz.org>
	<20080124225002.GC13819@sergelap.austin.ibm.com>
	<47A03A73.6070408@openvz.org> <47A03C25.8030205@linux.vnet.ibm.com>
	<20080130104336.GD3862@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080130104336.GD3862-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Kir Kolyshkin <kir-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Dhaval Giani (dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> On Wed, Jan 30, 2008 at 02:28:13PM +0530, Balbir Singh wrote:
> > Kir Kolyshkin wrote:
> > > Serge E. Hallyn wrote:
> > >> Quoting Kir Kolyshkin (kir-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org):
> > >>  
> > >>> Serge E. Hallyn wrote:
> > >>>    
> > >>>> mini-summit:
> > >>>>     I will submit for a 1-day mini-summit.  Some interesting
> > >>>>     remaining topics for the mini-summit would include device
> > >>>>     namespaces, ttys and syslog, and lots of checkpoint/restart.
> > >>>>         
> > >>> That's right, obviously the title of the mini-summit would be something
> > >>> like "Linux Kernel Containers".
> > >>>     
> > >>
> > >> Attached is what I currently had for a proposal to send to the OLS
> > >> committee.  (Please feel free to edit and add to the wiki)
> > >>   
> > > 
> > > Some people have made a few minor changes in the version at wiki. I
> > > guess no more major changes will be done. Here it is:
> > > 
> > > == Topic ==
> > > 
> > > Namespaces, containers, cgroups, and container checkpoint/restart.
> > > 
> > > == Description ==
> > > 
> > > Development for namespaces and cgroups is well underway in the
> > > mainline kernel. To keep momentum going and keep the loosely
> > > knit teams of developers well-coordinated, a physical meeting in
> > > which to discuss future development plans is needed.
> > > Additionally, we are at a point where crucial decisions about
> > > the nature of a "container object" and about the checkpoint/restart
> > > design need to be made.
> > > 
> > > A final set of topics will be decided upon through mailing lists
> > > ahead of time, but potential topics include:
> > > * Handling filesystem/namespace synchronization
> > > * Handling of /proc and /sysfs within containers
> > > * Additional needed namespaces (i.e. device namespace)
> > > * Nature of a 'container' ??? kernel object or userspace fiction
> > > * Additional cgroups and their design
> > > * How to initiate and synchronize checkpoint/restart
> > > * How to enter a 'container' ?
> > > 
> > 
> > Resource Management for containers?
> > 
> > > == Moderators ==
> > > {{Out|These are just suggestions, please edit here or let us know if you
> > > do or do not want to moderate.}}
> > > 
> > > * Namespaces/containers: Serge Hallyn, Cedric Le Goater
> > > * cgroups: Paul Menage
> > > * Checkpoint/restart: Dave Hansen, Cedric Le Goater
> > > 
> > 
> > Resource Management? - I don't mind moderating that if it happens to be
> > included in the summit or can we merge it with cgroups?
> > 
> 
> I don't mind helping out here. Could you add me to the list as well?

Ok I figured resource mgmt and cgroups would be combined, but I'm fine
splitting them.  So can I do:

cgroups: Paul Menage, Balbir
Resource Management: dhaval, someone from openvz (Pavel?)

?

thanks,
-serge
