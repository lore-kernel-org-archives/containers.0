From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v4 06/11] memcg: add dirty page accounting
 infrastructure
Date: Fri, 29 Oct 2010 20:17:26 +0900
Message-ID: <20101029201726.370e462b.kamezawa.hiroyu@jp.fujitsu.com>
References: <1288336154-23256-1-git-send-email-gthelen@google.com>
	<1288336154-23256-7-git-send-email-gthelen@google.com>
	<20101029111300.GB29774@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20101029111300.GB29774@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-Id: containers.vger.kernel.org

On Fri, 29 Oct 2010 19:13:00 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> On Fri, Oct 29, 2010 at 03:09:09PM +0800, Greg Thelen wrote:
> 
> > +
> > +	case MEMCG_NR_FILE_DIRTY:
> > +		/* Use Test{Set,Clear} to only un/charge the memcg once. */
> > +		if (val > 0) {
> > +			if (TestSetPageCgroupFileDirty(pc))
> > +				val = 0;
> > +		} else {
> > +			if (!TestClearPageCgroupFileDirty(pc))
> > +				val = 0;
> > +		}
> 
> I'm wondering why TestSet/TestClear and even the cgroup page flags for
> dirty/writeback/unstable pages are necessary at all (it helps to
> document in changelog if there are any). For example, VFS will call
> TestSetPageDirty() before calling
> mem_cgroup_inc_page_stat(MEMCG_NR_FILE_DIRTY), so there should be no
> chance of false double counting.
> 

1. flag is necessary for moving accounting information between cgroups
   when account_move() occurs.

2. TestSet... is required because there are always race with page_cgroup_lock()'s
   lock bit.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
