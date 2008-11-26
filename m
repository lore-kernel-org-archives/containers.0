From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/3] ftrace: add function tracing to single thread
Date: Tue, 25 Nov 2008 23:02:10 -0800
Message-ID: <m1zljn7yx9.fsf@frodo.ebiederm.org>
References: <20081125223456.976670734@goodmis.org>
	<20081125144221.66eb99ad.akpm@linux-foundation.org>
	<alpine.DEB.1.10.0811251800130.26424@gandalf.stny.rr.com>
	<20081125153104.ecdceed4.akpm@linux-foundation.org>
	<alpine.DEB.1.10.0811251909320.26424@gandalf.stny.rr.com>
	<1227660839.12109.52.camel@nimitz>
	<alpine.DEB.1.10.0811251956570.26424@gandalf.stny.rr.com>
	<m1zljndrb6.fsf@frodo.ebiederm.org>
	<alpine.DEB.1.10.0811260000400.26424@gandalf.stny.rr.com>
	<m1abbnc8ff.fsf@frodo.ebiederm.org> <20081126063201.GF9732@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753133AbYKZHGV@vger.kernel.org>
In-Reply-To: <20081126063201.GF9732@elte.hu> (Ingo Molnar's message of "Wed,
	26 Nov 2008 07:32:01 +0100")
Sender: linux-kernel-owner@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.osdl.org, fweisbec@gmail.com, LKML <linux-kernel@vger.kernel.org>, srostedt@redhat.com, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>
List-Id: containers.vger.kernel.org

Ingo Molnar <mingo@elte.hu> writes:

> i dont see the point of the complexity you are advocating. 99.9% of 
> the users run a unique PID space.

I'm not advocating complexity.  I'm advocating using the same APIs as
the rest of the kernel, for doing the same functions.

> Tracing is about keeping stuff simple. On containers we could also 
> trace the namespace ID (is there an easy ID for the namespace, as an 
> easy extension to the very nice PID concept that Unix introduced 
> decades ago?) and be done with it.

I don't really care about the pid namespace in this context.

I am just asking that we compare a different field in the task struct.

I am asking that we don't accumulate new users of an old crufty bug prone
API, for no good reason.

I'm asking that we don't be different for no good reason.

Eric
