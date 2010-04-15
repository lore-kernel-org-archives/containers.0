From: Brian Haley <brian.haley-VXdhtT5mjnY@public.gmane.org>
Subject: Re: [PATCH 3/4] Add IPv6 address checkpoint handler
Date: Thu, 15 Apr 2010 16:32:08 -0400
Message-ID: <4BC777C8.6050102@hp.com>
References: <1270748932-26745-1-git-send-email-danms@us.ibm.com>	<1270748932-26745-4-git-send-email-danms@us.ibm.com>	<4BC76A65.7060909@hp.com>
	<87vdbs1oty.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87vdbs1oty.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Dan Smith wrote:
> BH> Is using IFA_F_PERMANENT correct here?  Should you save the flags
> BH> from the address when checkpointing?  Permanent means it was added
> BH> by the user, not by the kernel, so you could be changing things
> BH> slightly.
> 
> Does the kernel create global scope addresses?  Maybe it does in some
> more advanced IPv6 environments, but it seemed like excluding global
> scope addresses in checkpoint meant that we only saved (and thus
> restore) the permanent ones anyway.

It adds global-scope addresses through the auto-configuration process,
i.e. by receiving a prefix in a router advertisement.

> I guess it's a better idea to just save the flags anyhow now that I
> have a way to restore them.

Yes, and I just realized something else.  This code:

+	ret = inet6_addr_add(net, dev->ifindex, &addr->inet6_addr,
+			     addr->inet6_prefix_len, IFA_F_PERMANENT,
+			     INFINITY_LIFE_TIME, INFINITY_LIFE_TIME);

isn't using the saved lifetimes either, so it won't ever go away.

And calling inet6_addr_add() isn't correct in all cases - you can
use it for manually-configured addresses (marked permanent), but
not for those added through address-autoconfiguration - for those
you'll want to use ipv6_add_addr().  But if you do that you'll
need to duplicate what's done after the add succeeds:

	ifp = ipv6_add_addr(idev, pfx, plen, addr_scope, addr_flags);

        if (!IS_ERR(ifp)) {
                spin_lock_bh(&ifp->lock);
                ifp->valid_lft = valid_lft;
                ifp->prefered_lft = prefered_lft;
                ifp->tstamp = jiffies;
                spin_unlock_bh(&ifp->lock);

                addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev,
                                      expires, flags);
                /*
                 * Note that section 3.1 of RFC 4429 indicates
                 * that the Optimistic flag should not be set for
                 * manually configured addresses
                 */
                addrconf_dad_start(ifp, 0);
                in6_ifa_put(ifp);
                addrconf_verify(0);
                return 0;
        }

That's just an example, not exactly correct.

-Brian
