From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] cgroup: Fix indent for /proc/cgroups
Date: Fri, 03 Jul 2009 16:37:44 +0800
Message-ID: <4A4DC358.7030900__30487.8996721984$1246610363$gmane$org@cn.fujitsu.com>
References: <4A4DBBC2.8010805@cn.fujitsu.com> <4A4DBF50.8090408@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A4DBF50.8090408-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Li Zefan wrote:
> CC: container list
> 
> Gui Jianfeng wrote:
>> Currently, /proc/cgroups outputs is fairly ugly as following,
>> #subsys_name    hierarchy       num_cgroups     enabled
>> cpuset  0       1       1
>> debug   0       1       1
>> ns      0       1       1
>>
>> indent it in a good-looking way.
>> #subsys_name    hierarchy       num_cgroups     enabled
>> cpuset          0               1               1
>> debug           0               1               1
>> ns              0               1               1
>>
> 
> But if there's a subsystem with name length >= 8,
> it won't be aligned properly..

  Yeap, but there isn't such a case at least by now.

> 
>> Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
>> ---
>>  kernel/cgroup.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
>> index 3737a68..99fc160 100644
>> --- a/kernel/cgroup.c
>> +++ b/kernel/cgroup.c
>> @@ -2963,7 +2963,7 @@ static int proc_cgroupstats_show(struct seq_file *m, void *v)
>>  	mutex_lock(&cgroup_mutex);
>>  	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
>>  		struct cgroup_subsys *ss = subsys[i];
>> -		seq_printf(m, "%s\t%lu\t%d\t%d\n",
>> +		seq_printf(m, "%s\t\t%lu\t\t%d\t\t%d\n",
>>  			   ss->name, ss->root->subsys_bits,
>>  			   ss->root->number_of_cgroups, !ss->disabled);
>>  	}
> 
> 
> 
> 

-- 
Regards
Gui Jianfeng
