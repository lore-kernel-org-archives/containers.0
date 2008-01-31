From: Vivek Goyal <vivek.goyal2008@gmail.com>
Subject: Re: [RFC] Default child of a cgroup
Date: Thu, 31 Jan 2008 16:13:29 -0500
Message-ID: <20080131211328.GA9521@dhcp83-78.boston.redhat.com>
References: <20080131024049.GA9544@linux.vnet.ibm.com>
Reply-To: vivek.goyal2008@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934033AbYAaVNv@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080131024049.GA9544@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, a.p.zijlstra@chello.nl, Ingo Molnar <mingo@elte.hu>, menage@google.com, containers@lists.osdl.org, dhaval@linux.vnet.ibm.com, Balbir Singh <balbir@in.ibm.com>, pj@sgi.com
List-Id: containers.vger.kernel.org

On Thu, Jan 31, 2008 at 08:10:49AM +0530, Srivatsa Vaddagiri wrote:
> Hi,
> 	As we were implementing multiple-hierarchy support for CPU
> controller, we hit some oddities in its implementation, partly related
> to current cgroups implementation. Peter and I have been debating on the 
> exact solution and I thought of bringing that discussion to lkml.
> 
> Consider the cgroup filesystem structure for managing cpu resource.
> 
> 	# mount -t cgroup -ocpu,cpuacct none /cgroup
> 	# mkdir /cgroup/A
> 	# mkdir /cgroup/B
> 	# mkdir /cgroup/A/a1
> 
> will result in:
> 
> 	/cgroup
> 	   |------<tasks>
> 	   |------<cpuacct.usage>
>  	   |------<cpu.shares>
> 	   |
> 	   |----[A]
> 	   |     |----<tasks>
> 	   |     |----<cpuacct.usage>
> 	   |     |----<cpu.shares>
> 	   |     |
> 	   |     |---[a1]
> 	   |           |----<tasks>
> 	   |   	       |----<cpuacct.usage>
> 	   |           |----<cpu.shares>
> 	   |           |
> 	   |
> 	   |----[B]
> 	   |     |----<tasks>
> 	   |     |----<cpuacct.usage>
> 	   |     |----<cpu.shares>
> 	   |     
> 
> 
> Here are some questions that arise in this picture:
> 
> 1. What is the relationship of the task-group in A/tasks with the
>    task-group in A/a1/tasks? In otherwords do they form siblings
>    of the same parent A?
> 

Vatsa,

I don't know much about cgroups but got a query. How do we handle this if we
just go one level up? How do we define relationship between /cgroup/tasks and
/cgroup/A/tasks, or /cgroup/tasks and /cgroup/B/tasks?

To me lower levels should be handeled in the same way.

Thanks
Vivek
