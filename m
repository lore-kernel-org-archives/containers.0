From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] mm: clear N_HIGH_MEMORY map before se set it again -v4
Date: Sun, 21 Jun 2009 23:39:56 -0500
Message-ID: <m3my807ug3.fsf__47947.3147461706$1245645744$gmane$org@pobox.com>
References: <4A05269D.8000701@kernel.org> <20090512111623.GG25923@csn.ul.ie>
	<4A0A64FB.4080504@kernel.org> <20090513145950.GB28097@csn.ul.ie>
	<4A0C4910.7090508@kernel.org> <4A0C4A2A.6080009@kernel.org>
	<20090514095414.ba8356e5.akpm@linux-foundation.org>
	<4A0C4F67.5080802@kernel.org>
	<20090514102554.b3a36f19.akpm@linux-foundation.org>
	<4A0C563A.3020100@kernel.org> <4A2758CB.9090404@kernel.org>
	<alpine.DEB.1.10.0906041236520.5377@gentwo.org>
	<4A27FAD4.2010104@kernel.org>
	<alpine.DEB.1.10.0906041309230.8080@gentwo.org>
	<4A2803D1.4070001@kernel.org>
	<m3bpokiv0u.fsf@pobox.com> <4A3B49BA.40100@kernel.org>
	<m3prd0havh.fsf@pobox.com> <4A3D7419.8040305@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A3D7419.8040305-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> (Yinghai Lu's message of "Sat\, 20
	Jun 2009 16\:43\:21 -0700")
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
Cc: steiner-sJ/iWh9BUns@public.gmane.org, Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, suresh.b.siddha-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> writes:
> please check
>
> [PATCH] x86: only clear node_states for 64bit
>
> Nathan reported that
> | commit 73d60b7f747176dbdff826c4127d22e1fd3f9f74
> | Author: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> | Date:   Tue Jun 16 15:33:00 2009 -0700
> |
> |    page-allocator: clear N_HIGH_MEMORY map before we set it again
> |    
> |    SRAT tables may contains nodes of very small size.  The arch code may
> |    decide to not activate such a node.  However, currently the early boot
> |    code sets N_HIGH_MEMORY for such nodes.  These nodes therefore seem to be
> |    active although these nodes have no present pages.
> |    
> |    For 64bit N_HIGH_MEMORY == N_NORMAL_MEMORY, so that works for 64 bit too
>
> the cpuset.mems cgroup attribute on an i386 kvm guest
>
> try to fix it by only clear node_states[N_NORMAL_MEMORY] for 64bit only.
> and need to do save/restore for that in find_zone_movable_pfn

This works for my setup, thanks.
