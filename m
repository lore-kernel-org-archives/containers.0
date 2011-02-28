From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v5 6/9] memcg: add kernel calls for memcg dirty page
 stats
Date: Mon, 28 Feb 2011 11:40:18 +0900
Message-ID: <20110228114018.390ce291.kamezawa.hiroyu@jp.fujitsu.com>
References: <1298669760-26344-1-git-send-email-gthelen@google.com>
	<1298669760-26344-7-git-send-email-gthelen@google.com>
	<20110227170143.GE3226@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20110227170143.GE3226@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>
List-Id: containers.vger.kernel.org

On Mon, 28 Feb 2011 02:01:43 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Fri, Feb 25, 2011 at 01:35:57PM -0800, Greg Thelen wrote:
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
> >  	} else {
> > @@ -1365,6 +1368,7 @@ int test_set_page_writeback(struct page *page)
> >  						PAGECACHE_TAG_WRITEBACK);
> >  			if (bdi_cap_account_writeback(bdi))
> >  				__inc_bdi_stat(bdi, BDI_WRITEBACK);
> > +			mem_cgroup_inc_page_stat(page, MEMCG_NR_FILE_WRITEBACK);
> 
> Question:
> Why should we care of BDI_CAP_NO_WRITEBACK?
> 
Hmm, should we do ..
==
        if (!ret) {
                account_page_writeback(page);
+		mem_cgroup_inc_page_stat(page, MEMCG_NR_FILE_WRITEBACL);
	}
==

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
