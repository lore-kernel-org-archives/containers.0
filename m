From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: container sharing /proc/kmsg???
Date: Wed, 13 Jan 2010 11:05:01 -0600
Message-ID: <20100113170501.GA19649@us.ibm.com>
References: <1263334195.4745.250.camel@Mercier.safe.ca>
	<20100113163251.GA18184@us.ibm.com>
	<1263401337.4745.282.camel@Mercier.safe.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1263401337.4745.282.camel-4BUXZ/Ty1v7iqR6jatDSCA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jean-Marc Pigeon <jmp-4qkeo2rQ0gg@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Jean-Marc Pigeon (jmp-4qkeo2rQ0gg@public.gmane.org):
> Hello,
> 
> Hello,
> 
> > > 	Namely, I have in iptables, reject packet logging
> > > 	on the HOST, as soon rsyslog is started on one
> > > 	container, I can't see my reject packet log anymore. 
> > > 
> [...]
> 
> > > 	If I am right, should ALL /proc/kmsg be isolated from
> > > 	each other???
> > > 	
> > > 	How could it be done??
> > 
> > Well, the results of do_syslog() should be containerized.  Kernel
> > messages (oopses for instance) should always go to the initial
> > container.  Shouldn't be hard to do, but the question is what do
> > we tie it to?  User namespace?  Network namespace?  Eric, is this
> > something you've thought about at all?
> > 
> > I'm tempted to say userns makes the most sense - if you start a new
> > userns you likely always want private syslog, whereas with netns and
> > pidns you may not.
> 
> 	I am not a kernel expert, but my guess/answer is
> 	"user namespace".
> 	I mean container /proc return only process number/info
> 	pertaining to container.
> 	Likewise /proc/kmsg should be container own, after all
> 	if iptables rules can be specific to container AND
> 	iptables can log via kmsg, then message must be reported
> 	to container (and duplicated to kmsg host?) and do not
> 	make trouble to host.

/proc/kmsg is just hooked int do_syslog(), the same helper used
by sys_sylog(), so we should be able to address this purely in
kernel/printk.c.

If I get some time tonight I may whip up a proof of concept, though
if anyone else wants to have at, please do.

-serge
