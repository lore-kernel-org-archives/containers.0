From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: Wiki for LXC with Checkpoint/Restart
Date: Wed, 14 Apr 2010 15:16:48 -0500
Message-ID: <1271276208.18251.119.camel@localhost>
References: <20100412222727.GA5759@us.ibm.com>
	<1271275047.18251.111.camel@localhost>
	<87ljcpajog.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87ljcpajog.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 2010-04-14 at 13:00 -0700, Dan Smith wrote:
> NL> When building the kernel with the commit id specified in the wiki
> NL> (0fdca57) I get:
> 
> NL> ERROR: "ckpt_netdev_base" [net/ipv6/sit.ko] undefined!
> NL> ERROR: "ckpt_netdev_in_init_netns" [drivers/net/veth.ko] undefined!
> NL> ERROR: "ckpt_netdev_base" [drivers/net/veth.ko] undefined!
> NL> ERROR: "ckpt_netdev_base" [drivers/net/macvlan.ko] undefined!
> NL> make[1]: *** [__modpost] Error 1
> NL> make: *** [modules] Error 2
> 
> Right and the fixes in my latest set should eliminate that :)
> 

I expected as much, but the question is how should we address this kind
of problem in the wiki?  Are the patches in a publicly available branch?
