From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 3/3] ftrace: trace single pid for function graph tracer
Date: Wed, 03 Dec 2008 20:22:28 -0800
Message-ID: <m1hc5kvabf.fsf@frodo.ebiederm.org>
References: <20081203203656.776893226@goodmis.org>
	<20081203203829.362295724@goodmis.org>
	<20081203124915.2eb9e7cd.akpm@linux-foundation.org>
	<alpine.DEB.1.10.0812031551360.29045@gandalf.stny.rr.com>
	<m1y6yw25mq.fsf@frodo.ebiederm.org>
	<alpine.DEB.1.10.0812032125340.28153@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754662AbYLDE0k@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.0812032125340.28153@gandalf.stny.rr.com> (Steven
	Rostedt's message of "Wed, 3 Dec 2008 21:29:10 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, mingo@elte.hu, fweisbec@gmail.com, peterz@infradead.org, arjan@infradead.org, dave@linux.vnet.ibm.com, containers@lists.osdl.org, sukadev@linux.vnet.ibm.com, serue@us.ibm.com, srostedt@redhat.com
List-Id: containers.vger.kernel.org

Steven Rostedt <rostedt@goodmis.org> writes:

> On Wed, 3 Dec 2008, Eric W. Biederman wrote:
>
>> Steven Rostedt <rostedt@goodmis.org> writes:
>> 
>> The way patch 2 uses pids is just stupid.  It has nothing to do with
>> pids aren't unique.  You do a full walk of the process list instead
>> of using the hash table.
>
> The way patch 2 uses the pids is stupid, it was just the easiest way to 
> implement it correctly ;-)  I work with, do it stupid but correct first, 
> then optimize.

Which is a reasonable and very unix approach.  As long as I don't need to
do more than advise about what to do.

>> It makes me think that task->pid really should go away because with it
>> there people don't bother to look and see how things normally work.
>
> This is far from a fast path, and I can easily fix it. The hard work was 
> the rest of the patch not this part. I even did it stupid knowing that I 
> would be rewriting it to handle namespaces. I stated that this needed to 
> be fixed in the patch itself.
>
> One thing I never got an answer for, using the namespace pid path, can I 
> still select the idle task to trace, i.e. pid == 0.

Sorry I didn't see this question.  As I recall we have a special pid that
is not hashed that is used by the idle task.  

So it should be possible but it would need to be a special case.  Although
please note we have one idle task per cpu.

Is the idle task doing anything interesting enough to warrant tracing?
We don't report the idle tasks in proc or in any of our other user space
interfaces.

Eric
