From: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] memcg: dirty pages instrumentation
Date: Tue, 23 Feb 2010 14:22:12 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1002231419450.8693__21654.6667893001$1266963879$gmane$org@chino.kir.corp.google.com>
References: <1266765525-30890-1-git-send-email-arighi@develer.com>
	<1266765525-30890-3-git-send-email-arighi@develer.com>
	<20100222165215.GA3096@redhat.com> <20100223094040.GC1882@linux>
	<20100223195606.GD11930@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100223195606.GD11930-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Tue, 23 Feb 2010, Vivek Goyal wrote:

> > > Because you have modified dirtyable_memory() and made it per cgroup, I
> > > think it automatically takes care of the cases of per cgroup dirty ratio,
> > > I mentioned in my previous mail. So we will use system wide dirty ratio
> > > to calculate the allowed dirty pages in this cgroup (dirty_ratio *
> > > available_memory()) and if this cgroup wrote too many pages start
> > > writeout? 
> > 
> > OK, if I've understood well, you're proposing to use per-cgroup
> > dirty_ratio interface and do something like:
> 
> I think we can use system wide dirty_ratio for per cgroup (instead of
> providing configurable dirty_ratio for each cgroup where each memory
> cgroup can have different dirty ratio. Can't think of a use case
> immediately).

I think each memcg should have both dirty_bytes and dirty_ratio, 
dirty_bytes defaults to 0 (disabled) while dirty_ratio is inherited from 
the global vm_dirty_ratio.  Changing vm_dirty_ratio would not change 
memcgs already using their own dirty_ratio, but new memcgs would get the 
new value by default.  The ratio would act over the amount of available 
memory to the cgroup as though it were its own "virtual system" operating 
with a subset of the system's RAM and the same global ratio.
