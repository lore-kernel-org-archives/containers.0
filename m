From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 03/33] task containersv11 add tasks file interface
Date: Wed, 3 Oct 2007 10:51:57 -0700
Message-ID: <20071003105157.254c51a4.pj@sgi.com>
References: <20070917210307.116234000@menage.corp.google.com>
	<20070917210426.579524000@menage.corp.google.com>
	<20071003010923.c606c176.pj@sgi.com>
	<6599ad830710030816m32321b54gbc79c24d0a39941b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757347AbXJCRwU@vger.kernel.org>
In-Reply-To: <6599ad830710030816m32321b54gbc79c24d0a39941b@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: akpm@linux-foundation.org, balbir@linux.vnet.ibm.com, serue@us.ibm.com, clg@fr.ibm.com, ebiederm@xmission.com, xemul@openvz.org, rientjes@google.com, svaidy@linux.vnet.ibm.com, nickpiggin@yahoo.com.au, a.p.zijlstra@chello.nl, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Paul M wrote:
> Are there cases when userspace is
> required to try to reattach a task to its current cpuset in order to
> get a cpu mask change to stick?

Yes, there are such cases.

If tasks are running in a cpuset, and someone changes the
'cpus' of that cpuset, the tasks already in that cpuset don't
move.  They stay with their task structs cpus_allowed pointing
to the old value.  The only code path that user space can trigger
that leads to changing an existing tasks cpus_allowed mask is to
write that tasks pid to a cpuset 'tasks' file.

So after changing the 'cpus' of a cpuset, you (something in
user space) then has to rewrite every pid in that cpusets
tasks file back to that same tasks file, in order to get the
change to be applied to each of those tasks, and get them to
start running on their new CPUs.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
