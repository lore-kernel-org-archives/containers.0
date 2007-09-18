From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Hookup group-scheduler with task container
 infrastructure
Date: Tue, 18 Sep 2007 17:19:45 +0900
Message-ID: <20070918171945.d0593a08.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070910171049.GA16048@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753831AbXIRISn@vger.kernel.org>
In-Reply-To: <20070910171049.GA16048@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: vatsa@linux.vnet.ibm.com
Cc: Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, ckrm-tech@lists.sourceforge.net
List-Id: containers.vger.kernel.org

On Mon, 10 Sep 2007 22:40:49 +0530
Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com> wrote:
> +	tg->cfs_rq = kzalloc(sizeof(cfs_rq) * num_possible_cpus(), GFP_KERNEL);
> +	if (!tg->cfs_rq)
> +		goto err;
> +	tg->se = kzalloc(sizeof(se) * num_possible_cpus(), GFP_KERNEL);
> +	if (!tg->se)
> +		goto err;
Sorry for very lazy responce..

num_possible_cpus() just returns # of possible cpus. Then it will not return
Max-cpu-id to be used. I think just use NR_CPUS here is an easy way.

Thanks,
-Kame
