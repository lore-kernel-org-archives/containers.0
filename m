From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][-mm] [0/2] Basic stats for cgroups V2
Date: Sun, 06 Apr 2008 11:55:39 +0530
Message-ID: <47F86CE3.9080705@linux.vnet.ibm.com>
References: <200804052339.42474.balajirrao@gmail.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755227AbYDFG0r@vger.kernel.org>
In-Reply-To: <200804052339.42474.balajirrao@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Balaji Rao <balajirrao@gmail.com>
Cc: linux-kernel@vger.kernel.org, containers@lists.osdl.org, dhaval@linux.vnet.ibm.com, balbir@in.ibm.com, menage@google.com, a.p.zijlstra@chello.nl, Ingo Molnar <mingo@elte.hu>
List-Id: containers.vger.kernel.org

Balaji Rao wrote:
> V1->V2
> - Fixed a possible race in cpu_cgroup_read_stat. Thank you Paul for pointing this out.
> - A few other naming changes.
> 
> This patchset is a first step towards implementing stats for cgroup 
> subsystems. Only a few trivial stats for cpu and memory resource controller 
> have been implemented for now. Please provide comments on the general 
> direction and any suggestions on how you would like the cgroupstats framework 
> to be implemented.
> 
> roadmap
> --------
> implement a generic statistics framework for cgroups,
> unification with taskstats/netlink interface,
> add more statistics
> 

I like the roadmap and the patches. We need these statistics quite urgently. We
have lot of control and some statistics. We need more statistics to help make
the decision making (resizing, moving task, etc.) easier


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
