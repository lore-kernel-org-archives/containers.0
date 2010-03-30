From: Brian Haley <brian.haley-VXdhtT5mjnY@public.gmane.org>
Subject: Re: [PATCH 1/2] C/R: Support for IPv6 addresses on network devices
Date: Tue, 30 Mar 2010 13:05:55 -0400
Message-ID: <4BB22F73.60704@hp.com>
References: <1269459625-21033-1-git-send-email-danms@us.ibm.com>	<1269459625-21033-2-git-send-email-danms@us.ibm.com>	<4BABC967.5090908@hp.com>
	<87aatwf74u.fsf@caffeine.danplanet.com>	<4BABD594.1020301@hp.com>
	<87634jf63u.fsf@caffeine.danplanet.com>	<4BB21A45.4050300@hp.com>
	<87zl1peqd4.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87zl1peqd4.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
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
> BH> Can I ask what the addresses were?
> 
> I'm not sure what you mean.  You want to know what the duplicated
> address was?  My flawed byteorder adjustment caused me to have two
> fe80::X addresses on the restored interface.

Ok, I was wondering if you had two link-locals because when you moved
from machine to machine the MAC changed.

> I've since added a check to ignore non-global scope addresses, which
> works nicely.

Well, in most cases you could ignore the global addresses as well,
since if they were auto-configured they'll be generated again on
the next Router Advertisement.  That's why they're removed on
an ifdown, but the permanent ones aren't (any more).

> BH> Did you move from VM to VM so the underlying NIC MAC address
> BH> changed?
> 
> No, the MAC doesn't change because I reconstruct the interface on the
> other side with the original MAC address.  The netns and netdev code
> assume that you're migrating your entire network namespace, which
> includes all the devices within.

Ok, I forgot about the underlying device being moved as well, that
makes sense.

> BH> Again, I don't know your typical user for C/R.  For example, with
> BH> IPv4 you save all the addresses, but if one of them was configured
> BH> via DHCP, you could have an address conflict when you restore it,
> BH> since there's no way to know if it's been handed-out to another
> BH> system in the meantime.  Or does a typical C/R user only have
> BH> static addresses?
> 
> I think that the expectation is that if you're migrating network
> connections, you are going to have to be in your own netns and have
> your own interface.  If DHCP is in play, then you're going to be
> migrating dhclient along with your app anyway.

Ok, so dhclient6 too :)

> BH> With IPv6 it gets worse because the link-local will get created
> BH> automatically, and if you're in a VM it will probably be somewhat
> BH> random.  Then when you move to another VM you'll get another
> BH> virtual NIC with a different MAC address.  Since the global
> BH> address is going to be based off the same lower 64-bits, you'll
> BH> wind-up with a second global in most situations (since you're
> BH> restoring the original address).
> 
> Well, I'm not sure of your use of "VM" in this case.  I think the
> typical usage here will be a container that behaves like a VM.  As I
> said above, you'll have your own virtual interface and your MAC
> address will go with you.

Yeah, I'm just using the wrong terminology sometimes, like you said,
it's a container behaving like a VM.

-Brian
