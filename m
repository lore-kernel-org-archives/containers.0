From: David Stevens <dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] igmp: make /proc/net/{igmp,mcfilter} per netns
Date: Mon, 8 Sep 2008 11:17:48 -0700
Message-ID: <OFAF5F99D2.464B2693-ON882574BE.00630917-882574BE.0064824E__33865.7763124958$1220898207$gmane$org@us.ibm.com>
References: <48C4F1C6.6080605@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48C4F1C6.6080605-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
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
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
List-Id: containers.vger.kernel.org

As I've said before, I really don't like the model you're
using for multicasting here (if I understand correctly, and
I shamelessly admit I haven't looked at this code in detail).

As I understand it, you're modelling the multiple virtual interfaces
as different pieces of hardware on the same physical network.
The implication is that apps joining the same group in multiple
containers will result in multiple advertisements for the same
group, from each of the multiple instances of IGMP & MLD.

In IPv4, that's just ineffecient. In IPv6, the question is: do you have
multiple link-local addresses-- one for each virtual device?
If not, then MLD will be sending multiple copies of everything in
violation of the spec (since they'll be from the same source, too).

I think IGMP and MLD both belong with the physical interface, since
they pretty much do exactly what you want already: glom all the
different filters and group memberships together into exactly the
minimal set of group memberships needed for everyone to hear
just the pieces they've requested.

If you do that at the interface, then you won't have any duplicated
traffic on the physical net and you can separate copies as needed
for the different virtual nets on the host. Perfect, and indistinguishable
externally from a non-container machine (and the code to do it is
already in IGMP and MLD).

If you treat them as separate physical devices all the way to the
wire, then you're just needlessly increasing the host processing
you need to do, as well as loading the multicast routers and network
that are unfortunate enough to be on the same network as you are.

I haven't been paying attention, so I'll be happy if you tell me you've
already addressed this. :-) Otherwise, I think it'd be wise to do so
before it's released into the wild and can't be easily changed.

                                                +-DLS
