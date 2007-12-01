From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][ only for review ] memory controller bacground reclaim
 [4/5] high/low watermark for memory controller
Date: Sat, 01 Dec 2007 16:15:36 +0530
Message-ID: <47513B50.8090003@linux.vnet.ibm.com>
References: <20071128174923.1f54f53f.kamezawa.hiroyu@jp.fujitsu.com>
	<20071128175607.37df2187.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830711302309p3a68828fjec6793bc9d854a1@mail.gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830711302309p3a68828fjec6793bc9d854a1-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org" <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Nov 28, 2007 12:56 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
>>         {
>> +               .name = "low_watermark_in_bytes",
>> +               .private = RES_LOW_WATERMARK,
>> +               .write = mem_cgroup_write,
>> +               .read = mem_cgroup_read,
>> +       },
>> +       {
>> +               .name = "high_watermark_in_bytes",
>> +               .private = RES_HIGH_WATERMARK,
>> +               .write = mem_cgroup_write,
>> +               .read = mem_cgroup_read,
>> +       },
> 
> From a style point of view, I dislike having the "in_bytes" suffix
> tacked on to all the memory controller filenames.
> 

The idea came from Andrew, when he suggested it.

Please see /proc/sys/vm. We have files like min_free_kbyes, I think it's
a good idea to tell the user what units are used.

> If people really want this to be self-documenting, how about we allow
> cgroup control files to specify metadata, which would be presented to
> the user via an auto-generated "api" file.
> 
> As an example, the addition above might then look something like:
> 
> {
>     .name = "low_watermark",
>     .units = "bytes",
>     .description = "usage below which background reclaim stops",
>     .write = mem_cgroup_write,
>     .read = mem_cgroup_read,
> }
> 
> which would correspond to a line in the "mem.api" auto-generated control file as
> 

The user is expected to cat "memory.api" in order to figure out how to
use the file?

> low_watermark: usage below which background reclaim stops (bytes)
> 
> Paul


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
