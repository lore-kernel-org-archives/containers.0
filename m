From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 2/2] memcg: dirty pages instrumentation
Date: Fri, 26 Feb 2010 09:14:21 +0900
Message-ID: <20100226091421.8c15c210.kamezawa.hiroyu__32350.2887077213$1267143642$gmane$org@jp.fujitsu.com>
References: <1266765525-30890-1-git-send-email-arighi@develer.com>
	<1266765525-30890-3-git-send-email-arighi@develer.com>
	<20100222165215.GA3096@redhat.com> <20100223094040.GC1882@linux>
	<20100223195606.GD11930@redhat.com>
	<alpine.DEB.2.00.1002231419450.8693@chino.kir.corp.google.com>
	<20100225143444.GB3964@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100225143444.GB3964@linux>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 25 Feb 2010 15:34:44 +0100
Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org> wrote:

> On Tue, Feb 23, 2010 at 02:22:12PM -0800, David Rientjes wrote:
> > On Tue, 23 Feb 2010, Vivek Goyal wrote:
> > 
> > > > > Because you have modified dirtyable_memory() and made it per cgroup, I
> > > > > think it automatically takes care of the cases of per cgroup dirty ratio,
> > > > > I mentioned in my previous mail. So we will use system wide dirty ratio
> > > > > to calculate the allowed dirty pages in this cgroup (dirty_ratio *
> > > > > available_memory()) and if this cgroup wrote too many pages start
> > > > > writeout? 
> > > > 
> > > > OK, if I've understood well, you're proposing to use per-cgroup
> > > > dirty_ratio interface and do something like:
> > > 
> > > I think we can use system wide dirty_ratio for per cgroup (instead of
> > > providing configurable dirty_ratio for each cgroup where each memory
> > > cgroup can have different dirty ratio. Can't think of a use case
> > > immediately).
> > 
> > I think each memcg should have both dirty_bytes and dirty_ratio, 
> > dirty_bytes defaults to 0 (disabled) while dirty_ratio is inherited from 
> > the global vm_dirty_ratio.  Changing vm_dirty_ratio would not change 
> > memcgs already using their own dirty_ratio, but new memcgs would get the 
> > new value by default.  The ratio would act over the amount of available 
> > memory to the cgroup as though it were its own "virtual system" operating 
> > with a subset of the system's RAM and the same global ratio.
> 
> Agreed.
> 
BTW, please add background_dirty_ratio in the same series of patches.
(or something other to kick background-writeback in proper manner.)

If not, we can't kick background write-back until we're caught by dirty_ratio.

Thanks,
-Kame
