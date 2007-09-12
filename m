From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm PATCH 1/9] Memory controller resource counters (v6)
Date: Wed, 12 Sep 2007 15:35:14 +0530
Message-ID: <46E7B9DA.6070404@linux.vnet.ibm.com>
References: <20070817084228.26003.12568.sendpatchset@balbir-laptop> <20070817084238.26003.7733.sendpatchset@balbir-laptop> <6599ad830709101742k658234b4of59f14ef27e40d14@mail.gmail.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933798AbXILKJ7@vger.kernel.org>
In-Reply-To: <6599ad830709101742k658234b4of59f14ef27e40d14@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, Eric W Biederman <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> Hi Balbir/Pavel,
> 
> As I mentioned to you directly at the kernel summit, I think it might
> be cleaner to integrate resource counters more closely with control
> groups. So rather than controllers such as the memory controller
> having to create their own boilerplate cf_type structures and
> read/write functions, it should be possible to just call a function
> something like
> 
> control_group_add_rescounter(struct cgroup *cg, struct cgroup_subsys *ss,
>                                              struct res_counter *res,
> const char *name)
> 
> and have it handle all the userspace API. This would simplify the task
> of keeping a consistent userspace API between different controllers
> using the resource counter abstraction.
> 
> Paul
> 

Yes, I remember discussing it with you. I would expect res_counters
definition to be dynamic (to be able to add the guarantee, soft limit,
etc) for expansion in the future. In the future, I would also like
to do hierarchical resource groups, the hierarchy would represent
the current filesystem hierarchy.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
