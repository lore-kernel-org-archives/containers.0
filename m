From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] task containersv11 add tasks file interface fix for
 cpusets
Date: Wed, 3 Oct 2007 10:58:17 -0700
Message-ID: <20071003105817.7adf6516.pj@sgi.com>
References: <20071003084241.24279.62099.sendpatchset@jackhammer.engr.sgi.com>
	<6599ad830710030851jb44f00ft9634f9381218b6e9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758621AbXJCR6c@vger.kernel.org>
In-Reply-To: <6599ad830710030851jb44f00ft9634f9381218b6e9@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: akpm@linux-foundation.org, nickpiggin@yahoo.com.au, a.p.zijlstra@chello.nl, serue@us.ibm.com, clg@fr.ibm.com, linux-kernel@vger.kernel.org, ebiederm@xmission.com, rientjes@google.com, svaidy@linux.vnet.ibm.com, xemul@openvz.org, containers@lists.osdl.org, balbir@linux.vnet.ibm.com
List-Id: containers.vger.kernel.org

Paul M wrote:
> > The code in kernel/cgroup.c attach_task() which skips the
> > attachment of a task to the group it is already in has to be
> > removed.  Cpusets depends on reattaching a task to its current
> > cpuset, in order to trigger updating the cpus_allowed mask in the
> > task struct.
> 
> Can you explain a bit more about why this is needed? (i.e. specific
> scenarios where cpusets will break without this change).
> 
> What triggers the reattach in normal use? Something from userspace?

Yes, something in user space has to do it.  It's part of the
kernel-user cpuset API.  If you change a cpuset's 'cpus', then
you have to rewrite each pid in its 'tasks' file back to that
'tasks' file in order to get that 'cpus' change to be applied
to the task struct cpus_allowed of each task, and thereby visible
to the scheduler.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
