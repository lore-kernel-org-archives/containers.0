From: Balaji Rao <balajirrao@gmail.com>
Subject: Re: [RFC][-mm] [1/2] Simple stats for cpu resource controller
Date: Sun, 6 Apr 2008 02:51:51 +0530
Message-ID: <200804060251.51635.balajirrao@gmail.com>
References: <200804052339.46632.balajirrao@gmail.com> <200804060201.52726.balajirrao@gmail.com> <20080405205914.GA25009@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755087AbYDEV2W@vger.kernel.org>
In-Reply-To: <20080405205914.GA25009@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, containers@lists.osdl.org, menage@google.com, a.p.zijlstra@chello.nl, balbir@in.ibm.com, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>
List-Id: containers.vger.kernel.org

On Sunday 06 April 2008 02:29:14 am Dhaval Giani wrote:
> On Sun, Apr 06, 2008 at 02:01:52AM +0530, Balaji Rao wrote:
> > On Sunday 06 April 2008 01:10:41 am Dhaval Giani wrote:
> > > > +};
> > > > +
> > > > +struct cpu_cgroup_stat_cpu {
> > > > +	s64 count[CPU_CGROUP_STAT_NSTATS];
> > > 
> > > u64? time does not go negative :)
> > Right. But these stats are not only going to measure time. We need the 
same 
> > variables for measuring other stats as well. I'm not sure if we would 
> > encounter scheduler stats that would count negative.
> > 
> > Balbir, what do you say ?
> 
> I would prefer to keep the stats logically separate. So something like
> struct cpu_cgroup_stat_cpu {
> 	u64 time[];
> 	s64 some_other_stat;
> }
> and so on. (I am not sure, is there some advantage gained by using
> structs?) Makes the code more maintainable imho.
> 
This would break the generic nature of __cpu_cgroup_stat_add. Its not a nice 
thing in my opinion.

-- 
regards,
Balaji Rao
Dept. of Mechanical Engineering,
National Institute of Technology Karnataka, India
