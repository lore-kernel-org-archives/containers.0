From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 04/10] memcg: disable local interrupts in
 lock_page_cgroup()
Date: Thu, 7 Oct 2010 11:17:43 +0900
Message-ID: <20101007111743.322c3993.kamezawa.hiroyu@jp.fujitsu.com>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
	<1286175485-30643-5-git-send-email-gthelen@google.com>
	<20101005160332.GB9515@barrios-desktop>
	<xr93wrpwkypv.fsf@ninji.mtv.corp.google.com>
	<AANLkTikKXNx-Cj2UY+tJj8ifC+Je5WDbS=eR6xsKM1uU@mail.gmail.com>
	<20101007093545.429fe04a.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007105456.d86d8092.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20101007105456.d86d8092.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Minchan Kim <minchan.kim@gmail.com>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-Id: containers.vger.kernel.org

On Thu, 7 Oct 2010 10:54:56 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Thu, 7 Oct 2010 09:35:45 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Wed, 6 Oct 2010 09:15:34 +0900
> > Minchan Kim <minchan.kim@gmail.com> wrote:
> > 
> > > First of all, we could add your patch as it is and I don't expect any
> > > regression report about interrupt latency.
> > > That's because many embedded guys doesn't use mmotm and have a
> > > tendency to not report regression of VM.
> > > Even they don't use memcg. Hmm...
> > > 
> > > I pass the decision to MAINTAINER Kame and Balbir.
> > > Thanks for the detail explanation.
> > > 
> > 
> > Hmm. IRQ delay is a concern. So, my option is this. How do you think ?
> > 
> > 1. remove local_irq_save()/restore() in lock/unlock_page_cgroup().
> >    yes, I don't like it.
> > 
> > 2. At moving charge, do this:
> > 	a) lock_page()/ or trylock_page()
> > 	b) wait_on_page_writeback()
> > 	c) do move_account under lock_page_cgroup().
> > 	c) unlock_page()
> > 
> > 
> > Then, Writeback updates will never come from IRQ context while
> > lock/unlock_page_cgroup() is held by move_account(). There will be no race.
> > 
> hmm, if we'll do that, I think we need to do that under pte_lock in
> mem_cgroup_move_charge_pte_range(). But, we can't do wait_on_page_writeback()
> under pte_lock, right? Or, we need re-organize current move-charge implementation.
> 
Nice catch. I think releaseing pte_lock() is okay. (and it should be released)

IIUC, task's css_set() points to new cgroup when "move" is called. Then,
it's not necessary to take pte_lock, I guess.
(And taking pte_lock too long is not appreciated..)

I'll write a sample patch today.

Thanks,
-Kame








> Thanks,
> Daisuke Nishimura.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
