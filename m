From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: Wiki for LXC with Checkpoint/Restart
Date: Wed, 14 Apr 2010 14:57:27 -0500
Message-ID: <1271275047.18251.111.camel@localhost>
References: <20100412222727.GA5759@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100412222727.GA5759-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2010-04-12 at 15:27 -0700, Sukadev Bhattiprolu wrote:
> Hi,
> 
> We created following wiki to describe the process to build/test LXC
> with checkpoint/restart.
> 
> 	https://ckpt.wiki.kernel.org/index.php/Link-LXC-USERCR
> 
> The USERCR and LXC patches that are needed are in:
> 
>         http://lxc.sourceforge.net/patches/lxc+usercr/usercr-patches/
>         http://lxc.sourceforge.net/patches/lxc+usercr/lxc-patches/
> 
> (and also referred to in the above wiki).
> 
> For now, the wiki identifies specific "commit-id"s to identify the
> commit with which the instructions in the wiki were tested. We hope
> to create more meaningful tags to the commits and if so, we will update
> the wiki with the tags.
> 
> Please let me know if you have any comments on the wiki or run into
> problems.

When building the kernel with the commit id specified in the wiki
(0fdca57) I get:

ERROR: "ckpt_netdev_base" [net/ipv6/sit.ko] undefined!
ERROR: "ckpt_netdev_in_init_netns" [drivers/net/veth.ko] undefined!
ERROR: "ckpt_netdev_base" [drivers/net/veth.ko] undefined!
ERROR: "ckpt_netdev_base" [drivers/net/macvlan.ko] undefined!
make[1]: *** [__modpost] Error 1
make: *** [modules] Error 2
