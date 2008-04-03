From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH -mm 2/3] cgroup: simplify init_subsys()
Date: Thu, 03 Apr 2008 12:59:34 +0800
Message-ID: <47F46436.3060607__16395.0799651959$1207199048$gmane$org@cn.fujitsu.com>
References: <47F2EC94.8030707@cn.fujitsu.com>
	<6599ad830804020326o7947e3e5k25249e6b1c00e6b5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830804020326o7947e3e5k25249e6b1c00e6b5-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Tue, Apr 1, 2008 at 7:16 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>>  -
>>  -       /* If this subsystem requested that it be notified with fork
>>  -        * events, we should send it one now for every process in the
>>  -        * system */
>>  -       if (ss->fork) {
>>  -               struct task_struct *g, *p;
>>  -
>>  -               read_lock(&tasklist_lock);
>>  -               do_each_thread(g, p) {
>>  -                       ss->fork(ss, p);
>>  -               } while_each_thread(g, p);
>>  -               read_unlock(&tasklist_lock);
>>  -       }
> 
> Should we maybe call ss->fork(ss, &init_task) ? Or just document that
> ss->fork() explicitly doesn't get called for init.
> 
> Maybe also add some BUG()s to confirm that no other tasks have in fact
> been forked by this point?
> 

At system boot, before all the subsystems have been registered, no processes
including init has been forked, am I right? So the fork callback will be
invoked when the init process is forked, so we don't need to call
ss->fork(ss, &init_task).

I'll add a BUG_ON(), and update the document about the fork callback.

Regards,
Li Zefan
