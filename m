From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [Ksummit-2010-discuss] checkpoint-restart: naked patch
Date: Thu, 18 Nov 2010 15:25:33 -0500
Message-ID: <4CE58BBD.8010706@cs.columbia.edu>
References: <AANLkTinOg6n3ZA+0gHzw9LouRuUmJ7DJwHtABRy5c=gM@mail.gmail.com>
	<4CD26948.7050009@kernel.org>
	<20101104164401.GC10656@sundance.ccs.neu.edu>
	<4CD3CE29.2010105@kernel.org>
	<20101106053204.GB12449@count0.beaverton.ibm.com>
	<20101106204008.GA31077@sundance.ccs.neu.edu>
	<4CD5D99A.8000402@cs.columbia.edu>
	<20101107184927.GF31077@sundance.ccs.neu.edu>
	<4CD72150.9070705@cs.columbia.edu> <4CE3C334.9080401@kernel.org>
	<20101117221713.GA27736@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101117221713.GA27736-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Kapil Arya <kapil-1vnkWVZi4QaVc3sceRu5cw@public.gmane.org>, Gene Cooperman <gene-1vnkWVZi4QaVc3sceRu5cw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ksummit-2010-discuss-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, hch-jcswGhMUV9g@public.gmane.org
List-Id: containers.vger.kernel.org



On 11/17/2010 05:17 PM, Matt Helsley wrote:
> On Wed, Nov 17, 2010 at 12:57:40PM +0100, Tejun Heo wrote:
>> Hello, Oren.
>>
>> On 11/07/2010 10:59 PM, Oren Laadan wrote:

<snip>

>>> Or we could use linux-cr for that: do the c/r in the kernel,
>>> keep the know-how in the kernel, expose (and commit to) a
>>> per-kernel-version ABI (not vow to keep countless new individual
> 
> Oren, that statement might be read to imply that it's based on
> something as useless as kernel version numbers. Arnd has pointed out in the
> past how unsuitable that is and I tend to agree. There are at least two
> possible things we can relate it to: the SHA of the compiled kernel tree
> (which doesn't quite work because it assumes everybody uses git trees :( ),
> or perhaps the SHA/hash of the cpp-processed checkpoint_hdr.h. We could
> also stuff that header into the kernel (much like kconfigs are output from
> /proc) for programs that want the kernel to describe the ABI to them.

BTW, it's the same for userspace c/r: for the same set of features,
the format (ABI) remains unchanged. Adding features breaks this and
a new version is necessary, and conversion from old to new will be
needed.

Moreover, supporting a new feature in userspace means adding the
proper API/ABI in the kernel, including refactoring etc, which is
even harder than adding the support for it in linux-cr.

Oren.
