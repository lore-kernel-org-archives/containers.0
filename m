From: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
Subject: Re: [C/R ARM][PATCH 3/3] c/r: ARM implementation of
	checkpoint/restart
Date: Mon, 29 Mar 2010 00:55:11 +0200
Message-ID: <7d08b87d1003281555h1eb255f8ic3bcdec08008d5b2__7025.89323414049$1269816951$gmane$org@mail.gmail.com>
References: <1269219965-23923-1-git-send-email-christofferdall@christofferdall.dk>
	<1269219965-23923-4-git-send-email-christofferdall@christofferdall.dk>
	<20100323211843.GC19572@n2100.arm.linux.org.uk>
	<7d08b87d1003241348g347f092k1142318490e0bdcc@mail.gmail.com>
	<20100326024759.GN19308@shareable.org>
	<20100326030208.GA5815@linux-sh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100326030208.GA5815-M7jkjyW5wf5g9hUCZPvPmw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Mundt <lethal-M7jkjyW5wf5g9hUCZPvPmw@public.gmane.org>
Cc: Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Mar 26, 2010 at 5:02 AM, Paul Mundt <lethal-M7jkjyW5wf5g9hUCZPvPmw@public.gmane.org> wrote:
> On Fri, Mar 26, 2010 at 02:47:59AM +0000, Jamie Lokier wrote:
>>
>> It's possible in principle to run many non-MMU binaries on MMU
>> kernels, but I've never heard of anyone doing it.
>>
> FDPIC supports running the same binaries with or without MMU depending on
> your ABI, it's not really that uncommon, even if it's mostly just used
> for prototyping.
>
I would imagine that the chance that a restart will fail anyway when
restoring an MMU process on a non-MMU kernel. However, as you suggest,
the other way around should be possible. Thanks for clearing that up.

Specifically, do you know the meaning of the end_brk field on the
mm_context_t struct and if I need to checkpoint it on restart for
non-MMU systems (and potentially do something more clever during
restart on an MMU kernel?)
