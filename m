From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ do?
Date: Tue, 3 Mar 2009 12:28:21 -0600
Message-ID: <20090303182821.GA4088__7315.87270643121$1236105113$gmane$org@us.ibm.com>
References: <1234475483.30155.194.camel@nimitz>
	<20090212141014.2cd3d54d.akpm@linux-foundation.org>
	<1234479845.30155.220.camel@nimitz>
	<20090226162755.GB1456@x200.localdomain>
	<20090226173302.GB29439@elte.hu>
	<20090226223112.GA2939@x200.localdomain>
	<20090301013304.GA2428@x200.localdomain>
	<20090301200231.GA25276@us.ibm.com>
	<20090301205659.GA7276@x200.localdomain> <49AD581F.2090903@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49AD581F.2090903-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Cedric Le Goater (legoater-GANU6spQydw@public.gmane.org):
> 
> >> 1. cap_sys_admin check is unfortunate.  In discussions about Oren's
> >> patchset we've agreed that not having that check from the outset forces
> >> us to consider security with each new patch and feature, which is a good
> >> thing.
> > 
> > Removing CAP_SYS_ADMIN on restore?
> 
> we've kept the capabilities in our patchset but the user tools doing checkpoint
> and restart are setcap'ed appropriately to be able to do different things like : 
> 	
> 	clone() the namespaces
> 	mount /dev/mqueue
> 	interact with net_ns
> 	etc.

Right, that stuff done in userspace requires capabilities.

> at restart, the task are restarted through execve() so they loose their 
> capabilities automatically.
> 
> but I think we could drop the CAP_SYS_ADMIN tests for some namespaces,
> uts and ipc are good candidates. I guess network should require some 
> privilege.  

Eric and i have talked about that a lot, and so far are continuing
to punt on it.  There are too many possibilities for subtle exploits
so I'm not suggesting changing those now.

But checkpoint and restart are entirely new.  If at each small step
we accept that an unprivileged user should be able to use it safely,
that will lead to a better design, i.e. doing may_ptrace before
checkpoint, and always doing access checks before re-creating a
resource.

If we *don't* do that, we'll have a big-stick setuid root checkpoint
and restart program which isn't at all trustworthy (bc it hasn't
received due scrutiny at each commit point), but must be trusted by
anyone wanting to use it.

And if we're too afraid to remove CAP_SYS_ADMIN checks from unsharing
one innocuous namespace, will we ever convince ourselves to remove it
from an established feature that can recreate every type of resource on
the system?

-serge
