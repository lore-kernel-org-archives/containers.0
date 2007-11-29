From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH][for -mm] per-zone and reclaim enhancements for memory
 controller take 3 [3/10] per-zone active inactive counter
Date: Thu, 29 Nov 2007 12:25:32 +0900
Message-ID: <20071129122532.68ff4e75.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071127120048.ef5f2005.kamezawa.hiroyu@jp.fujitsu.com>
	<20071129031937.3C86F1CFE80@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758530AbXK2DXg@vger.kernel.org>
In-Reply-To: <20071129031937.3C86F1CFE80@siro.lan>
Sender: linux-kernel-owner@vger.kernel.org
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, akpm@linux-foundation.org, balbir@linux.vnet.ibm.com
List-Id: containers.vger.kernel.org

On Thu, 29 Nov 2007 12:19:37 +0900 (JST)
yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:

> > @@ -651,10 +758,11 @@
> >  		/* Avoid race with charge */
> >  		atomic_set(&pc->ref_cnt, 0);
> >  		if (clear_page_cgroup(page, pc) == pc) {
> > +			int active;
> >  			css_put(&mem->css);
> > +			active = pc->flags & PAGE_CGROUP_FLAG_ACTIVE;
> >  			res_counter_uncharge(&mem->res, PAGE_SIZE);
> > -			list_del_init(&pc->lru);
> > -			mem_cgroup_charge_statistics(mem, pc->flags, false);
> > +			__mem_cgroup_remove_list(pc);
> >  			kfree(pc);
> >  		} else 	/* being uncharged ? ...do relax */
> >  			break;
> 
> 'active' seems unused.
> 
ok, I will post clean-up against -mm2.

Thanks,
-Kame
