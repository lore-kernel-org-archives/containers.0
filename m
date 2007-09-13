From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC][PATCH 0/3] Kernel memory accounting container (v2)
Date: Thu, 13 Sep 2007 15:33:07 +0400
Message-ID: <46E91FF3.7030105@openvz.org>
References: <46E8FEC7.2010707@openvz.org>
	<20070913191950.ea100a62.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070913191950.ea100a62.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
List-Id: containers.vger.kernel.org

KAMEZAWA Hiroyuki wrote:
> On Thu, 13 Sep 2007 13:11:35 +0400
> Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:
> 
>> First of all - why do we need this kind of control. The major
>> "pros" is that kernel memory control protects the system
>> from DoS attacks by processes that live in container. As our
>> experience shows many exploits simply do not work in the
>> container with limited kernel memory.
>>
>> I can split the kernel memory container into 4 parts:
>>
>> 1. kmalloc-ed objects control
>> 2. vmalloc-ed objects control
>> 3. buddy allocated pages control
>> 4. kmem_cache_alloc-ed objects control
>>
> <snip>
>> To play with it, one need to mount the container file system
>> with -o kmem and then mark some caches as accountable via
>> /sys/slab/<cache_name>/cache_account.
>>
> Hmm, how can we know "How many kmem will we need ?" in precise per-object
> style ? Is this useful ?  

You can start with unlimited container and check how many
kernel memory your applications use normally and set the limit
to 120% of this.

You may also set this to some reasonable value like 50% of normal
zone to protect your system from a fork bomb or similar.

This is the same question as "how many user pages will my
container consume". The answer is - find it out experimentally
or ask for someone who has already done so.

> Following kind of limitation of user friendly params is bad ?
> 
>  - # of file handles
>  - # of tasks
>  - # of sockets/ connections / packets
>  - # of posix IPC related things
>  - and other sources of DoS.

These are not enough and none of them are reasonable. E.g. the
struct vm_area_struct objects are allocated for many mmap() calls,
but how to find it out how many of them you will require.

However some controllers will be done as well.

> Thanks,
> -Kame
> 
> 
> 
