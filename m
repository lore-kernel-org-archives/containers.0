From: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Subject: Re: [RFC][-mm] [1/2] Simple stats for cpu resource controller
Date: Sun, 6 Apr 2008 02:29:14 +0530
Message-ID: <20080405205914.GA25009@linux.vnet.ibm.com>
References: <200804052339.46632.balajirrao@gmail.com> <20080405194041.GB21279@linux.vnet.ibm.com> <200804060201.52726.balajirrao@gmail.com>
Reply-To: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754758AbYDEU7h@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200804060201.52726.balajirrao@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Balaji Rao <balajirrao@gmail.com>
Cc: linux-kernel@vger.kernel.org, containers@lists.osdl.org, menage@google.com, a.p.zijlstra@chello.nl, balbir@in.ibm.com, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>
List-Id: containers.vger.kernel.org

On Sun, Apr 06, 2008 at 02:01:52AM +0530, Balaji Rao wrote:
> On Sunday 06 April 2008 01:10:41 am Dhaval Giani wrote:
> > > +};
> > > +
> > > +struct cpu_cgroup_stat_cpu {
> > > +	s64 count[CPU_CGROUP_STAT_NSTATS];
> > 
> > u64? time does not go negative :)
> Right. But these stats are not only going to measure time. We need the same 
> variables for measuring other stats as well. I'm not sure if we would 
> encounter scheduler stats that would count negative.
> 
> Balbir, what do you say ?

I would prefer to keep the stats logically separate. So something like
struct cpu_cgroup_stat_cpu {
	u64 time[];
	s64 some_other_stat;
}
and so on. (I am not sure, is there some advantage gained by using
structs?) Makes the code more maintainable imho.

> 
> > count also is not very clear? Can you give a more descriptive name?
> > 
> ok. How does 'value' look  ?
> 
> <snip>
> 
> > > +static s64 cpu_cgroup_read_stat(struct cpu_cgroup_stat *stat,
> > > +		enum cpu_cgroup_stat_index idx)
> > > +{
> > > +	int cpu;
> > > +	s64 ret = 0;
> > > +	unsigned long flags;
> > 
> > > +
> > > +	local_irq_save(flags);
> > 
> > I am just wondering. Is local_irq_save() enough?
> > 
> Hmmm.. You are right.This does not prevent concurrent updates on other CPUs 
> from crossing a 32bit boundary. Am not sure how to do this in a safe way. I 
> can only think of using atomic64_t now..
> 

I am going to answer that one when I am awake :-)

-- 
regards,
Dhaval
