From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 0/5] Kernel memory accounting container (v5)
Date: Mon, 01 Oct 2007 19:43:44 +0400
Message-ID: <470115B0.2030402@openvz.org>
References: <46F91841.9070708@openvz.org> <4701006B.6050809@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4701006B.6050809-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Balbir Singh wrote:
> Pavel Emelyanov wrote:
>> Changes since v.4:
>> * make SLAB_NOTIFY caches mark pages as SlabDebug. That
>>   makes the interesting paths simpler (thanks to Christoph);
>> * the change above caused appropriate changes in "turn
>>   notifications on" path - all available pages must become 
>>   SlabDebug and page's freelists must be flushed;
>> * added two more events - "on" and "off" to make kmalloc
>>   caches disabling more gracefully;
>> * turning notifications "off" is marked as "TODO". Right
>>   now it's hard w/o massive rework of slub.c in respect to
>>   full slabs handling.
>>
>> Changes since v.3:
>> * moved alloc/free notification into slow path and make
>>   "notify-able" caches walk this path always;
>> * introduced some optimization for the case, when there's
>>   only one listener for SLUB events (saves more that 10%
>>   of performance);
>> * ported on 2.6.23-rc6-mm1 tree.
>>
>> Changes since v.2:
>> * introduced generic notifiers for slub. right now there
>>   are only events, needed by accounting, but this set can
>>   be extended in the future;
>> * moved the controller core into separate file, so that
>>   its extension and/or porting on slAb will look more 
>>   logical;
>> * fixed this message :).
>>
>> Changes since v.1:
>> * fixed Paul's comment about subsystem registration;
>> * return ERR_PTR from ->create callback, not NULL;
>> * make container-to-object assignment in rcu-safe section;
>> * make turning accounting on and off with "1" and "0".
>>
> 
> Hi, Pavel,
> 
> Overall, the patches look good, except for the comments
> noted in the other patch postings. I am going to test
> these patches and see how they hold out.
> 

OK, thanks. It's already time to go home now, so I will send
them to Andrew tomorrow. Maybe you'll find some more BUGs by
that time :)

BTW, Acked-by-s from different teams make Andrew more willing
to accept the patches ;)

Thanks,
Pavel
