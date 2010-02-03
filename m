From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Kernel 2.6.33-rc6, 3 bugs container specific.
Date: Wed, 3 Feb 2010 10:21:48 -0600
Message-ID: <20100203162148.GA11738@us.ibm.com>
References: <1265074676.6260.212.camel@Mercier.safe.ca>
	<20100202031647.GA14318@fqdn.org>
	<1265121846.6260.231.camel@Mercier.safe.ca>
	<4B68649D.2000503@free.fr> <20100202181801.GA28412@us.ibm.com>
	<1265136215.6260.261.camel@Mercier.safe.ca>
	<20100202213254.GH32305@us.ibm.com> <4B695535.7020301@free.fr>
	<20100203150350.GA7146@us.ibm.com>
	<1265212090.6260.284.camel@Mercier.safe.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <lxc-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1265212090.6260.284.camel-4BUXZ/Ty1v7iqR6jatDSCA@public.gmane.org>
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

> [...]
> > > =

> > > The prink keeps writing in the global ring buffer and the syslog(2)
> > > writes to the "namespaced" ring buffer.
> > > =

> > > Does it makes sense ?
> > =

> > Yeah, it's a nice alternative.  Though (1) there is something to be sai=
d for
> > forcing a new ring buffer upon clone(CLONE_NEWUSER), and (2) assuming t=
he
> > new ring buffer is pointed to from nsproxy, it might be frowned upon to=
 do
> > an unshare/clone action in yet another way.
> > =

> > I still think our first concern should be safety, and that we should co=
nsider
> > just adding 'struct syslog_struct' to nsproxy, and making that NULL on a
> > clone(CLONE_NEWUSER).  any sys_syslog() or /proc/kmsg access returns -E=
INVAL
> > after that.  Then we can discuss whether and how to target printks to
> > namespaces, and whether duplicates should be sent to parent namespaces.
> 	/proc/kmsg=3D-EINVAL  will resolve the own HOST: ring buffer corruption
> 	not sure what sys_syslog()=3D-EINVAL mean???, rsyslog MUST be able to
> 	run within CONT: right?
> =

> 	printk namespaces duplicate and sent to parent namespace
> 	is not a good idea (duplicating&forwarding is done by tools as rsyslogd).

Heh, agreed, I just disagree that we should trust CONT to fwd stuff to
HOST, rather we should have HOST fwd stuff to CONT.

It comes down to whether HOST might need the info to determine what CONT
or someone attacking CONT is up to.  To the extend that HOST will never be
fully safe from CONT (and if you think it is, even using kvm/vmware, then
you you're deluding yourself) I think it's misguided to keep information
from HOST.

> > After we start getting flexible with syslog, the next request will be f=
or
> > audit flexibility.  I don't even know how our netlink support suffices =
for
> > that right now.
> > =

> > (So, this all does turn into a big deal...)
> > =

> > -serge
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
