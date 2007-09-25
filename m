From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] allow "unlimited" limit value.
Date: Tue, 25 Sep 2007 13:40:52 -0700
Message-ID: <6599ad830709251340t6e002dcbh6d7bcc6e6405739@mail.gmail.com>
References: <20070925193900.1af6d871.kamezawa.hiroyu@jp.fujitsu.com>
	<20070926003056.7df087a0.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.0.9999.0709251205390.19001@chino.kir.corp.google.com>
	<46F95FD7.3010204@linux.vnet.ibm.com>
	<6599ad830709251235u33dde9c8pfd56ed3d9d4fbe4b@mail.gmail.com>
	<alpine.DEB.0.9999.0709251236040.23337@chino.kir.corp.google.com>
	<6599ad830709251300sea126bam5a4b6f7c6bd366e0@mail.gmail.com>
	<alpine.DEB.0.9999.0709251304030.28350@chino.kir.corp.google.com>
	<6599ad830709251312p7cdfae3byac2048fdc64ea5ca@mail.gmail.com>
	<alpine.DEB.0.9999.0709251325540.29575@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <alpine.DEB.0.9999.0709251325540.29575-X6Q0R45D7oAcqpCFd4KODRPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
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
> If you're fine with rounding up to the nearest page, then what's the point
> of exposing it as a number of bytes??  You'll never get a granularity
> finer than a kilobyte.

API != implementation.

>
> So by expressing it in terms of bytes instead of kilobytes, you're just
> making the largest amount of memory allowed via this interface smaller
> that is should have to be.

Yes, that's true. With a 64-bit count in bytes, we can only limit
people to 16 exabytes of memory. We're going to bump up against that
limit in no time.

>
> > > That fundamental unit being charged are pages,
> >
> > No, that just happens to be the implementation mechanism in this controller.
> >
>
> And this controller owns the memory.limit file so it can express its
> memory limits in whatever unit it wants.
>

Right, but it would be nice to have different memory controllers be
API-compatible with one another. Bytes is the lowest common
denominator.

Paul
