From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] memory.min_usage (seqlock for res_counter)
Date: Wed, 05 Dec 2007 12:32:26 +0300
Message-ID: <4756702A.3070500@openvz.org>
References: <20071204164615.fc871e44.kamezawa.hiroyu@jp.fujitsu.com>	<20071204075854.5850B1D0BFA@siro.lan>	<20071204195436.77fc911b.kamezawa.hiroyu@jp.fujitsu.com>	<475535B2.1020801@openvz.org>	<20071205093455.0f46b456.kamezawa.hiroyu@jp.fujitsu.com>	<47566B76.6020102@openvz.org>
	<20071205182927.41d140a7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071205182927.41d140a7.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, minoura-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

KAMEZAWA Hiroyuki wrote:
> On Wed, 05 Dec 2007 12:12:22 +0300
> Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:
> 
>> Sorry, let me explain it in other words.
>>
>> I think, that protection in reader, that guarantees that it
>> will see the valid result, is not very important - even if
>> we compare usage and limit not atomically nothing serious
>> will happen (in this particular case)
>>
> Maybe there is no serious situation (now).
> But programmers don't assume that the function may not return trustable result.
> And I think it shouldn be trustable AMAP.

Well... OK. Among other possible ways to achieve this goal
seqlocks is the most preferable one from my POV.

Thanks :)

> I'd like to use seq_lock or res_counter_state, here.
> 
> BTW, I'm wondering I should hold off my patches until 2.6.25-rc series if they
> make things complex.

Actually, Andrew wrote that he will pay little attention to
new functionality till 2.6.24 release, so I think that serious
patches should really be held off.

That's why I don't send the kmem controller yet :(

> Thanks,
> -Kame

Thanks,
Pavel
