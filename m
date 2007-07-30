From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/15] kern_siginfo helper
Date: Mon, 30 Jul 2007 10:07:46 +0400
Message-ID: <46AD8032.90005@openvz.org>
References: <46A8B37B.6050108@openvz.org> <46A8B42F.5070605@openvz.org>
	<20070729114154.GE120@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070729114154.GE120-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Oleg Nesterov wrote:
> On 07/26, Pavel Emelyanov wrote:
>> TODO: 	This is more an exploratory patch and modifies only interfaces
>> 	necessary to implement correct signal semantics in pid namespaces.
>> 	
>> 	If the approach is feasible, we could consistently use 'kern_siginfo'
>> 	in other signal interfaces and possibly in 'struct sigqueue'.
>>
>> 	We could modify dequeue_signal() to directly work with 'kern_siginfo'
>> 	and remove dequeue_signal_kern_info().
> 
> Well... I know, it is very easy to blame somebody else's patch, and probably
> my taste is not good...
> 
> But honestly, I personally think this approach is a horror, and any alternative
> is better :)
> 
> I'd rather change dequeue_signal() so that it takes "struct sigqueue *"
> parameter instead of "siginfo_t *", or add a new "int *flags".
> 
> OK, this doesn't work anyway, we should do something different. Perhaps
> just do all checks on sender's side.

Yes. Signal handling in namespaces turned out to be the most complicated
part of the set. I start thinking to drop this part till we have the "core"
in -mm tree. Suka, what do you think?

> It is a bit strange that this patch is 3/15, and the rest bits in 11/15,
> not very convenient for the review.

Well, I thought that a split like
1. patches for kernel to prepare it for the set
2. the set itself
is the best to review. Maybe I was wrong, but how to make this then?
E.g. I have a MS_KERNOUNT patch, but its changes are used *much* later.

> Oleg.
> 
> 

Thanks,
Pavel
