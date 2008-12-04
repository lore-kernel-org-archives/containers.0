From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/3] ftrace: use struct pid
Date: Thu, 04 Dec 2008 06:32:55 -0800
Message-ID: <m1abbct3hk.fsf@frodo.ebiederm.org>
References: <20081204052638.425740534@goodmis.org>
	<20081204052735.175697908@goodmis.org>
	<m11vwoumjn.fsf@frodo.ebiederm.org>
	<alpine.DEB.1.10.0812040921410.5240@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757889AbYLDOgi@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.0812040921410.5240@gandalf.stny.rr.com> (Steven
	Rostedt's message of "Thu, 4 Dec 2008 09:23:07 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org

Steven Rostedt <rostedt@goodmis.org> writes:

> On Thu, 4 Dec 2008, Eric W. Biederman wrote:
>
>> Steven Rostedt <rostedt@goodmis.org> writes:
>> 
>> > From: Steven Rostedt <srostedt@redhat.com>
>> >
>> > Impact: clean up
>> >
>> > Eric Biederman suggested using the struct pid for filtering on
>> > pids in the kernel. This patch is based off of a demonstration
>> > of an implementation that Eric sent me in an email.
>> 
>> Please find_get_vpid and pid_vnr.  
>
> I could not find a "find_get_vpid".

Doh.  Grumble Pavel Grumble.

find_get_pid is the right one.

Sorry.  We have a stupid inconsistency in the naming here,
If we were consistent it would be find_get_vpid.

pid_vnr in that case then pid_vnr is definitely what you want
to use when talking to user space.

Eric
