From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH][for -mm] per-zone and reclaim enhancements for memory
 controller take 3 [3/10] per-zone active inactive counter
Date: Thu, 29 Nov 2007 12:42:07 +0900
Message-ID: <20071129124207.b59ae745.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071127120048.ef5f2005.kamezawa.hiroyu@jp.fujitsu.com>
	<20071129033328.20E5F1CFEAA@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760811AbXK2DjV@vger.kernel.org>
In-Reply-To: <20071129033328.20E5F1CFEAA@siro.lan>
Sender: linux-kernel-owner@vger.kernel.org
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, akpm@linux-foundation.org, balbir@linux.vnet.ibm.com
List-Id: containers.vger.kernel.org

On Thu, 29 Nov 2007 12:33:28 +0900 (JST)
yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:

> > +static inline struct mem_cgroup_per_zone *
> > +mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
> > +{
> > +	if (!mem->info.nodeinfo[nid])
> 
> can this be true?
> 
> YAMAMOTO Takashi

When I set early_init=1, I added that check.
BUG_ON() is better ?

Thanks,
-Kame
