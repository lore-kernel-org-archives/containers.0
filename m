From: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 2/2] cgroup/memcg show correct file mode
Date: Wed, 25 Feb 2009 13:39:47 +0530
Message-ID: <20090225080947.GA28832__9637.1969012127$1235549588$gmane$org@linux.vnet.ibm.com>
References: <20090225163555.d2a0b24c.kamezawa.hiroyu@jp.fujitsu.com>
	<20090225163729.cc43bd5c.kamezawa.hiroyu@jp.fujitsu.com>
	<20090225080329.GE11421@balbir.in.ibm.com>
Reply-To: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090225080329.GE11421-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Feb 25, 2009 at 01:33:29PM +0530, Balbir Singh wrote:
> * KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> [2009-02-25 16:37:29]:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> > 
> > Set correct permission to memcg's file.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> > ---
> >  mm/memcontrol.c |    4 ++++
> >  1 file changed, 4 insertions(+)
> > 
> > Index: mmotm-2.6.29-Feb24/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-2.6.29-Feb24.orig/mm/memcontrol.c
> > +++ mmotm-2.6.29-Feb24/mm/memcontrol.c
> > @@ -2218,6 +2218,7 @@ static struct cftype mem_cgroup_files[] 
> >  		.name = "usage_in_bytes",
> >  		.private = MEMFILE_PRIVATE(_MEM, RES_USAGE),
> >  		.read_u64 = mem_cgroup_read,
> > +		.mode = 0444
> >  	},
> >  	{
> >  		.name = "max_usage_in_bytes",
> > @@ -2240,10 +2241,12 @@ static struct cftype mem_cgroup_files[] 
> >  	{
> >  		.name = "stat",
> >  		.read_map = mem_control_stat_show,
> > +		.mode = 0444
> >  	},
> >  	{
> >  		.name = "force_empty",
> >  		.trigger = mem_cgroup_force_empty_write,
> > +		.mode = 0200
> >  	},
> >  	{
> >  		.name = "use_hierarchy",
> > @@ -2263,6 +2266,7 @@ static struct cftype memsw_cgroup_files[
> >  		.name = "memsw.usage_in_bytes",
> >  		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_USAGE),
> >  		.read_u64 = mem_cgroup_read,
> > +		.mode = 0444
> >  	},
> >  	{
> >  		.name = "memsw.max_usage_in_bytes",
> > 
> >
> 
> Yes, please, very much required
> 
> Acked-by: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

I agree,

Acked-by: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
-- 
regards,
Dhaval
