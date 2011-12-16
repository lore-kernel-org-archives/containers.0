From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] cgroups: fix a css_set not found bug in cgroup_attach_proc
Date: Fri, 16 Dec 2011 10:12:51 +0800
Message-ID: <4EEAA923.5060104__10239.0688298785$1324001476$gmane$org@cn.fujitsu.com>
References: <1323977803-5385-1-git-send-email-msb@chromium.org>
	<20111215212329.GH32002@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20111215212329.GH32002-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Olof Johansson <olofj-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
List-Id: containers.vger.kernel.org

Tejun Heo wrote:
> On Thu, Dec 15, 2011 at 11:36:43AM -0800, Mandeep Singh Baines wrote:
>> There is a BUG when migrating a PF_EXITING proc. Since css_set_prefetch()
>> is not called for the PF_EXITING case, find_existing_css_set() will return
>> NULL inside cgroup_task_migrate() causing a BUG.
>>
>> This bug is easy to reproduce. Create a zombie and echo its pid to
>> cgroup.procs.
>>
>> $ cat zombie.c
>> \#include <unistd.h>
>>
>> int main()
>> {
>>   if (fork())
>>       pause();
>>   return 0;
>> }
>> $
>>
>> We are hitting this bug pretty regularly on ChromeOS.
>>
>> This bug is already fixed by Tejun Heo's cgroup patchset which is
>> targetted for the next merge window:
>>
>> https://lkml.org/lkml/2011/11/1/356
>>
>> I've create a smaller patch here which just fixes this bug so that a
>> fix can be merged into the current release and stable.
> 
> Looks safe to me.  Li?
> 

It should be fine.

Reviewed-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
