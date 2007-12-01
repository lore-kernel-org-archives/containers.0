From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][ only for review ] memory controller bacground reclaim
 [4/5] high/low watermark for memory controller
Date: Sat, 01 Dec 2007 22:46:19 +0530
Message-ID: <475196E3.2060500@linux.vnet.ibm.com>
References: <20071128174923.1f54f53f.kamezawa.hiroyu@jp.fujitsu.com>
	<20071128175607.37df2187.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830711302309p3a68828fjec6793bc9d854a1@mail.gmail.com>
	<47513B50.8090003@linux.vnet.ibm.com>
	<6599ad830712010855j7967ddeau1a558474de4eea19@mail.gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830712010855j7967ddeau1a558474de4eea19-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
> On Dec 1, 2007 2:45 AM, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
>>> which would correspond to a line in the "mem.api" auto-generated control file as
>>>
>> The user is expected to cat "memory.api" in order to figure out how to
>> use the file?
>>
> 
> Yes, the very first time they try to use a particular cgroup, if
> they've not bothered to read any documentation about it. There has to
> be some documentation *somewhere*, and putting some of the basic bits
> at a point where they're immediately accessible could be an advantage.
> 
> Paul

I worry about the kernel size bloat due to adding documentation in the
kernel. I don't think the documentation belongs to the kernel image, but
using file names like /proc/sys/vm/min_free_kbytes is a much better idea.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
