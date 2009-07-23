From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC][PATCH] flexible array implementation v3
Date: Thu, 23 Jul 2009 23:48:11 +0900 (JST)
Message-ID: <3b45d0f54f0f9c96727e4f9d07b97008.squirrel__11401.1111473248$1248360574$gmane$org@webmail-b.css.fujitsu.com>
References: <20090722175345.7154C2F2@kernel>
	<20090723104450.e0d421ca.kamezawa.hiroyu@jp.fujitsu.com>
	<1248357948.24021.692.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1248357948.24021.692.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: vda.linux-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Dave Hansen wrote:
> On Thu, 2009-07-23 at 10:44 +0900, KAMEZAWA Hiroyuki wrote:

>> The caller can't know whether
>>  - there are no entry or
>>  - NULL(0) is stored at the array.
>>
>> Then, he has to check gotten value is valid or not by himself.
>
> I think you may be reading this bit wrong.  Either that, or I badly
> miscoded it. :)  The flex_array_get() code should returns NULL in cases
> of error or the *address* of the data element.  It will actually return
> an address pointing into the second-level page.
>
> NULL's two meaning here are:
> 1. No element was ever put() here and thus there's no data page
> 2. Your index was out of bounds
>
> (1) is a little fuzzy here.  It of course doesn't absolutely guarantee
> that no put() was done since we just use the data page's existence to
> tell.  This is certainly no worse than a normal C array would be,
> though.
>
ok, maybe not necessary to handle.


>> Can't we return -ENOENT here(especially when prealloc() is called) ?
>> But ah, anyway, all-zero elements in allocated array exists ;(
>> and the user can get value from an entry never be put.
>>
>> If we can fill the first 4bytes of _unused_ index by some magic code
>> like this
>> #define FLEX_ARRAY_UNUSED_MAGIC		(0xa5a5a5a5)
>> (if maintaining bitmap/status of usage is nonsense)
>> and flex_array_get() can return -ENOENT, the users will feel easy.
>>
>> Overprotection ;) ?
>
> I intentionally didn't use kzalloc() for the data pages.  I figured that
> users will either initialize it themselves or pass in __GFP_ZERO.  I've
> added a comment to clarify this.
>

sorry for noise.
I just felt that this code expects users know all they really do.
As said, seems nice :) thank you.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
