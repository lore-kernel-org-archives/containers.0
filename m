From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 7/7] cgroups: Update documentation for bindable subsystems
Date: Mon, 25 Oct 2010 08:56:42 +0800
Message-ID: <4CC4D5CA.3080409__34149.8937611052$1287968268$gmane$org@cn.fujitsu.com>
References: <4CC146A4.9090505@cn.fujitsu.com>	<4CC14769.2000406@cn.fujitsu.com>
	<20101025093617.7de750c0.kamezawa.hiroyu@jp.fujitsu.com>
	<4CC4D4B9.3020807@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4CC4D4B9.3020807-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "akpm >> Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Li Zefan wrote:
> KAMEZAWA Hiroyuki wrote:
>> On Fri, 22 Oct 2010 16:12:25 +0800
>> Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>>
>>> Provide a usage example, and update the bind() callback API.
>>>
>>> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
>>> ---
>>>  Documentation/cgroups/cgroups.txt |   26 +++++++++++++++++---------
>>>  1 files changed, 17 insertions(+), 9 deletions(-)
>>>
>>> diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
>>> index 190018b..5b5382a 100644
>>> --- a/Documentation/cgroups/cgroups.txt
>>> +++ b/Documentation/cgroups/cgroups.txt
>>> @@ -363,17 +363,23 @@ Note this will add ns to the hierarchy but won't remove memory or
>>>  cpuset, because the new options are appended to the old ones:
>>>  # mount -o remount,ns /dev/cgroup
>>>  
>>> +For some subsystems you can bind them to a mounted hierarchy or
>>> +remove them from it, even if there're sub-cgroups in it:
>>> +# mount -t cgroup -o freezer hier1 /dev/cgroup
>>> +# echo $$ > /dev/cgroup/my_cgroup
>>> +# mount -o freezer,cpuset hier1 /dev/cgroup
>>> +(failed)
>>> +# mount -o freezer,cpuacct hier1 /dev/cgroup
>>> +# mount -o cpuacct hier1 /dev/cgroup
>>> +
>>> +Note cpuacct should be sit in the default hierarchy before remount.
>>> +
>> Can this operation be used with noop cgroup ?
>> (IOW, perf cgroup can be attached to noop cgroup ?)
>>
> 
> Yes, you can. I've tested it.

But, wait. It stuck when I moved a task from a sub-cgroup to the root.
Need to dig more..
