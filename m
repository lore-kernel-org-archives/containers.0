From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] introduce task cgroup v2
Date: Mon, 16 Jun 2008 15:59:25 +0900
Message-ID: <20080616155630.78A9.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080607195733.9C77.KOSAKI.MOTOHIRO@jp.fujitsu.com> <1213598394.16944.85.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759788AbYFPG7d@vger.kernel.org>
In-Reply-To: <1213598394.16944.85.camel@twins>
Sender: linux-kernel-owner@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: kosaki.motohiro@jp.fujitsu.com, containers@lists.osdl.org, LKML <linux-kernel@vger.kernel.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

Hi Peter,

> > # mount -t cgroup -o task none /dev/cgroup
> > # mkdir /dev/cgroup/foo
> > # cd /dev/cgroup/foo
> > # ls 
> > notify_on_release  task.max_tasks  task.nr_tasks  tasks
> > # echo 100 > task.max_tasks
> > # echo $$ > tasks
> > # fork_bomb 1000 &  <- try create 1000 process
> > # pgrep fork_bomb | wc -l
> > 98
> 
> fwiw I think the name sucks!
> cgroups are about grouping tasks, so what's a task cgroup?

Sorry, my english skill is very low.
I hope restrict number of tasks.

Do you have any name idea?
