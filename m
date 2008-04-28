From: Balaji Rao <balajirrao@gmail.com>
Subject: Re: [RFC][-mm] [2/2] Simple stats for memory resource controller
Date: Mon, 28 Apr 2008 21:30:29 +0530
Message-ID: <200804282130.30188.balajirrao@gmail.com>
References: <200804052340.02386.balajirrao@gmail.com> <48036CB4.5050700@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S935868AbYD1QA5@vger.kernel.org>
In-Reply-To: <48036CB4.5050700@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, containers@lists.osdl.org, menage@google.com, balbir@in.ibm.com, dhaval@linux.vnet.ibm.com
List-Id: containers.vger.kernel.org

On Monday 14 April 2008 08:09:48 pm Balbir Singh wrote:
> Balaji Rao wrote:
> > This patch implements trivial statistics for the memory resource controller.
> > 
> > Signed-off-by: Balaji Rao <balajirrao@gmail.com>
> > CC: Balbir Singh <balbir@linux.vnet.ibm.com>
> > CC: Dhaval Giani <dhaval@linux.vnet.ibm.com>
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index a860765..ca98b21 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -47,6 +47,8 @@ enum mem_cgroup_stat_index {
> >  	 */
> >  	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
> >  	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as rss */
> > +	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
> > +	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
> > 
> >  	MEM_CGROUP_STAT_NSTATS,
> >  };
> > @@ -198,6 +200,13 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *mem, int flags,
> >  		__mem_cgroup_stat_add_safe(stat, MEM_CGROUP_STAT_CACHE, val);
> >  	else
> >  		__mem_cgroup_stat_add_safe(stat, MEM_CGROUP_STAT_RSS, val);
> > +
> > +	if (charge)
> > +		__mem_cgroup_stat_add_safe(stat,
> > +				MEM_CGROUP_STAT_PGPGIN_COUNT, 1);
> > +	else
> > +		__mem_cgroup_stat_add_safe(stat,
> > +				MEM_CGROUP_STAT_PGPGOUT_COUNT, 1);
> >  }
> > 
> >  static struct mem_cgroup_per_zone *
> > @@ -897,6 +906,8 @@ static const struct mem_cgroup_stat_desc {
> >  } mem_cgroup_stat_desc[] = {
> >  	[MEM_CGROUP_STAT_CACHE] = { "cache", PAGE_SIZE, },
> >  	[MEM_CGROUP_STAT_RSS] = { "rss", PAGE_SIZE, },
> > +	[MEM_CGROUP_STAT_PGPGIN_COUNT] = {"pgpgin", 1, },
> > +	[MEM_CGROUP_STAT_PGPGOUT_COUNT] = {"pgpgout", 1, },
> >  };
> > 
> >  static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
> > 
> 
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> Hi, Andrew,
> 
> Could you please include these statistics in -mm.
> 
> Balbir
> 
> 
Hi Andrew,

Now that Balbir Singh has ACKed it, could you please include it in -mm ?

-- 
Warm Regards,

Balaji Rao
Dept. of Mechanical Engineering
NITK
