From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/3] ftrace: add function tracing to single thread
Date: Wed, 26 Nov 2008 00:48:38 -0800
Message-ID: <m1k5aq50ux.fsf@frodo.ebiederm.org>
References: <alpine.DEB.1.10.0811251800130.26424@gandalf.stny.rr.com>
	<20081125153104.ecdceed4.akpm@linux-foundation.org>
	<alpine.DEB.1.10.0811251909320.26424@gandalf.stny.rr.com>
	<1227660839.12109.52.camel@nimitz>
	<alpine.DEB.1.10.0811251956570.26424@gandalf.stny.rr.com>
	<m1zljndrb6.fsf@frodo.ebiederm.org>
	<alpine.DEB.1.10.0811260000400.26424@gandalf.stny.rr.com>
	<m1abbnc8ff.fsf@frodo.ebiederm.org> <20081126063201.GF9732@elte.hu>
	<m1zljn7yx9.fsf@frodo.ebiederm.org> <20081126071834.GF26036@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753829AbYKZI4U@vger.kernel.org>
In-Reply-To: <20081126071834.GF26036@elte.hu> (Ingo Molnar's message of "Wed,
	26 Nov 2008 08:18:34 +0100")
Sender: linux-kernel-owner@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.osdl.org, fweisbec@gmail.com, LKML <linux-kernel@vger.kernel.org>, srostedt@redhat.com, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>
List-Id: containers.vger.kernel.org

Ingo Molnar <mingo@elte.hu> writes:

> * Eric W. Biederman <ebiederm@xmission.com> wrote:
>
>> Ingo Molnar <mingo@elte.hu> writes:
>> 
>> > i dont see the point of the complexity you are advocating. 99.9% of 
>> > the users run a unique PID space.
>> 
>> I'm not advocating complexity.  I'm advocating using the same APIs as
>> the rest of the kernel, for doing the same functions.
>> 
>> > Tracing is about keeping stuff simple. On containers we could also 
>> > trace the namespace ID (is there an easy ID for the namespace, as an 
>> > easy extension to the very nice PID concept that Unix introduced 
>> > decades ago?) and be done with it.
>> 
>> I don't really care about the pid namespace in this context.
>> 
>> I am just asking that we compare a different field in the task 
>> struct.
>> 
>> I am asking that we don't accumulate new users of an old crufty bug 
>> prone API, for no good reason.
>
> i dont disagree about the change, but i'm curious, what's bug-prone 
> about current->pid? It certainly worked quite well for the first 15 
> years.

Nothing especially serious.

- Just plain general sloppiness that you can get into with using numeric
  pids because you can get away with that you can't get away with if you
  are dealing with a real data structure.

  One of which is classic data type confusion.  Is a pid stored in an
  int a pid_t a short or something else.  Which leads to the difficult
  question if you need to change something how do you find and update
  all of the users.

  Other cases are the horrible to convert cases where we in practice
  leaked pids all over the place, got the locking totally all confused
  simply because we never noticed the races.  Code like that is a
  nightmare to convert to using struct pid *.  Even if struct pid pointers
  are faster to use.

- There is the interesting case that the original unix usage of pids
  and process and session groups with ttys, did not have any problems
  with pid wrap around.  But as pids became more common we added the
  SIGIO support which theoretically at least could allow send a signal
  to the wrong process due to pid wrap around.

  I'm not especially security paranoid but I suspect someone intent
  on such things could likely find a way to send a signal to a process they usually
  could not using pid wrap around.

- As for current->pid itself it is on my hit list for a different reason.

  It is one of the very few left overs from the old pid API, where we
  assume pids numbers are global. Being able to successfully remove it
  would greatly increase the confidence that we haven't missed
  something in the pid namespace implementation.

  The __pgrp and the __session fields in signal_struct are much higher
  on my hit list.  Darn I thought I had already removed them.  But unfortunately
  the final finishing touches on the pid namespace got stalled.

  Currently the preferred patterns are struct pid pointers internal to
  the kernel ( any place we are likely to save them ) and pid_t values
  right on the edge of user space. 

  current->pid is very handy for debugging.  Certainly global pid numbers
  aka pid numbers in the initial pid namespace are the pids we want
  to print with printk, and in any very light weight tracing.  As long
  as they don't creep into APIs where people turn around and use those
  those pids I don't have a problem with privileged users seeing them.


Eric
