From: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [RFC][PATCH 0/3] Kernel memory accounting container (v2)
Date: Fri, 14 Sep 2007 10:30:26 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0709141028120.15683@schroedinger.engr.sgi.com>
References: <46E8FEC7.2010707@openvz.org>
	<Pine.LNX.4.64.0709131135210.9590@schroedinger.engr.sgi.com>
	<46EA297B.5070605@openvz.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46EA297B.5070605-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 14 Sep 2007, Pavel Emelyanov wrote:

> > Hmmmm... Okay I have seen multiple people who want to control slab 
> > allocations and track memory for various reasons. Would it be possible to 
> > come up with some hook that would allow a subscription to certain SLUB 
> > events? That way multiple subsystems may track and maybe disallow certain
> > allocations in various contexts.
> 
> Do you mean some more generic than just explicit call from slab_alloc, etc?
> Ok, I will work on it.

Yes I guess an API in slub to register callbacks for these things. This 
needs to include a way to control the granularity. Callbacks at the level 
of slab allocations are likely not that performance critical. But some 
uses may require control at the object level. There needs to be some way 
to tell SLUB to disable the fast path for a particular allocated slab 
because the API will police each individual allocation.
