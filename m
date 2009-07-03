From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] cgroup: Fix indent for /proc/cgroups
Date: Fri, 03 Jul 2009 17:00:19 +0800
Message-ID: <4A4DC8A3.9040709@cn.fujitsu.com>
References: <4A4DBBC2.8010805@cn.fujitsu.com> <4A4DBF50.8090408@cn.fujitsu.com>
	<4A4DC358.7030900@cn.fujitsu.com> <4A4DC4CF.4020808@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A4DC4CF.4020808-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
> Gui Jianfeng wrote:
>> Li Zefan wrote:
>>> CC: container list
>>>
>>> Gui Jianfeng wrote:
>>>> Currently, /proc/cgroups outputs is fairly ugly as following,
>>>> #subsys_name    hierarchy       num_cgroups     enabled
>>>> cpuset  0       1       1
>>>> debug   0       1       1
>>>> ns      0       1       1
>>>>
>>>> indent it in a good-looking way.
>>>> #subsys_name    hierarchy       num_cgroups     enabled
>>>> cpuset          0               1               1
>>>> debug           0               1               1
>>>> ns              0               1               1
>>>>
>>> But if there's a subsystem with name length >= 8,
>>> it won't be aligned properly..
>>   Yeap, but there isn't such a case at least by now.
>>
> 
> This is not a good reason.
> 
> We'll probably have such a subsystem. Actually there's a
> proposed subsystem named "maxdepth" which is of length 8.
> 
> See:
> http://lkml.org/lkml/2009/7/1/581

  yes, this is a case. But at least others can be aligned 
  properly, right? Anyway, please ignore it if you don't
  like this change.

> 
> 
> 
> 

-- 
Regards
Gui Jianfeng
