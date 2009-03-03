From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] Allow cpusets to be configured/built on non-SMP systems
Date: Tue, 03 Mar 2009 16:54:33 +0800
Message-ID: <49ACF049.8060306__28668.0406112739$1236070724$gmane$org@cn.fujitsu.com>
References: <20090303013432.11211.18662.stgit@menage.corp.google.com>		<49ACA13B.5050106@cn.fujitsu.com>		<6599ad830903022201s4d2296c7u225e84a77f9f7167@mail.gmail.com>	<6599ad830903030026w2081a72dhf3cac90346b1d806@mail.gmail.com>
	<49ACED6A.9060002@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49ACED6A.9060002-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
List-Id: containers.vger.kernel.org

Li Zefan wrote:
> Paul Menage wrote:
>> On Mon, Mar 2, 2009 at 10:01 PM, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>>> On Mon, Mar 2, 2009 at 7:17 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>>>>> +static int generate_sched_domains(struct cpumask **domains,
>>>>> +                     struct sched_domain_attr **attributes)
>>>>> +{
>>>> Except here should "return 0;", otherwise emit a compile warining.
>>>>
>>> Good catch - the weird thing is that (in my UML build) it doesn't
>>> actually generate that warning. Mysterious.
>>>
>>> I'll resend with the extra return.
>> After looking at the sched domains code it's not clear to me that
>> returning 0 is necessarily the right thing to do -
>> partition_sched_domains() says that 0 is a special case used for
>> destroying existing domains? Would returning 1 and setting up a single
>> dummy domain be better?
>>
> 

partition_sched_domains() says (0, NULL, ...) is used for destroying existing
domains, (1, NULL, ...) will fallback to the single default domain.

But partition_sched_domains() is a stub if !CONFIG_SMP

> Yes, return 1 seems more reasonable. And if we do this, should we also set
> *domains to NULL like this?
> 
> static int generate_sched_domains(struct cpumask **domains,
>                      struct sched_domain_attr **attributes)
> {
> 	*domains = NULL;
> 	return 1;
> }
> 
