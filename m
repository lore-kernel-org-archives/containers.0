From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 2/3] ftrace: use struct pid
Date: Thu, 4 Dec 2008 09:23:07 -0500 (EST)
Message-ID: <alpine.DEB.1.10.0812040921410.5240@gandalf.stny.rr.com>
References: <20081204052638.425740534@goodmis.org> <20081204052735.175697908@goodmis.org> <m11vwoumjn.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757807AbYLDOXW@vger.kernel.org>
In-Reply-To: <m11vwoumjn.fsf@frodo.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org


On Thu, 4 Dec 2008, Eric W. Biederman wrote:

> Steven Rostedt <rostedt@goodmis.org> writes:
> 
> > From: Steven Rostedt <srostedt@redhat.com>
> >
> > Impact: clean up
> >
> > Eric Biederman suggested using the struct pid for filtering on
> > pids in the kernel. This patch is based off of a demonstration
> > of an implementation that Eric sent me in an email.
> 
> Please find_get_vpid and pid_vnr.  

I could not find a "find_get_vpid".

-- Steve
