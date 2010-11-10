From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 1/7] cgroups: Shrink struct cgroup_subsys
Date: Wed, 10 Nov 2010 08:52:34 +0800
Message-ID: <4CD9ECD2.3030805__2943.13374110988$1289350335$gmane$org@cn.fujitsu.com>
References: <4CC146A4.9090505@cn.fujitsu.com>	<4CC146BA.7080009@cn.fujitsu.com>	<AANLkTikf-1kLStxqi5UjP=vn3pqVBHy0OA7ibeWTkJ5z@mail.gmail.com>	<4CD78946.5060405@cn.fujitsu.com>
	<AANLkTim6d1fQLZbkmZST3PTN0RMSs3m=oossF81pYBn9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTim6d1fQLZbkmZST3PTN0RMSs3m=oossF81pYBn9-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
> On Sun, Nov 7, 2010 at 9:23 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>> bool active;
>> bool disabled;
>> ...
>>
>> ?
>>
>> With alignment 5-8 bool values == 8 bytes in 64-bit machine, compared to
>> 4 bytes with the approach this patch takes.
> 
> I meant specifying it as:
> 
> bool active:1;
> bool disabled:1;
> 

It won't compile, but unsigned char active:1 will do. ;)

> i.e. keeping the bit-sized flags but also keeping the bool semantics.
> Having said that, I'm not really sure why saving 12 bytes per
> subsystem is worth a patch.

Every thing that reduces code size (without sacrifice readability
and maintain maintainability) should be worth.

This is one of the reasons we accept patches that replacing
kmalloc+memset with kzalloc, which just saves 8 bytes in my box.
