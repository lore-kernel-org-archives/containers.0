From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] memory.min_usage (seqlock for res_counter)
Date: Wed, 05 Dec 2007 12:12:22 +0300
Message-ID: <47566B76.6020102@openvz.org>
References: <20071204164615.fc871e44.kamezawa.hiroyu@jp.fujitsu.com>	<20071204075854.5850B1D0BFA@siro.lan>	<20071204195436.77fc911b.kamezawa.hiroyu@jp.fujitsu.com>	<475535B2.1020801@openvz.org>
	<20071205093455.0f46b456.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071205093455.0f46b456.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, minoura-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

KAMEZAWA Hiroyuki wrote:
> On Tue, 04 Dec 2007 14:10:42 +0300
> Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:
> 
>> KAMEZAWA Hiroyuki wrote:
>>> This is seqlock version res_counter.
>>> Maybe this this will reduce # of spin_lock.
>>>
>>> Pavel-san, How about this ?
>> AFAIS the readlock is used only in the check_under_limit(),
>> but I think, that even if we read usage and limit values
>> in this case non-atomically, this won't result in any 
>> dramatic sequence at all. No?
>>
> Reader can detect *any* changes in res_counter member which happens
> while they access res_counter between seq_begin/seq_retry.
> Memory barrier and "sequence" of seq_lock guarantees this.
> So..there is no dramatical situation.
> (it's used for accesing xtime.)
> 
> I'm sorry if I miss your point.

Sorry, let me explain it in other words.

I think, that protection in reader, that guarantees that it
will see the valid result, is not very important - even if
we compare usage and limit not atomically nothing serious
will happen (in this particular case)

> Thanks,
> -Kame
> 
> 
