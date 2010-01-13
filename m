From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: container sharing /proc/kmsg???
Date: Wed, 13 Jan 2010 10:32:51 -0600
Message-ID: <20100113163251.GA18184@us.ibm.com>
References: <1263334195.4745.250.camel@Mercier.safe.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1263334195.4745.250.camel-4BUXZ/Ty1v7iqR6jatDSCA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jean-Marc Pigeon <jmp-4qkeo2rQ0gg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Jean-Marc Pigeon (jmp-4qkeo2rQ0gg@public.gmane.org):
> Hello,
> 
> 
> 	I have done a small utility to build containers
> 	using kernel API 'clone' available with kernel-2.6.31.
> 	So far I am able to run more than 30 different
> 	distribution (from rh7.3 -> fc12) on the same
> 	host.
> 	(ftp://ftp.safe.ca/pub/linux/vzgot to know more.)
> 
> 	Everything is working fine...
> 
> 	Except seems HOST and all containers share the
> 	SAME /proc/kmsg, meaning kernel syslog information
> 	are scrambled (useless).
> 
> 	Namely, I have in iptables, reject packet logging
> 	on the HOST, as soon rsyslog is started on one
> 	container, I can't see my reject packet log anymore. 
> 
> 	Also, container have their own iptables with reject
> 	packet logging which are not displayed too.
> 
> 	Am I wrong/forgetting something about the /proc/kmsg
> 	sharing?
> 
> 	If I am right, should ALL /proc/kmsg be isolated from
> 	each other???
> 	
> 	How could it be done??

Well, the results of do_syslog() should be containerized.  Kernel
messages (oopses for instance) should always go to the initial
container.  Shouldn't be hard to do, but the question is what do
we tie it to?  User namespace?  Network namespace?  Eric, is this
something you've thought about at all?

I'm tempted to say userns makes the most sense - if you start a new
userns you likely always want private syslog, whereas with netns and
pidns you may not.

-serge
