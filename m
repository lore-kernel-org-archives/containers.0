From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH -mmotm] res_counter: fix building failure
Date: Thu, 03 Jul 2008 12:17:24 +0200
Message-ID: <486CA734.1000200@gmail.com>
References: <486B1D3D.5070805@cn.fujitsu.com>
	<6599ad830807012345r4f02f9acq3c8e9be633e109e8@mail.gmail.com>
	<486B250D.3090605@cn.fujitsu.com>
Reply-To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <486B250D.3090605-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Li Zefan wrote:
> Paul Menage wrote:
>> On Tue, Jul 1, 2008 at 11:16 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>>> kernel/res_counter.c: In function 'res_counter_memparse_write_strategy':
>>> kernel/res_counter.c:115: error: implicit declaration of function 'PAGE_ALIGN'
>>>
>>> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
>> Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>>
>> Thanks - what architecture did it break on?
>>
> 
> On my x86_32.
> 
> I guess this break has something to do with:
> 
> http://marc.info/?l=linux-mm&m=121389282702302&w=2
> ([PATCH -mm] PAGE_ALIGN(): correctly handle 64-bit values on 32-bit)

Exactly, your fix sounds good to me. Thanks.

-Andrea

> 
> You tested the patch before that patch was accepted by Andrew.
> 
>> Paul
>>
>>> ---
>>>
>>> should follow cgroup-files-convert-res_counter_write-to-be-a-cgroups-write_string-handler.patch
>>>
>>> --- linux-mm/kernel/res_counter.c.bak   2008-07-02 14:05:37.000000000 +0800
>>> +++ linux-mm/kernel/res_counter.c       2008-07-02 14:07:36.000000000 +0800
>>> @@ -13,6 +13,7 @@
>>>  #include <linux/slab.h>
>>>  #include <linux/res_counter.h>
>>>  #include <linux/uaccess.h>
>>> +#include <linux/mm.h>
>>>
>>>  void res_counter_init(struct res_counter *counter)
>>>  {
>>>
