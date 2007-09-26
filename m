From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] allow "unlimited" limit value.
Date: Tue, 25 Sep 2007 17:06:21 -0700
Message-ID: <6599ad830709251706y5ba08288x9471289ff408f101@mail.gmail.com>
References: <20070925193900.1af6d871.kamezawa.hiroyu@jp.fujitsu.com>
	<46F95FD7.3010204@linux.vnet.ibm.com>
	<6599ad830709251235u33dde9c8pfd56ed3d9d4fbe4b@mail.gmail.com>
	<alpine.DEB.0.9999.0709251236040.23337@chino.kir.corp.google.com>
	<6599ad830709251300sea126bam5a4b6f7c6bd366e0@mail.gmail.com>
	<alpine.DEB.0.9999.0709251304030.28350@chino.kir.corp.google.com>
	<6599ad830709251312p7cdfae3byac2048fdc64ea5ca@mail.gmail.com>
	<alpine.DEB.0.9999.0709251325540.29575@chino.kir.corp.google.com>
	<6599ad830709251340t6e002dcbh6d7bcc6e6405739@mail.gmail.com>
	<alpine.DEB.0.9999.0709251346550.30668@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <alpine.DEB.0.9999.0709251346550.30668-X6Q0R45D7oAcqpCFd4KODRPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On 9/25/07, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>
> Having the limit expressed and configurable in bytes suggests that it can
> be defined on that granularity which is obviously wrong.

One of the other options suggested was that you can write a value in
bytes, and the value you can read back from there will reflect the
real limit, with any associated granularity/rounding.

>
> > > So by expressing it in terms of bytes instead of kilobytes, you're just
> > > making the largest amount of memory allowed via this interface smaller
> > > that is should have to be.
> >
> > Yes, that's true. With a 64-bit count in bytes, we can only limit
> > people to 16 exabytes of memory. We're going to bump up against that
> > limit in no time.
> >
>
> So, by your logic, it would be fine to express it in bits too.

I don't think it would be much of a scalability limit to express it in
bits, no. Of course, it would be a bit silly. Bytes are the natural
counting units for memory - e.g. they're the units you get back when
you call sizeof(), or you pass to malloc().

>
> Please cite examples of other memory controllers that you can imagine
> would actually support (not expose to userspace, but support) memory
> limits in terms of anything smaller than kilobytes

Pavel's kernel memory controller, posted to this list this morning,
appears to charge for each object based on its size in bytes.

I could also imagine that a filesystem that packs short files or tails
into partial pages could charge based on those partial pages, although
I don't know of any such controller.

Paul
