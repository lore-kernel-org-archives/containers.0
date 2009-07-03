From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 1/9] [RFC] Support named cgroups hierarchies
Date: Fri, 03 Jul 2009 09:51:53 +0800
Message-ID: <4A4D6439.8030302__31269.014781765$1246586202$gmane$org@cn.fujitsu.com>
References: <20090702020624.14469.47066.stgit@menage.mtv.corp.google.com>	
	<20090702021057.14469.37548.stgit@menage.mtv.corp.google.com>	
	<20090702112814.ddf0c280.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830907011949h13598e36m45b85ae76900b90a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830907011949h13598e36m45b85ae76900b90a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

>>>  /*
>>>   * A cgroupfs_root represents the root of a cgroup hierarchy,
>>>   * and may be associated with a superblock to form an active
>>> @@ -93,6 +95,9 @@ struct cgroupfs_root {
>>>
>>>       /* The path to use for release notifications. */
>>>       char release_agent_path[PATH_MAX];
>>> +
>>> +     /* The name for this hierarchy - may be empty */
>>> +     char name[MAX_CGROUP_ROOT_NAMELEN];
>>>  };
>>>
>> If you don't want to make cgroupfs_root bigger,
>>
>>        cgroupfs_root {
>>                ......
>>                /* this must be the bottom of struct */
>>                char name[0];
>>        }
>>
>> Is a choice.
> 
> I'd rather avoid something like that since I think it's less readable
> - I'd probably just make the name into a pointer in that case.
> 

Whichever choice we make, the length should be limited I think.

>> BTW, reading a patch, any kind of charactors are allowed ?
> 
> Yes, other than \000 of course. I guess maybe I should use
> seq_escape() to print the name to avoid confusion in the event that
> people put whitespace in there, or else just ban whitespace (or maybe
> all non-alphanumeric chars).
> 

I don't think we need to care about this.

mount -t cgroup -o debug xxx /mnt

"xxx" can be any chars.
