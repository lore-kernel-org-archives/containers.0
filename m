From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [PATCH] introduce task cgroup v2
Date: Mon, 16 Jun 2008 15:01:47 +0800
Message-ID: <48560FDB.9070206@cn.fujitsu.com>
References: <20080607195733.9C77.KOSAKI.MOTOHIRO@jp.fujitsu.com> <484E0F7F.3000606@cn.fujitsu.com> <20080616111410.7896.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759553AbYFPHDe@vger.kernel.org>
In-Reply-To: <20080616111410.7896.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: containers@lists.osdl.org, LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

I guess you didn't notice this comment ? :)

>> --- a/kernel/fork.c
>> > +++ b/kernel/fork.c
>> > @@ -54,6 +54,7 @@
>> >  #include <linux/tty.h>
>> >  #include <linux/proc_fs.h>
>> >  #include <linux/blkdev.h>
>> > +#include <linux/cgroup_task.h>
>> >  
>> >  #include <asm/pgtable.h>
>> >  #include <asm/pgalloc.h>
>> > @@ -920,6 +921,8 @@ static struct task_struct *copy_process(
>> >  		    p->user != current->nsproxy->user_ns->root_user)
>> >  			goto bad_fork_free;
>> >  	}
>> > +	if (task_cgroup_can_fork(p))
>> > +		goto bad_fork_free;
> 
> If task_cgroup_can_fork() returns 0, but copy_process() fails afterwords,
> taskcg->nr_tasks will be in a wrong state.
> 
