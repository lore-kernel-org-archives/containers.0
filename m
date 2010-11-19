From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [Ksummit-2010-discuss] checkpoint-restart: naked patch
Date: Fri, 19 Nov 2010 17:32:31 +0100
Message-ID: <4CE6A69F.4030008@kernel.org>
References: <20101104164401.GC10656@sundance.ccs.neu.edu>	<4CD3CE29.2010105@kernel.org>	<20101106053204.GB12449@count0.beaverton.ibm.com>	<20101106204008.GA31077@sundance.ccs.neu.edu>	<4CD5D99A.8000402@cs.columbia.edu>	<20101107184927.GF31077@sundance.ccs.neu.edu>	<4CD72150.9070705@cs.columbia.edu>	<4CE3C334.9080401@kernel.org>	<20101117153902.GA1155@hallyn.com>	<4CE3F8D1.10003@kernel.org>	<20101119041045.GC24031@hallyn.com>	<4CE683E1.6010500@kernel.org>	<04F4899E-B5C7-4BAF-8F2F-05D507A91408@parallels.com>	<4CE698C5.5060806@kernel.org>	<AANLkTikRHuaCpaROtty6X_Oe6JixzgcbVsxHxvtsu+UV@mail.gmail.com>	<4CE6A076.2020807@kernel.org>	<AANLkTikz++4_SvqU_Wvx5CjcpKJhPsD7q470swdqwn94@mail.gmail.com>	<4CE6A397.6010105@kernel.org>
	<AANLkTin7kd3crS+fTLLea5PhAii7B3dz=n7p7YtQ6d4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTin7kd3crS+fTLLea5PhAii7B3dz=n7p7YtQ6d4g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Kapil Arya <kapil-1vnkWVZi4QaVc3sceRu5cw@public.gmane.org>, Kirill Korotaev <dev-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Pavel Emelianov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Gene Cooperman <gene-1vnkWVZi4QaVc3sceRu5cw@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On 11/19/2010 05:27 PM, Alexey Dobriyan wrote:
> On Fri, Nov 19, 2010 at 6:19 PM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>>> The paragon of absurdity is struct task_struct::did_exec .
>>
>> Yeah, then go and figure how to do that in a way which would be useful
>> for other purposes too instead of trying to shove the whole
>> checkpointer inside the kernel.  It sure would be harder but hey
>> that's the way it is.
> 
> System call for one bit? This is ridiculous.

Why not just a flag in proc entry?  It's a frigging single bit.

> Doing execve(2) for userspace C/R is ridicoulous too (and likely
> doesn't work).

Really, whatever.  Just keep doing what you're doing.  Hey, if it
makes you happy, it can't be too wrong.

-- 
tejun
