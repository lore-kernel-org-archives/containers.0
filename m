From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH v5 3/3] cgroups: make procs file writable
Date: Thu, 30 Dec 2010 12:38:30 +0800
Message-ID: <4D1C0CC6.4090107@cn.fujitsu.com>
References: <alpine.DEB.2.00.1012240245040.775@chino.kir.corp.google.com>
	<20101224114500.GA18036@ghc17.ghc.andrew.cmu.edu>
	<20101224035331.b907b410.akpm@linux-foundation.org>
	<20101224120853.GA18518@ghc17.ghc.andrew.cmu.edu>
	<20101224212452.GA27275@ghc17.ghc.andrew.cmu.edu>
	<alpine.DEB.2.00.1012241333010.13509@chino.kir.corp.google.com>
	<20101224230901.GA30136@ghc17.ghc.andrew.cmu.edu>
	<alpine.DEB.2.00.1012261345340.23173@chino.kir.corp.google.com>
	<20101227001233.GA10951@ghc17.ghc.andrew.cmu.edu>
	<alpine.DEB.2.00.1012270227010.3960@chino.kir.corp.google.com>
	<20101227103701.GC20986@ghc17.ghc.andrew.cmu.edu>
	<alpine.DEB.2.00.1012270240400.3960@chino.kir.corp.google.com>
	<4D1A913C.5080702@cn.fujitsu.com>
	<alpine.DEB.2.00.1012291624210.6040@chino.kir.corp.google.com>
	<4D1C0464.5090801@cn.fujitsu.com>
	<alpine.DEB.2.00.1012292019540.27634@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.1012292019540.27634-X6Q0R45D7oAcqpCFd4KODRPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

David Rientjes wrote:
> On Thu, 30 Dec 2010, Li Zefan wrote:
> 
>> That's what we did for cpu masks :). See commit
>> 2341d1b6598c7146d64a5050b53a72a5a819617f.
>>
>> I made a patchset to remove on stack cpu masks.
>>
>> What I meant is we don't have to allocate nodemasks in cpuset_sprintf_memlist().
>> This is sufficient:
>>
>> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
>> index 4349935..a159612 100644
>> --- a/kernel/cpuset.c
>> +++ b/kernel/cpuset.c
>> @@ -1620,20 +1620,12 @@ static int cpuset_sprintf_cpulist(char *page, struct cpu
>>
>>  static int cpuset_sprintf_memlist(char *page, struct cpuset *cs)
>>  {
>> -       NODEMASK_ALLOC(nodemask_t, mask, GFP_KERNEL);
>>         int retval;
>>
>> -       if (mask == NULL)
>> -               return -ENOMEM;
>> -
>>         mutex_lock(&callback_mutex);
>> -       *mask = cs->mems_allowed;
>> +       retval = nodelist_scnprintf(page, PAGE_SIZE, cs->mems_allowed);
>>         mutex_unlock(&callback_mutex);
>>
>> -       retval = nodelist_scnprintf(page, PAGE_SIZE, *mask);
>> -
>> -       NODEMASK_FREE(mask);
>> -
>>         return retval;
>>  }
>>
> 
> This needs to be done with cgroup_lock() instead of callback_mutex since 
> the post_clone() callback will store to cs->mems_allowed on 
> cgroup_clone().
> 

Then cpuset_post_clone() breaks the lock rule:

 * A task must hold both mutexes to modify cpusets...
 ...
 * If a task is only holding callback_mutex, then it has read-only
 * access to cpusets.

But that's Ok, because cgroup_clone() is called during the creation of
the new cgroup, so no one can access the cpuset at that time.
