From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC][PATCH 2/4] res_counter check usage under val
Date: Wed, 30 Jul 2008 16:34:53 +0400
Message-ID: <48905FED.9090909@openvz.org>
References: <4884CA4F.9060003@openvz.org>	
	<20080718193123.cf74b574.kamezawa.hiroyu@jp.fujitsu.com>	
	<20080718193530.578fb1e3.kamezawa.hiroyu@jp.fujitsu.com>	
	<26133366.1217233738316.kamezawa.hiroyu@jp.fujitsu.com>	
	<488FCD42.4090309@openvz.org>
	<6599ad830807300441w5b1c149dg7dc0f4eb521439e7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830807300441w5b1c149dg7dc0f4eb521439e7-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Tue, Jul 29, 2008 at 7:09 PM, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:
>>> I get your point. Logically this lock is unnecessary.
>>> (And seems this patch itself is buggy..(maybe refresh miss))
>>>
>>> BTW, I'm sorry if I misunderstand. unsigned long long (on x86-32)
>>> can be compared safely ?
>> Oops... Indeed.
>> That discourages me, that we need a spinlock for simple comparisons :(
>>
> 
> We could add a function to read a res_counter that only takes a
> spinlock on architectures where a 64-bit value can't be read
> atomically.

Agree.

BTW, I think it's a good candidate for some generic, I don't know, data
type? Or some helper like arch_prepare_long_read(), that is void on 64 
bit ones and some variant of seqcount (*count*, not seq*lock*) for 32.

> Also, for values that are monotonically increasing, I think it should
> be possible to read a 64-bit value without locking by checking that
> reading the value twice either side of an appropriate memory value
> returns the same result both times.
> 
> Paul
> 
