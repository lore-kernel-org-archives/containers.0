From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: lock-free clear page writeback  (Was Re: [PATCH
 04/10] memcg: disable local interrupts in lock_page_cgroup()
Date: Thu, 7 Oct 2010 18:05:29 +0900
Message-ID: <20101007180529.1240e79a.kamezawa.hiroyu@jp.fujitsu.com>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
	<1286175485-30643-5-git-send-email-gthelen@google.com>
	<20101005160332.GB9515@barrios-desktop>
	<xr93wrpwkypv.fsf@ninji.mtv.corp.google.com>
	<AANLkTikKXNx-Cj2UY+tJj8ifC+Je5WDbS=eR6xsKM1uU@mail.gmail.com>
	<20101007093545.429fe04a.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007105456.d86d8092.nishimura@mxp.nes.nec.co.jp>
	<20101007111743.322c3993.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007152111.df687a62.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007152422.c5919517.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20101007152422.c5919517.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-Id: containers.vger.kernel.org

On Thu, 7 Oct 2010 15:24:22 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Greg, I think clear_page_writeback() will not require _any_ locks with this patch.
> But set_page_writeback() requires it...
> (Maybe adding a special function for clear_page_writeback() is better rather than
>  adding some complex to switch() in update_page_stat())
> 

I'm testing a code like this.
==
       /* pc->mem_cgroup is unstable ? */
        if (unlikely(mem_cgroup_stealed(mem))) {
                /* take a lock against to access pc->mem_cgroup */
                if (!in_interrupt()) {
                        lock_page_cgroup(pc);
                        need_unlock = true;
                        mem = pc->mem_cgroup;
                        if (!mem || !PageCgroupUsed(pc))
                                goto out;
                } else if (idx == MEMCG_NR_FILE_WRITEBACK && (val < 0)) {
                        /* This is allowed */
                } else
                        BUG();
        }
==
Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
