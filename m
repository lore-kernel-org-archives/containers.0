From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH 5/5] blk-cgroup: Fix an RCU warning in blkiocg_create()
Date: Fri, 7 May 2010 08:57:41 +0200
Message-ID: <20100507065741.GW27497@kernel.dk>
References: <4BD016F4.8060108@cn.fujitsu.com> <4BD017AC.1020209@cn.fujitsu.com> <20100422195725.GM2524@linux.vnet.ibm.com> <4BE3B985.1000407@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4BE3B985.1000407@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: paulmck@linux.vnet.ibm.com, "containers@lists.osdl.org" <containers@lists.osdl.org>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Vivek Goyal <vgoyal@redhat.com>, Gui Jianfeng <GuiJianfeng@cn.fujitsu.com>
List-Id: containers.vger.kernel.org

On Fri, May 07 2010, Li Zefan wrote:
> Paul E. McKenney wrote:
> > On Thu, Apr 22, 2010 at 05:32:28PM +0800, Li Zefan wrote:
> >> with CONFIG_PROVE_RCU=y, a warning can be triggered:
> >>
> >>   # mount -t cgroup -o blkio xxx /mnt
> >>   # mkdir /mnt/subgroup
> >>
> >> ...
> >> kernel/cgroup.c:4442 invoked rcu_dereference_check() without protection!
> >> ...
> >>
> >> To fix this, we avoid caling css_depth() here, which is a bit simpler
> >> than the original code.
> > 
> > Queued for 2.6.34, thank you!
> > 
> 
> Seems neither you nor Jens queued this patch...

I've included it now, thanks.

-- 
Jens Axboe
