From: Brian Haley <brian.haley-VXdhtT5mjnY@public.gmane.org>
Subject: Re: [PATCH 1/2] C/R: Support for IPv6 addresses on network devices
Date: Thu, 25 Mar 2010 17:28:52 -0400
Message-ID: <4BABD594.1020301@hp.com>
References: <1269459625-21033-1-git-send-email-danms@us.ibm.com>	<1269459625-21033-2-git-send-email-danms@us.ibm.com>	<4BABC967.5090908@hp.com>
	<87aatwf74u.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87aatwf74u.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
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
>>> +#define HTON_IPV6(dst, src) __BYTE_ORDER_COPY(htonl, dst, src)
>>> +#define NTOH_IPV6(dst, src) __BYTE_ORDER_COPY(ntohl, dst, src)
> 
> BH> Yuck, this is ugly, use ipv6_addr_copy() please.
> 
> So, I started with ipv6_addr_copy(), but that leaves the addresses in
> the host endianess within the checkpoint image, right?  Dave Miller
> had previously asked to have the IPv4 addresses htonl()'d before being
> written to the image, so I was doing the same here.

Ok, I don't remember Dave's email.

> BH> I am still worried about this.  When an interface is activated and
> BH> the IPv6 module is loaded, it's going to generate a link-local address
> BH> right away.  Then it will auto-configure an address based on information
> BH> in a received router advertisement.  Is this code going to conflict
> BH> with that?  Meaning, will you have two link-locals on this interface
> BH> once the system is running?
> 
> I have to claim IPv6 ignorance here :)

Well, what does an 'ip -6 a' show before and after a checkpoint?

-Brian
