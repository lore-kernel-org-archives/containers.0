From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] introduce task cgroup v2
Date: Mon, 16 Jun 2008 16:09:07 +0900
Message-ID: <20080616160802.78AF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080616155630.78A9.KOSAKI.MOTOHIRO@jp.fujitsu.com> <1213599882.16944.90.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760419AbYFPHKu@vger.kernel.org>
In-Reply-To: <1213599882.16944.90.camel@twins>
Sender: linux-kernel-owner@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: kosaki.motohiro@jp.fujitsu.com, containers@lists.osdl.org, LKML <linux-kernel@vger.kernel.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

> > > fwiw I think the name sucks!
> > > cgroups are about grouping tasks, so what's a task cgroup?
> > 
> > Sorry, my english skill is very low.
> > I hope restrict number of tasks.
> > 
> > Do you have any name idea?
> 
> Sadly I suck at naming too ;-(
> 
> perhaps task_limit controller, or nr_tasks controller.
> 
> We should preferably pick one that transfers to most other rlimit like
> controls.

Yeah, thanks.
I like "task_limit" controller.

I'll change to it.

very thanks.
