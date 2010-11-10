From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 1/7] cgroups: Shrink struct cgroup_subsys
Date: Wed, 10 Nov 2010 10:06:37 +0800
Message-ID: <4CD9FE2D.2070108__15029.8390457921$1289354826$gmane$org@cn.fujitsu.com>
References: <4CC146A4.9090505@cn.fujitsu.com> <4CC146BA.7080009@cn.fujitsu.com>
	<AANLkTikf-1kLStxqi5UjP=vn3pqVBHy0OA7ibeWTkJ5z@mail.gmail.com>
	<4CD78946.5060405@cn.fujitsu.com>
	<AANLkTim6d1fQLZbkmZST3PTN0RMSs3m=oossF81pYBn9@mail.gmail.com>
	<4CD9ECD2.3030805@cn.fujitsu.com>
	<AANLkTinMr7VE4Os7rXWjiHWOVysv=oE0vHKduLWCN0bC@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTinMr7VE4Os7rXWjiHWOVysv=oE0vHKduLWCN0bC-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "akpm >> Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Tue, Nov 9, 2010 at 4:52 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>>> bool active:1;
>>> bool disabled:1;
>>>
>> It won't compile, but unsigned char active:1 will do. ;)
> 
> Are you sure? I don't have a buildable kernel tree at the moment, but
> the following fragment compiled fine for me (with gcc 4.4.3):
> 
> struct foo {
>   _Bool b1:1;
>   _Bool b2:1;
> };
> 
> and was sized at one byte. And "bool" is just a typedef of _Bool in
> the kernel headers.
> 

Oops, I just used bool outside kernel tree..

>> Every thing that reduces code size (without sacrifice readability
>> and maintain maintainability) should be worth.
> 
> Agreed, within reason. But this patch doesn't reduce code size - it

I meant binary size.

> makes the code fractionally more complicated and reduces the *binary*
> size by a few bytes.
> 

It's a commonly used skill in kernel code, so I can't say it makes
code more complicated.

That said, I'll happily drop this patch. It just came to me when I
started to add new bool values to the structure. Or if you prefer
bool xxx:1 or just bool xxx, I can do that.

>> This is one of the reasons we accept patches that replacing
>> kmalloc+memset with kzalloc, which just saves 8 bytes in my box.
>>
> 
> Replacing two function calls with one function call is a code
> simplification and hence (generally) a good thing - the minuscule
> reduction in binary size reduction that comes with it is just noise.
> 
