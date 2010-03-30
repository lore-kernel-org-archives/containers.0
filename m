From: Brian Haley <brian.haley-VXdhtT5mjnY@public.gmane.org>
Subject: Re: [PATCH 1/2] C/R: Support for IPv6 addresses on network devices
Date: Tue, 30 Mar 2010 11:35:33 -0400
Message-ID: <4BB21A45.4050300@hp.com>
References: <1269459625-21033-1-git-send-email-danms@us.ibm.com>	<1269459625-21033-2-git-send-email-danms@us.ibm.com>	<4BABC967.5090908@hp.com>
	<87aatwf74u.fsf@caffeine.danplanet.com>	<4BABD594.1020301@hp.com>
	<87634jf63u.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87634jf63u.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
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
> BH> Ok, I don't remember Dave's email.
> 
> https://lists.linux-foundation.org/pipermail/containers/2010-February/023135.html
> 
> However, now that I've gone in and done some looking and replacing my
> print statements with %pI6, I think it may actually be kept in memory
> in network byte order, which means I don't need to switch it.  Does
> that sound right? :)

Yes, it sounds right to me.

> BH> Well, what does an 'ip -6 a' show before and after a checkpoint?
> 
> Yeah, I end up with an extra address.  I think ignoring the
> link-local ones sounds like a good plan, for now at least.

Can I ask what the addresses were?  Did you move from VM to VM so the
underlying NIC MAC address changed?

Again, I don't know your typical user for C/R.  For example, with IPv4
you save all the addresses, but if one of them was configured via DHCP,
you could have an address conflict when you restore it, since there's
no way to know if it's been handed-out to another system in the meantime.
Or does a typical C/R user only have static addresses?

With IPv6 it gets worse because the link-local will get created
automatically, and if you're in a VM it will probably be somewhat
random.  Then when you move to another VM you'll get another virtual
NIC with a different MAC address.  Since the global address is going
to be based off the same lower 64-bits, you'll wind-up with a second
global in most situations (since you're restoring the original address).

It almost seems as though you only want to C/R manually configured
IPv6 addresses (those marked IFA_F_PERMANENT) since those are going
to be static to that "system", and in that case the admin has probably
disabled the address auto-configuration process.  I guess you'll find
out as people use it and complain, then you can add knobs to control
the behavior, or simply document the restrictions.

-Brian
