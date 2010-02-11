From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: iptables in container, wrong log destination, need pointer
Date: Thu, 11 Feb 2010 11:51:10 -0600
Message-ID: <20100211175110.GG6884@us.ibm.com>
References: <1265898746.19130.119.camel@Mercier.safe.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1265898746.19130.119.camel-4BUXZ/Ty1v7iqR6jatDSCA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Jean-Marc Pigeon (jmp-4qkeo2rQ0gg@public.gmane.org):
> Hello,
> 
> 
> 	I have containerized syslog, such each container has its
> 	own syslog.
> 
> 	Container can have their own set of iptables rules.
> 	
> 	I was expecting CONT: iptables log report to be
> 	send to the CONT: syslog, which is not the case,
> 	they are rather sent to HOST: syslog.
> 
> 	This means to me, iptables rules are containerized,
> 	but the execution is NOT (CONT: rules are checked
> 	within the HOST: context, not the CONT: context).
> 
> 	Could somebody give me hint where I should look
> 	in the code, to have a better understanding about
> 	what is happening?

Again, printk can be called from any context, so you can't
rely on 'current'.  But you are relying on current in
emit_log_char() to get the syslog_ns.  That is why you're
getting that.

You're going to have to keep a separate container_printk
(nsprintk) which is called with a syslog_ns.  Then in
functions where you know you can determine the syslog_ns,
you can call that fn instead of printk and pass the ns.

Note that since iptables printks are happening out of
context, this means yet another problem: you'll need to
have a way to get the syslog_ns from the netns, which
I suspect is the only thing can track at that point.

-serge
