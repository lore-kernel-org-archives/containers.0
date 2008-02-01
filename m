From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC] Default child of a cgroup
Date: Fri, 01 Feb 2008 09:02:33 +0530
Message-ID: <47A292D1.1040600@linux.vnet.ibm.com>
References: <20080131024049.GA9544@linux.vnet.ibm.com> <6599ad830801311839x33cf2ebco9f501571fc129b11@mail.gmail.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760594AbYBADeA@vger.kernel.org>
In-Reply-To: <6599ad830801311839x33cf2ebco9f501571fc129b11@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: vatsa@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, a.p.zijlstra@chello.nl, Ingo Molnar <mingo@elte.hu>, containers@lists.osdl.org, dhaval@linux.vnet.ibm.com, Balbir Singh <balbir@in.ibm.com>, pj@sgi.comDhaval Giani <dhaval@linux.vnet.ibm.com>
List-Id: containers.vger.kernel.org

Paul Menage wrote:

[snip]
> BTW, I noticed this code in cpu_cgroup_create():
> 
>         /* we support only 1-level deep hierarchical scheduler atm */
>         if (cgrp->parent->parent)
>                 return ERR_PTR(-EINVAL);
> 
> Is anyone working on allowing more levels?
> 

Yes, Dhaval nad Vatsa are looking at removing that limitation.
This discussion is a side-effect of the multi-hierarchy discussion/implementation.

> Paul


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
