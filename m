From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Kernel 2.6.33-rc6, 3 bugs container specific.
Date: Tue, 2 Feb 2010 12:18:01 -0600
Message-ID: <20100202181801.GA28412@us.ibm.com>
References: <1265074676.6260.212.camel@Mercier.safe.ca>
	<20100202031647.GA14318@fqdn.org>
	<1265121846.6260.231.camel@Mercier.safe.ca>
	<4B68649D.2000503@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lxc-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B68649D.2000503-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/lxc-users>,
	<mailto:lxc-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=lxc-users>
List-Post: <mailto:lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:lxc-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/lxc-users>,
	<mailto:lxc-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: lxc-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
> Jean-Marc Pigeon wrote:
> > Hello,
> >
> > On Tue, 2010-02-02 at 04:16 +0100, Michael Holzt wrote:
> >   
> >>> 	Tried 2.6.33-rc6 to check container, 3 bugs show up.
> >>> 	(test done on x86_64, Pentium(R) Dual-Core CPU E5400)
> >>>       
> >> I guess this should better go on the containers mailing list,
> >> as this are kernel related problems?
> >>     
> >
> > 	Yes, you are right....I'll do it.
> >
> > 	Problem with /proc/kmsg (bug #3) is a very real
> > 	concern, Daniel Lezcano proposed a solution
> > 	(using fuse), but I think this solution is
> > 	just a patch (container sys-admin can override 
> > 	it, putting the whole system in total jeopardy).
> >
> > 	Seems kernel team is very reluctant to make 
> > 	the K ring buffer virtual but I see no other
> > 	solution (used already in openVZ).
> >   
> 
> Maybe I missed something, but AFAIR Serge Hallyn was willing to do this, 
> no ?
> Or there was a nack from someone ?

I was wondering out loud about the best design to solve his problem.

If we try to redirect kernel-generated messages to containers, we have
several problems, including whether we need to duplicate the messages
to the host container.  So in one sense it seems more flexible to
	1. send everything to host syslog
	2. clamp down on syslog use by processes not in the init_user_ns
	3. let the userspace on the host copy messages into a socket or
	   file so child container can pretend it has real syslog.

-serge

------------------------------------------------------------------------------
The Planet: dedicated and managed hosting, cloud storage, colocation
Stay online with enterprise data centers and the best network in the business
Choose flexible plans and management services without long-term contracts
Personal 24x7 support from experience hosting pros just a phone call away.
http://p.sf.net/sfu/theplanet-com
