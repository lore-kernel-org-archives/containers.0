From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] Introduce ActivePid: in /proc/self/status (v2, was
	Vpid:)
Date: Thu, 16 Jun 2011 18:22:20 +0200
Message-ID: <20110616162220.GB3189@redhat.com>
References: <20110615145527.4016.70157.stgit@bahia.local> <20110615190302.GA16440@redhat.com> <1308223158.8230.66.camel@bahia.local> <4DF9F657.7030605@fr.ibm.com> <20110616130613.GC19312@redhat.com> <4DFA126D.9060102@fr.ibm.com> <m1fwn9by3e.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1fwn9by3e.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Cedric Le Goater <clg@fr.ibm.com>, Greg Kurz <gkurz@fr.ibm.com>, linux-kernel@vger.kernel.org, containers@lists.osdl.org, akpm@linux-foundation.org, xemul@openvz.org
List-Id: containers.vger.kernel.org

On 06/16, Eric W. Biederman wrote:
>
> I remember there were a few very weird things with pids when ptracing
> a process in another pid namespace.

The only problems is pids. PTRACE_EVENT_FORK/etc reports the global pid.
This is fixable. Some tracers look at syscall_get_return_value() register
and get the "local" pid which they do not want.

> It may be that ActivePid is enough
> to allow the tracer to figure out the confusing information it is
> getting.

I don't think so. ActivePid doesn't help unless you know all pids in
this container.

> I would be surprised if using ptrace to send signals is how you
> want to do things.

Yes, yes, this is hack.

Oleg.
