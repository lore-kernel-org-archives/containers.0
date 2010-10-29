From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH v4 06/11] memcg: add dirty page accounting
 infrastructure
Date: Fri, 29 Oct 2010 19:13:00 +0800
Message-ID: <20101029111300.GB29774@localhost>
References: <1288336154-23256-1-git-send-email-gthelen@google.com>
 <1288336154-23256-7-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <1288336154-23256-7-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-Id: containers.vger.kernel.org

On Fri, Oct 29, 2010 at 03:09:09PM +0800, Greg Thelen wrote:

> +
> +	case MEMCG_NR_FILE_DIRTY:
> +		/* Use Test{Set,Clear} to only un/charge the memcg once. */
> +		if (val > 0) {
> +			if (TestSetPageCgroupFileDirty(pc))
> +				val = 0;
> +		} else {
> +			if (!TestClearPageCgroupFileDirty(pc))
> +				val = 0;
> +		}

I'm wondering why TestSet/TestClear and even the cgroup page flags for
dirty/writeback/unstable pages are necessary at all (it helps to
document in changelog if there are any). For example, VFS will call
TestSetPageDirty() before calling
mem_cgroup_inc_page_stat(MEMCG_NR_FILE_DIRTY), so there should be no
chance of false double counting.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
