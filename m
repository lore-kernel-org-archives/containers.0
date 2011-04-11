From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/3] Compare namespaces when comparing addresses in
	auth_unix cache.
Date: Mon, 11 Apr 2011 08:36:02 -0500
Message-ID: <20110411133602.GA5321__23499.4588107385$1302529003$gmane$org@hallyn.com>
References: <4D9431B3.2070305@parallels.com> <20110405034641.GC6764@hallyn.com>
	<4D9F24F2.9020603@parallels.com> <4DA30222.5040902@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4DA30222.5040902-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Kir Kolyshkin <kir-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Tim Spriggs <tims-DAzCR1AAk2Rg9hUCZPvPmw@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Rob Landley (rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
> On 04/08/2011 10:08 AM, Rob Landley wrote:
> > On 04/04/2011 10:46 PM, Serge E. Hallyn wrote:
> >> Does this need to take a reference?  Or is there no way for an
> >> entry to outlive its netns?  It sort of looks like
> >> svcauth_unix_info_release will ensure that doesn't happen, but
> >> I'm not convinced because other parts of the kernel can get
> >> to ip_map_init through the struct cache_detail.
> > 
> > When I wrote this I thought the transport's get_net() and put_net()
> > would pin it, but after re-reading, the sunrpc code is disgustingly
> > convoluted enough that I can't easily reconstruct my earlier reasoning.
> >  I'll add a get_net() and put_net() just to not have to worry about it.
> 
> Ah-ha!
> 
> Stanislav Kinsbursky helped me reconstruct some of the reasoning: we
> don't need to take a reference because we never actually dereference the
> struct net *, all we do is feed them to net_eq() which just compares the
> pointers for equality.  (The inline function exists so it can compile to
> a constant "return 1" when configured out.)
> 
> So if the network context did go away (which still shouldn't happen
> between the rpc_xprt and the struct nfs_client having references to it)
> we still wouldn't have a use-after-free problem because we're not
> looking at the memory, just the pointer.

Besides use-after-free, the other concern is an invalid net_eq()
result due to the * being re-used for a new netns.  I assume that's
deemed "super-duper impossible" again bc of the rpc_xprt/nfs_client
references to it?

> So I shouldn't need to add get_net() and put_net() to the cache.  Sound
> about right?

thanks,
-serge
