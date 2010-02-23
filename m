From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC] [PATCH 0/2] memcg: per cgroup dirty limit
Date: Tue, 23 Feb 2010 10:55:55 +0100
Message-ID: <20100223095555.GF1882__10392.1443726451$1266919067$gmane$org@linux>
References: <1266765525-30890-1-git-send-email-arighi@develer.com>
	<20100222142744.GB13823@redhat.com> <20100222181226.GC4052@linux>
	<20100222182934.GD3096@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Feb 22, 2010 at 01:29:34PM -0500, Vivek Goyal wrote:
> > I would't like to add many different interfaces to do the same thing.
> > I'd prefer to choose just one interface and always use it. We just have
> > to define which is the best one. IMHO dirty_bytes is more generic. If
> > we want to define the limit as a % we can always do that in userspace.
> > 
> 
> dirty_ratio is easy to configure. One system wide default value works for
> all the newly created cgroups. For dirty_bytes, you shall have to
> configure each and individual cgroup with a specific value depneding on
> what is the upper limit of memory for that cgroup.

OK.

> 
> Secondly, memory cgroup kind of partitions global memory resource per
> cgroup. So if as long as we have global dirty ratio knobs, it makes sense
> to have per cgroup dirty ratio knob also. 
> 
> But I guess we can introduce that later and use gloabl dirty ratio for
> all the memory cgroups (instead of each cgroup having a separate dirty
> ratio). The only thing is that we need to enforce this dirty ratio on the
> cgroup and if I am reading the code correctly, your modifications of
> calculating available_memory() per cgroup should take care of that.

At the moment (with dirty_bytes) if the cgroup has dirty_bytes == 0, it
simply uses the system wide available_memory(), ignoring the memory
upper limit for that cgroup and fallbacks to the current behaviour.

With dirty_ratio, should we change the code to *always* apply this
percentage to the cgroup memory upper limit, and automatically set it
equal to the global dirty_ratio by default when the cgroup is created?
mmmh... I vote yes.

-Andrea
