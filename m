From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 3/3] ftrace: trace single pid for function graph tracer
Date: Wed, 3 Dec 2008 21:29:10 -0500 (EST)
Message-ID: <alpine.DEB.1.10.0812032125340.28153@gandalf.stny.rr.com>
References: <20081203203656.776893226@goodmis.org> <20081203203829.362295724@goodmis.org> <20081203124915.2eb9e7cd.akpm@linux-foundation.org> <alpine.DEB.1.10.0812031551360.29045@gandalf.stny.rr.com> <m1y6yw25mq.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757937AbYLDC30@vger.kernel.org>
In-Reply-To: <m1y6yw25mq.fsf@frodo.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, mingo@elte.hu, fweisbec@gmail.com, peterz@infradead.org, arjan@infradead.org, dave@linux.vnet.ibm.com, containers@lists.osdl.org, sukadev@linux.vnet.ibm.com, serue@us.ibm.com, srostedt@redhat.com
List-Id: containers.vger.kernel.org


On Wed, 3 Dec 2008, Eric W. Biederman wrote:

> Steven Rostedt <rostedt@goodmis.org> writes:
> 
> The way patch 2 uses pids is just stupid.  It has nothing to do with
> pids aren't unique.  You do a full walk of the process list instead
> of using the hash table.

The way patch 2 uses the pids is stupid, it was just the easiest way to 
implement it correctly ;-)  I work with, do it stupid but correct first, 
then optimize.

> 
> It makes me think that task->pid really should go away because with it
> there people don't bother to look and see how things normally work.

This is far from a fast path, and I can easily fix it. The hard work was 
the rest of the patch not this part. I even did it stupid knowing that I 
would be rewriting it to handle namespaces. I stated that this needed to 
be fixed in the patch itself.

One thing I never got an answer for, using the namespace pid path, can I 
still select the idle task to trace, i.e. pid == 0.

-- Steve
