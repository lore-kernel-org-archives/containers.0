From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [cgroup or VFS ?] WARNING: at
	fs/namespace.c:636	mntput_no_expire+0xac/0xf2()
Date: Fri, 13 Feb 2009 15:26:05 +0800
Message-ID: <4995208D.8050700@cn.fujitsu.com>
References: <499013CC.2060808@cn.fujitsu.com> <4993BD5D.2020707@cn.fujitsu.com>
	<20090212062442.GE28946@ZenIV.linux.org.uk>
	<4993C2A0.3050507@cn.fujitsu.com> <4993C7C2.4060100@cn.fujitsu.com>
	<20090212070729.GF28946@ZenIV.linux.org.uk>
	<4995007D.7040101@cn.fujitsu.com>
	<20090213054751.GI28946@ZenIV.linux.org.uk>
	<49950F3D.3030704@cn.fujitsu.com>
	<20090213064135.GJ28946@ZenIV.linux.org.uk>
	<20090213071816.GK28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090213071816.GK28946-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
List-Id: containers.vger.kernel.org

Al Viro wrote:
> On Fri, Feb 13, 2009 at 06:41:35AM +0000, Al Viro wrote:
> 
> Aaaargh...
> 
>         /*
>          * We don't have to hold all of the locks at the
>          * same time here because we know that we're the
>          * last reference to mnt and that no new writers
>          * can come in.
>          */
>         for_each_possible_cpu(cpu) {
>                 struct mnt_writer *cpu_writer = &per_cpu(mnt_writers, cpu);
>                 if (cpu_writer->mnt != mnt)
>                         continue;
>                 spin_lock(&cpu_writer->lock);
> 
> is *almost* OK.  Modulo SMP cache coherency.  We know that nothing should
> be setting ->mnt to ours anymore, that's fine.  But we do not know if
> we'd seen *earlier* change done on CPU in question (not the one we
> are running __mntput() on).
> 
> I probably would still like to use milder solution in the long run, but for
> now let's check if turning that into
> 
>                 struct mnt_writer *cpu_writer = &per_cpu(mnt_writers, cpu);
>                 spin_lock(&cpu_writer->lock);
>                 if (cpu_writer->mnt != mnt) {
> 			spin_unlock(&cpu_writer->lock);
>                         continue;
> 		}
> prevents the problem, OK?
> 

Sure, I'll try. :)

BTW, thread2's rmdir failed:

rmdir: /cgroup/0: No such file or directory
