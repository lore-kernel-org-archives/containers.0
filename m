From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC] [PATCH] cgroup: add "procs" control file
Date: Thu, 19 Jun 2008 11:07:14 +0800
Message-ID: <4859CD62.8090402__42429.2138116018$1213845179$gmane$org@cn.fujitsu.com>
References: <4858C111.8050806@cn.fujitsu.com>
	<20080619091436.0a441351.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080619091436.0a441351.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

KAMEZAWA Hiroyuki wrote:
> On Wed, 18 Jun 2008 16:02:25 +0800
> Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> 
>> This control file is the equivalent of the "tasks" control file, but
>> acting/reporting on entire thread groups.
>>
>> For example, we have a process with pid 1000 and its sub-thread with
>> tid 1001, to attach them into a cgroup:
>>  # echo 1000 > procs
>> Then show the process list and the task list respectively:
>>  # cat procs
>>  1000
>>  # cat tasks
>>  1000
>>  1001
>>
>> Questions:
>> - What to do if the attaching of a thread failed? continue to attach
>>   other threads, or stop and return error?
>> - When a sub-thread of a process is in the cgroup, but not its thread
>>   cgroup leader, what to do when 'cat procs'? just skip those threads?
>>
> I think this feature make sense. But not meets a theory that cgroup handles
> a thread not a process. So, how about changing the definition of this interface
> from
>   - showing procs
> to
>   - showing threads which is thread-group-leader.
> 
> One possible problem is a case that thread-group-leader exits while other
> members are alive. In such case, thread-group-leader calls cgroup_exit()
> but will be still alive until all sub-threads exit. So, this interface
> cannot show correct information. 
> (right ??? please point out if I miss something)
> 
> So, how about this kind of interface ? showing both of TID and PID.
> 
> %/cat/procs
> TID  PID
> 1001 1001
> 1234 1001
> 3856 1001
> 728  728
> ....
> ....
> 
> nonsense ?
> 

Then the left column is exactly the same with the contents of `cat tasks`, so IMO
it won't be useful. Besides, the tasks of pids listed in the right column may not
all belongs to that group, so how we can make use of this column?
