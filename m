From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [patch 1/2][NETNS][RFD] store the network namespace pointer in
	the dst_entry structure
Date: Tue, 11 Dec 2007 08:52:24 -0700
Message-ID: <m1r6htz0sn.fsf@ebiederm.dsl.xmission.com>
References: <20071211131231.701104221@ICON-9-164-138-215.megacenter.de.ibm.com>
	<20071211131749.644219049@ICON-9-164-138-215.megacenter.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071211131749.644219049-K1HbUr/PGdchrHDkVdNya89sqxeZRdF2IBfkmQ/nkib1ENwx4SLHqw@public.gmane.org>
	(Daniel Lezcano's message of "Tue, 11 Dec 2007 14:12:32 +0100")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: xemul-3ImXcnM4P+0@public.gmane.org, den-3ImXcnM4P+0@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, benjamin.thery-6ktuUTfB/bM@public.gmane.org
List-Id: containers.vger.kernel.org

Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:

> Store the network namespace pointer in the dst_entry structure when it is
> allocated. 
> The different protocols redefine the route object as a derivate object from
> dst_entry. So using the dst_entry to store the network namespace pointer will
> allow to take into account the ipv4, ipv6, dccp protocols in one shot through
> the different route objects, rtable, rt6_info, ...
>
> ---
>  include/net/dst.h      |    3 ++-
>  net/core/dst.c         |    3 ++-
>  net/decnet/dn_route.c  |    4 ++--
>  net/ipv4/route.c       |   14 +++++++-------
>  net/ipv6/route.c       |   18 ++++++++++--------
>  net/xfrm/xfrm_policy.c |    2 +-
>  6 files changed, 24 insertions(+), 20 deletions(-)
>
> Index: linux-2.6-netns/include/net/dst.h
> ===================================================================
> --- linux-2.6-netns.orig/include/net/dst.h
> +++ linux-2.6-netns/include/net/dst.h
> @@ -81,6 +81,7 @@ struct dst_entry
>  		struct dn_route  *dn_next;
>  	};
>  	char			info[0];
> +	struct net		*net;

Unless I'm missing something you just place that net pointer in
the middle of a variable length array.  Weird I don't see us
using that array.

Could you please place the struct net *net pointer up by the
network device pointer.
>  };

I know we need a net pointer in struct rt_table, because it
is a hash table that we can't dynamically allocate so we need
to place a network namespace pointer as part of the hash key.

For the ipv6 fib tables I don't recall needing a net pointer 
as we didn't have a hash table and could instead have separate
roots for different namespaces.

I find this slightly odd as I didn't wind up needing to add
a struct net pointer in struct dst in my proof of concept tree
and struct dst doesn't have a struct flowi so that would not
have prevented it.

Eric
