From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/3] ftrace: add function tracing to single thread
Date: Tue, 25 Nov 2008 22:23:16 -0800
Message-ID: <m1abbnc8ff.fsf@frodo.ebiederm.org>
References: <20081125223421.795046329@goodmis.org>
	<20081125223456.976670734@goodmis.org>
	<20081125144221.66eb99ad.akpm@linux-foundation.org>
	<alpine.DEB.1.10.0811251800130.26424@gandalf.stny.rr.com>
	<20081125153104.ecdceed4.akpm@linux-foundation.org>
	<alpine.DEB.1.10.0811251909320.26424@gandalf.stny.rr.com>
	<1227660839.12109.52.camel@nimitz>
	<alpine.DEB.1.10.0811251956570.26424@gandalf.stny.rr.com>
	<m1zljndrb6.fsf@frodo.ebiederm.org>
	<alpine.DEB.1.10.0811260000400.26424@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752789AbYKZG0W@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.0811260000400.26424@gandalf.stny.rr.com> (Steven
	Rostedt's message of "Wed, 26 Nov 2008 00:01:08 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.osdl.org, fweisbec@gmail.com, Ingo Molnar <mingo@elte.hu>, LKML <linux-kernel@vger.kernel.org>, srostedt@redhat.com, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>
List-Id: containers.vger.kernel.org

Steven Rostedt <rostedt@goodmis.org> writes:

> On Tue, 25 Nov 2008, Eric W. Biederman wrote:
>
>> 
>> 
>
> I'm speechless too.

I'm a bit tired so probably am pushing to hard.

At the same time I don't see a single reason not to use
struct pid for what it was designed for.  Identifying tasks.
pid_t's really only belong at the border.

I can see in the tracer when grabbing numbers you might
not be able to follow pointers.  For that I see justification
for using task->pid.  For the comparison I just don't see it.

Eric
