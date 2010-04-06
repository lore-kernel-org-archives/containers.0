From: Brian Haley <brian.haley-VXdhtT5mjnY@public.gmane.org>
Subject: Re: [PATCH 1/3] C/R: Support for IPv6 addresses on network devices
	(v2)
Date: Tue, 06 Apr 2010 11:53:35 -0400
Message-ID: <4BBB58FF.1090908@hp.com>
References: <1270563183-9351-1-git-send-email-danms@us.ibm.com>
	<1270563183-9351-2-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1270563183-9351-2-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

> +static int ckpt_netdev_inet6_addrs(struct inet6_dev *indev,
> +				   int index, int max,
> +				   struct ckpt_netdev_addr *abuf)
> +{
> +	struct inet6_ifaddr *addr;
> +	struct ifmcaddr6 *mcaddr;
> +	struct ifacaddr6 *acaddr;
> +
> +	for (addr = indev->addr_list; addr; addr = addr->if_next) {
> +		if (ipv6_addr_scope(&addr->addr))
> +			continue; /* Ignore non-global scope addresses */

This will prevent the loopback address (::1) from getting checkpointed
since it's host-local.  The ipv6 module will add it anyways so it's
probably not a big deal.

-Brian
