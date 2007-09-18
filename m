From: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [PATCH 0/4] Kernel memory accounting container (v3)
Date: Tue, 18 Sep 2007 12:37:44 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0709181237070.3714@schroedinger.engr.sgi.com>
References: <46EE70B4.6060902@openvz.org>
	<Pine.LNX.4.64.0709171126330.27057@schroedinger.engr.sgi.com>
	<46EF6F6C.60702@openvz.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46EF6F6C.60702-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 18 Sep 2007, Pavel Emelyanov wrote:

> > Where can I find more information why is would not be possible to 
> > account kmalloc caches?
> 
> It is possible, but the problem is that we want to account only
> allocations explicitly caused by the user request. E.g. the
> vfsmount name is kmalloc-ed by explicit user request, but such
> things as buffer heads are not.
> 
> So we have to explicitly specify which calls to kmalloc() do we
> wand to be accounted and which we do not by passing additional
> flag (GFP_ACCT?) to kmalloc, but this is another patch.
> 
> Yet again - as soon as we agree on the implementation of kmem
> caches accounting, I will proceed with working on kmalloc, vmalloc
> and buddy allocator.

Oh gosh..... Lots of complications in the allocator paths.
