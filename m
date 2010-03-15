From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: ckpt-v20-rc1
Date: Sun, 14 Mar 2010 22:38:04 -0500
Message-ID: <20100315033804.GA2047@hallyn.com>
References: <4B9DA00C.3000001@cs.columbia.edu>
	<20100315032347.GA4707@us.ibm.com>
	<4B9DAA71.2000808@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B9DAA71.2000808-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> 
> 
> Serge E. Hallyn wrote:
> > Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> >> I pushed all the recent patches to ckpt-v19-dev (except for Matt's code
> >> order series). It includes the recent post of netdev/netns.
> >>
> >> Feel free to yell if I left out your patch unjustifiably.
> >>
> >> Also pushed ckpt-v20-rc1 which is a clean patchset of the same and
> >> also rebased to 2.6.33, lightly tested here.
> >>
> >> The goal is to get ckpt-v20 in 1-2 days and post the series on LKML
> >> following up on Andrew's reply.
> >>
> >> Before that, I'd like to validate that there are no regressions, and
> >> apply some netns/netdev cleanups (in particular, the kernel doesn't
> >> compile when NETNS isn't configured)
> >>
> >> Let's give it a quick test drive.
> >>
> >> Oren.	
> >>
> > 
> > hmm, 
> > 
> > ERROR: "ckpt_obj_lookup" [drivers/net/veth.ko] undefined!
> > ERROR: "do_ckpt_msg" [drivers/net/veth.ko] undefined!
> > ERROR: "ckpt_hdr_put" [drivers/net/veth.ko] undefined!
> > ERROR: "checkpoint_obj" [drivers/net/veth.ko] undefined!
> > ERROR: "ckpt_netdev_in_init_netns" [drivers/net/veth.ko] undefined!
> > ERROR: "ckpt_write_buffer" [drivers/net/veth.ko] undefined!
> > ERROR: "ckpt_write_obj" [drivers/net/veth.ko] undefined!
> > ERROR: "ckpt_obj_lookup_add" [drivers/net/veth.ko] undefined!
> > ERROR: "ckpt_netdev_base" [drivers/net/veth.ko] undefined!
> > ERROR: "ckpt_hdr_put" [drivers/net/macvlan.ko] undefined!
> > ERROR: "ckpt_write_buffer" [drivers/net/macvlan.ko] undefined!
> > ERROR: "ckpt_write_obj" [drivers/net/macvlan.ko] undefined!
> > ERROR: "ckpt_netdev_base" [drivers/net/macvlan.ko] undefined!
> > ERROR: "ckpt_debug_level" [drivers/net/macvlan.ko] undefined!
> 
> Oh... I didn't test with kernel modules. This required export
> symbol - will send a patch promptly.
> 
> Some (the last two) are because NETNS isn't configured ?

No, NETNS is configured.

If you can push to git i'll pull and keep testing

(applying patches i become afraid i'm not running a 'true' test
of what you'll be sending out)

thanks,
-serge
