From: Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>
Subject: Re: [PATCH] Hookup group-scheduler with task container infrastructure
Date: Tue, 18 Sep 2007 16:14:37 +0530
Message-ID: <20070918104437.GA18221@linux.vnet.ibm.com>
References: <20070910171049.GA16048@linux.vnet.ibm.com> <20070918171945.d0593a08.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: vatsa@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756748AbXIRKeQ@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070918171945.d0593a08.kamezawa.hiroyu@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: containers@lists.osdl.org, Ingo Molnar <mingo@elte.hu>, ckrm-tech@lists.sourceforge.net, akpm@linux-foundation.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On Tue, Sep 18, 2007 at 05:19:45PM +0900, KAMEZAWA Hiroyuki wrote:
> Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com> wrote:
> > +	tg->cfs_rq = kzalloc(sizeof(cfs_rq) * num_possible_cpus(), GFP_KERNEL);
> > +	if (!tg->cfs_rq)
> > +		goto err;
> > +	tg->se = kzalloc(sizeof(se) * num_possible_cpus(), GFP_KERNEL);
> > +	if (!tg->se)
> > +		goto err;
> Sorry for very lazy responce..
> 
> num_possible_cpus() just returns # of possible cpus. Then it will not return
> Max-cpu-id to be used. I think just use NR_CPUS here is an easy way.

Good catch! Yes, you are right, the pointer array needs to be NR_CPUS
size.

On closer examination, I think I can simply use alloc_percpu() here.
Will send a patch after some testing.

-- 
Regards,
vatsa
