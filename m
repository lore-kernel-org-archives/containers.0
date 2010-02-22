From: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] [PATCH 0/2] memcg: per cgroup dirty limit
Date: Mon, 22 Feb 2010 13:15:49 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1002221307180.14426__28726.467912975$1266873444$gmane$org@chino.kir.corp.google.com>
References: <1266765525-30890-1-git-send-email-arighi@develer.com>
	<20100222142744.GB13823@redhat.com> <20100222181226.GC4052@linux>
	<20100222182934.GD3096@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100222182934.GD3096-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 22 Feb 2010, Vivek Goyal wrote:

> dirty_ratio is easy to configure. One system wide default value works for
> all the newly created cgroups. For dirty_bytes, you shall have to
> configure each and individual cgroup with a specific value depneding on
> what is the upper limit of memory for that cgroup.
> 

Agreed, it makes sense for each memcg to have a dirty_ratio that defaults 
to whatever vm_dirty_ratio does, and export that constant via 
linux/writeback.h.  dirty_bytes would then use the same semantics as 
globally so that if it is set to 0, the finer-granuality is disabled by 
default and we use memcg->dirty_ratio instead.

> Secondly, memory cgroup kind of partitions global memory resource per
> cgroup. So if as long as we have global dirty ratio knobs, it makes sense
> to have per cgroup dirty ratio knob also. 
> 

It has a good default, too: whatever ratio of memory that was allowed to 
be dirty before the memcg limit was set is still allowed by default.
