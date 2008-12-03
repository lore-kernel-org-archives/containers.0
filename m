From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 3/3] ftrace: trace single pid for function graph tracer
Date: Wed, 03 Dec 2008 15:36:29 -0800
Message-ID: <m1y6yw25mq.fsf@frodo.ebiederm.org>
References: <20081203203656.776893226@goodmis.org>
	<20081203203829.362295724@goodmis.org>
	<20081203124915.2eb9e7cd.akpm@linux-foundation.org>
	<alpine.DEB.1.10.0812031551360.29045@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756746AbYLCXqk@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.0812031551360.29045@gandalf.stny.rr.com> (Steven
	Rostedt's message of "Wed, 3 Dec 2008 15:52:24 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, mingo@elte.hu, fweisbec@gmail.com, peterz@infradead.org, arjan@infradead.org, dave@linux.vnet.ibm.com, containers@lists.osdl.org, sukadev@linux.vnet.ibm.com, serue@us.ibm.com, srostedt@redhat.com
List-Id: containers.vger.kernel.org

Steven Rostedt <rostedt@goodmis.org> writes:

>> >  # echo $$ > /debugfs/tracing/set_ftrace_pid
>> >  # echo function_graph > /debugfs/tracing/current_tracer
>> > 
>> > Will cause only the current task to be traced. Note, the trace flags are
>> > also inherited by child processes, so the children of the shell
>> > will also be traced.
>> 
>> Where did we end up on the pids-arent-unique issue?  Gave up?
>
> Nah, patch 2 opens the door for a solution. I'm just pawning the work off 
> to the container folks ;-)

The way patch 2 uses pids is just stupid.  It has nothing to do with
pids aren't unique.  You do a full walk of the process list instead
of using the hash table.

It makes me think that task->pid really should go away because with it
there people don't bother to look and see how things normally work.

Eric
