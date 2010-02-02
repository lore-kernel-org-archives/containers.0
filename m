From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Kernel 2.6.33-rc6, 3 bugs container specific.
Date: Tue, 2 Feb 2010 15:32:54 -0600
Message-ID: <20100202213254.GH32305@us.ibm.com>
References: <1265074676.6260.212.camel@Mercier.safe.ca>
	<20100202031647.GA14318@fqdn.org>
	<1265121846.6260.231.camel@Mercier.safe.ca>
	<4B68649D.2000503@free.fr> <20100202181801.GA28412@us.ibm.com>
	<1265136215.6260.261.camel@Mercier.safe.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <lxc-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1265136215.6260.261.camel-4BUXZ/Ty1v7iqR6jatDSCA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/lxc-users>,
	<mailto:lxc-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=lxc-users>
List-Post: <mailto:lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:lxc-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/lxc-users>,
	<mailto:lxc-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: lxc-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Jean-Marc Pigeon <jmp-4qkeo2rQ0gg@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Jean-Marc Pigeon (jmp-4qkeo2rQ0gg@public.gmane.org):
> Hello,
> =

> =

> > =

> > I was wondering out loud about the best design to solve his problem.
> > =

> > If we try to redirect kernel-generated messages to containers, we have
> > several problems, including whether we need to duplicate the messages
> > to the host container.  So in one sense it seems more flexible to
> > 	1. send everything to host syslog
> 		No, if we do that all CONTs message will reach
> 		the same bucket and it will be difficult to sort
> 		them out..
> 		CONT sys_admin and HOST sys_admin could be different
> 		"entity", so you debug CONT config and critical
> 		needed information reach HOST (which you do not =

> 		have access to).

Yes, so a privileged task on HOST must pass that information back to
you on CONT.  That is not a valid complaint imo.  But how to sort the
msgs out is a valid question.

We need some sort of identifier, unique system-wide, attached to.. somethin=
g.
Is ifindex unique system-wide right now?  Oh, IIRC it is, but we wnat it to
be containerized, so that would be a bad choice :)

> > 	2. clamp down on syslog use by processes not in the init_user_ns
> 		Could give me more detail??...

Simplest choices would be to just refuse sys_syslog() and open(/proc/kmsg)
altogether from a container, or to only allow reading/writing messages
to own syslog.  (I had hoped to find time to try out the second option but
simply haven't had the time, and it doesn't look like I will very soon.
So if anyone else wants to, pls jump at it...)

Then /proc/kmsg can provide what I described above through a FUSE file,
and if, as you mentioned, the container unmounts the FUSE fs and gets
to real procfs, they just get nothing.

> > 	3. let the userspace on the host copy messages into a socket or
> > 	   file so child container can pretend it has real syslog.
> =

> 		So you trap printk message from CONT on the HOST and =

> 		redirect them on CONT but on a standard syslog channel.
> 		Seem OK to me, as long /proc/kmsg is not existing
> 		(/dev/null) in the CONT file tree.
> 		=

> -- =

> A bient=F4t
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> Jean-Marc Pigeon                                   Internet: jmp-4qkeo2rQ0gg@public.gmane.org
> SAFE Inc.                                          Phone: (514) 493-4280
>                                                    Fax:   (514) 493-1946
>         Clement, 'a kiss solution' to get rid of SPAM (at last)
>            Clement' Home base <"http://www.clement.safe.ca">
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

---------------------------------------------------------------------------=
---
The Planet: dedicated and managed hosting, cloud storage, colocation
Stay online with enterprise data centers and the best network in the busine=
ss
Choose flexible plans and management services without long-term contracts
Personal 24x7 support from experience hosting pros just a phone call away.
http://p.sf.net/sfu/theplanet-com
