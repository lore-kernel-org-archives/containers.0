From: Balaji Rao <balajirrao@gmail.com>
Subject: Re: [RFC][-mm] [1/2] Simple stats for cpu resource controller
Date: Thu, 10 Apr 2008 21:39:59 +0530
Message-ID: <200804102140.00078.balajirrao@gmail.com>
References: <200804052339.46632.balajirrao@gmail.com> <200804060201.52726.balajirrao@gmail.com> <1207574693.15579.35.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758322AbYDJQQr@vger.kernel.org>
In-Reply-To: <1207574693.15579.35.camel@twins>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Dhaval Giani <dhaval@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, containers@lists.osdl.org, menage@google.com, balbir@in.ibm.com, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>
List-Id: containers.vger.kernel.org

On Monday 07 April 2008 06:54:53 pm Peter Zijlstra wrote:
> On Sun, 2008-04-06 at 02:01 +0530, Balaji Rao wrote:
> 
> > > > +static s64 cpu_cgroup_read_stat(struct cpu_cgroup_stat *stat,
> > > > +		enum cpu_cgroup_stat_index idx)
> > > > +{
> > > > +	int cpu;
> > > > +	s64 ret = 0;
> > > > +	unsigned long flags;
> > > 
> > > > +
> > > > +	local_irq_save(flags);
> > > 
> > > I am just wondering. Is local_irq_save() enough?
> > > 
> > Hmmm.. You are right.This does not prevent concurrent updates on other 
CPUs 
> > from crossing a 32bit boundary. Am not sure how to do this in a safe way. 
I 
> > can only think of using atomic64_t now..
> > 
> > > > +	for_each_possible_cpu(cpu)
> > > > +		ret += stat->cpustat[cpu].count[idx];
> > > > +	local_irq_restore(flags);
> > > > +
> > > > +	return ret;
> > > > +}
> > > > +
> 
> So many stats to steal code from,.. but you didn't :-(
> 
> Look at mm/vmstat.c, that is a rather complete example.
> 
> The trick to solving the above is to use per cpu deltas instead, the
> deltas can be machine word size and are thus always read in an atomic
> manner (provided they are also naturally aligned).
> 
> 
Hi Peter,

This wont work for time based statistics. At nsec granularity, a word can hold 
a time value of up to ~4s. 

I propose to solve this problem by using a lock to protect the statistics, but 
only on 32bit architectures.

I'm not sure how good a solution this is, but that's the best I can think of 
ATM. 
-- 
regards,
Balaji Rao
Dept. of Mechanical Engineering,
National Institute of Technology Karnataka, India
