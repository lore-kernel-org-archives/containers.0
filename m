From: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
Subject: Re: [PATCHSET] block: per-queue policy activation, take#2
Date: Fri, 20 Apr 2012 21:08:35 +0200
Message-ID: <4F91B433.2070209__12706.0757870369$1334948933$gmane$org@kernel.dk>
References: <1334347895-6268-1-git-send-email-tj@kernel.org>
	<20120420080943.GG7505@kernel.dk> <4F91503D.2060402@kernel.dk>
	<20120420171742.GC32324@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120420171742.GC32324-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2012-04-20 19:17, Tejun Heo wrote:
> Hello, Jens.
> 
> On Fri, Apr 20, 2012 at 02:02:05PM +0200, Jens Axboe wrote:
>> Tejun, everything merged in cleanly. A boot test didn't not go so well,
>> I'm afraid. It complains about stuck RCU. Even with extra RCU
>> debugging/info turned on, it doesn't give my any extra info.
>>
>> Config is attached. I can try and debug this on Monday, for now I've
>> pulled it out of for-next again.
> 
> Hmmm... it works fine with the same config here (qemu w/ 4 cpus
> configured).  Doesn't stuck RCU usually come from unbalanced RCU
> lock/unlocking?  That should trigger context or RCU warnings before
> anything else, weird.  Anyways, it would be great if you can provide
> more info on how to reproduce the problem.

The machine just sat there. I'll get some more info out of it and run a
bisect too.

-- 
Jens Axboe
