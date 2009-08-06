From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/6] Makes procs file writable to move all threads by tgid
	at once
Date: Thu, 6 Aug 2009 03:42:20 -0700
Message-ID: <6599ad830908060342m1fc8cdd2me25af248a8e0e183__23103.1638723382$1249555380$gmane$org@mail.gmail.com>
References: <2f86c2480908031113y525b6cbdhe418b8a0364c7760@mail.gmail.com>
	<2f86c2480908041214r1f23c1b7q9a25b04e26c92a1a@mail.gmail.com>
	<6599ad830908041228w67bc6f7fh57e28f244e1923b3@mail.gmail.com>
	<20090805102057.GT29252@hawkmoon.kerlabs.com>
	<6599ad830908050911t6f23f810i65fe8fe17f3ee698@mail.gmail.com>
	<20090805164218.GB26446@hawkmoon.kerlabs.com>
	<2f86c2480908051701s57120404q475edbedb58cdca1@mail.gmail.com>
	<20090806095854.GD26446@hawkmoon.kerlabs.com>
	<6599ad830908060328y21a008c1pc5ed5c27e0ec905d@mail.gmail.com>
	<1249554853.32113.145.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1249554853.32113.145.camel@twins>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Cc: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Aug 6, 2009 at 3:34 AM, Peter Zijlstra<a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org> wrote:
> On Thu, 2009-08-06 at 03:28 -0700, Paul Menage wrote:
>
>> OK, well if lockdep can't currently handle the "writer takes a lock on
>> every thread" model,
>
> I haven't read what this is about, but simply looking at that sentence
> makes me want to hit someone with a cluebat. Have you any idea how
> expensive that is?

For lockdep to track that many locks, or just the concept of taking
that many locks generally?

The basic idea is that in order to implement a "procs" file in cgroups
that can migrate all threads in a process atomically, we need to
synchronize with concurrent clone() calls. But since thread clones are
likely to occur far more often than "procs" writes, and we wanted to
avoid introducing overhead into the clone path, one approach was to
give each thread a fork mutex, which it could take around the relevant
parts of the fork/clone operation, and have the "procs" writer deal
with obtaining the fork mutex for every thread in the process being
moved, so pushing the overhead on to the "procs" writer.

I don't think it's a deficiency of lockdep that it would have trouble
dealing with this - in fact, my original plan was that we'd just have
to live with the fact that anyone doing a "procs" move on a massive
process would have to live with lockdep printing an overflow warning.
But given that AFAICS we can eliminate the overhead associated with a
single lock by piggy-backing on the cache line containing
sighand->count, hopefully this won't be an issue any more.

Paul
