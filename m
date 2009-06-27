From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: [PATCH] x86: only clear node_states for 64bit
Date: Sat, 27 Jun 2009 19:17:14 +0200
Message-ID: <20090627171714.GD21595@elte.hu>
References: <alpine.DEB.1.10.0906041309230.8080@gentwo.org>
	<4A2803D1.4070001@kernel.org> <m3bpokiv0u.fsf@pobox.com>
	<4A3B49BA.40100@kernel.org> <m3prd0havh.fsf@pobox.com>
	<4A3D7419.8040305@kernel.org> <m3my807ug3.fsf@pobox.com>
	<4A3FA58A.3010909@kernel.org>
	<20090626135428.d8f88a70.akpm@linux-foundation.org>
	<4A4538FE.2090101@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A4538FE.2090101-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: steiner-sJ/iWh9BUns@public.gmane.org, cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, suresh.b.siddha-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org
List-Id: containers.vger.kernel.org


* Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:

> Andrew Morton wrote:
> > On Mon, 22 Jun 2009 08:38:50 -0700
> > Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> > 
> >> Nathan reported that
> >> | commit 73d60b7f747176dbdff826c4127d22e1fd3f9f74
> >> | Author: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> >> | Date:   Tue Jun 16 15:33:00 2009 -0700
> >> |
> >> |    page-allocator: clear N_HIGH_MEMORY map before we set it again
> >> |    
> >> |    SRAT tables may contains nodes of very small size.  The arch code may
> >> |    decide to not activate such a node.  However, currently the early boot
> >> |    code sets N_HIGH_MEMORY for such nodes.  These nodes therefore seem to be
> >> |    active although these nodes have no present pages.
> >> |    
> >> |    For 64bit N_HIGH_MEMORY == N_NORMAL_MEMORY, so that works for 64 bit too
> >>
> >> the cpuset.mems cgroup attribute on an i386 kvm guest
> >>
> >> fix it by only clearing node_states[N_NORMAL_MEMORY] for 64bit only.
> >> and need to do save/restore for that in find_zone_movable_pfn
> >>
> > 
> > There appear to be some words omitted from this changelog - it doesn't
> > make sense.
> > 
> > I think that perhaps a line got deleted before "the cpuset.mems cgroup
> > ...".  That was the line which actualy describes the bug which we're
> > fixing.  Or perhaps it was a single word?  "zeroes".
> > 
> > 
> > I did this:
> > 
> > Nathan reported that
> > : 
> > : | commit 73d60b7f747176dbdff826c4127d22e1fd3f9f74
> > : | Author: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> > : | Date:   Tue Jun 16 15:33:00 2009 -0700
> > : |
> > : |    page-allocator: clear N_HIGH_MEMORY map before we set it again
> > : |
> > : |    SRAT tables may contains nodes of very small size.  The arch code may
> > : |    decide to not activate such a node.  However, currently the early boot
> > : |    code sets N_HIGH_MEMORY for such nodes.  These nodes therefore seem to be
> > : |    active although these nodes have no present pages.
> > : |
> > : |    For 64bit N_HIGH_MEMORY == N_NORMAL_MEMORY, so that works for 64 bit too
> > : 
> 
> "
> > : unintentionally and incorrectly clears the cpuset.mems cgroup attribute on
> > : an i386 kvm guest
> "
> ==> 
> 
> 32bit assume NORMAL_MEMORY bit and HIGH_MEMORY bit are set for 
> Node0 always.

Where in the code is this assumption?

> and some code only check if HIGH_MEMORY is there to know if 
> NORMAL_MEMORY is there.

Which code is that exactly?

	Ingo
