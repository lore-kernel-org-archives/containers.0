From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 1/2] Adds a read-only "procs" file similar to "tasks" that
	shows only unique tgids
Date: Wed, 15 Jul 2009 01:33:05 -0700
Message-ID: <m1ocrm73cu.fsf__38944.6524241523$1247646910$gmane$org@fess.ebiederm.org>
References: <20090702231814.3969.44308.stgit@menage.mtv.corp.google.com>
	<2f86c2480907021731h13e0bb95q94f06829eded9aa6@mail.gmail.com>
	<20090702175341.fd2e26d5.akpm@linux-foundation.org>
	<6599ad830907021808o6f3bb51eh324e4bf13544d83e@mail.gmail.com>
	<2f86c2480907021817o79fce75yd9785aab682f7bb4@mail.gmail.com>
	<20090702190845.0cafc46a.akpm@linux-foundation.org>
	<6599ad830907022116n7a711c7fs52ff9b400ec8797f@mail.gmail.com>
	<20090702235527.7ddc873c.akpm@linux-foundation.org>
	<6599ad830907030911m6176dc59id3a7d897b03d2bd@mail.gmail.com>
	<20090703095000.cf46ad19.akpm@linux-foundation.org>
	<6599ad830907031054x74d90149y38aae60afa403d58@mail.gmail.com>
	<20090703111016.ceb28541.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090703111016.ceb28541.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> (Andrew
	Morton's message of "Fri\, 3 Jul 2009 11\:10\:16 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, lizf-BthXqXjhjHXBeW8qKU6YJg@public.gmane.org, Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> writes:

> On Fri, 3 Jul 2009 10:54:48 -0700 Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>
>> >__Unfortunately radix-trees are presented as operating on
>> > void* data, so one would need to do some typecasting when storing
>> > BITS_PER_LONG-sized bitfields inside them.
>> 
>> That would mean adding something a bit like the IDA wrapper that
>> converts IDR to deal with bitfields?
>
> I guess so.
>
>> Is the benefit of avoiding a vmalloc() at all costs really worth the
>> additional complexity
>
> Well no.  But nor was it worth the additional complexity the last twenty
> times someone resorted to vmalloc to solve a problem of this nature.  Taking
> a kernel-wide perspective here gives a different answer.
>
> However I don't think a little scoreboarding thing (what's the correct
> term) built around radix-trees would suffice to solve many of those
> past sins.  Whereas a general dynamic array thing would be applicable
> in many cases.

It is even easier.  Just grab the logic from proc_pid_readdir.
It uses rcu locking.
It returns pids in order.
It needs no mallocs to use.

The people who ran benchmarks tell me I actually sped up proc,
when I started traversing the existing bitmap of pids.

It makes the guarantee that for every process that existed for
the length of the operation you will see it's pid.  Processes
that die or were born half way through we don't say anything about
but if they stay around you will get them next time.

I think guaranteeing a truly atomic snapshot is likely to be a
horrible idea requiring all kinds of nasty locking, and smp
scalability issues.  So please walk the list of pids and
just return those that belong to your cgroup.

Compare to the rest of the implementations everyone is balking
at it should be simple.

Eric
