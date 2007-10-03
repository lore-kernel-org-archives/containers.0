From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH] task containersv11 add tasks file interface fix for cpusets
Date: Wed, 3 Oct 2007 11:10:58 -0700
Message-ID: <6599ad830710031110r1a74eafej56f20cc33e72ac81@mail.gmail.com>
References: <20071003084241.24279.62099.sendpatchset@jackhammer.engr.sgi.com>
	 <6599ad830710030851jb44f00ft9634f9381218b6e9@mail.gmail.com>
	 <20071003105817.7adf6516.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758909AbXJCSLc@vger.kernel.org>
In-Reply-To: <20071003105817.7adf6516.pj@sgi.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Jackson <pj@sgi.com>
Cc: akpm@linux-foundation.org, nickpiggin@yahoo.com.au, a.p.zijlstra@chello.nl, serue@us.ibm.com, clg@fr.ibm.com, linux-kernel@vger.kernel.org, ebiederm@xmission.com, rientjes@google.com, svaidy@linux.vnet.ibm.com, xemul@openvz.org, containers@lists.osdl.org, balbir@linux.vnet.ibm.com
List-Id: containers.vger.kernel.org

On 10/3/07, Paul Jackson <pj@sgi.com> wrote:
>
> Yes, something in user space has to do it.  It's part of the
> kernel-user cpuset API.  If you change a cpuset's 'cpus', then
> you have to rewrite each pid in its 'tasks' file back to that
> 'tasks' file in order to get that 'cpus' change to be applied
> to the task struct cpus_allowed of each task, and thereby visible
> to the scheduler.

What's the rationale for this?

Given that later in cpusets.txt you say:

>If hotplug functionality is used
>to remove all the CPUs that are currently assigned to a cpuset,
>then the kernel will automatically update the cpus_allowed of all
>tasks attached to CPUs in that cpuset to allow all CPUs

why can't the same thing be done when changing the 'cpus' file manually.

What's wrong with, in update_cpumask(), doing a loop across all
members of the cgroup and updating their cpus_allowed fields?

The existing cpusets API is broken, since a new child can always be
forked between reading the tasks file and doing the writes.

Paul
