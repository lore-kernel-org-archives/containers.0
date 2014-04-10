From: Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH for v3.14] AUDIT: Allow login in non-init namespaces
Date: Wed, 09 Apr 2014 20:08:40 -0400
Message-ID: <19406418.LIeRWhPu7h@x2>
References: <1396220874.6974.5.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1396220874.6974.5.camel@localhost>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sunday, March 30, 2014 07:07:54 PM Eric Paris wrote:
> It its possible to configure your PAM stack to refuse login if
> audit messages (about the login) were unable to be sent.  This is common
> in many distros and thus normal configuration of many containers. The
> PAM modules determine if audit is enabled/disabled in the kernel based
> on the return value from sending an audit message on the netlink socket.
> If userspace gets back ECONNREFUSED it believes audit is disabled in the
> kernel.  If it gets any other error else it refuses to let the login
> proceed.

This is a requirement. I do not advocate "tricking" user space. If you do, I 
might have to fix the bug you created. What should be done is have some 
discussion about the problem so that everyone involved has some chance to 
discuss the problem.

-Steve

> Just about ever since the introduction of namespaces the kernel audit
> subsystem has returned EPERM if the task sending a message was not in
> the init user or pid namespace.  So many forms of containers have never
> worked if audit was enabled in the kernel.
> 
> BUT if the container was not in net_init then the kernel network code
> would send ECONNREFUSED (instead of the audit code sending EPERM).  Thus
> by pure accident/dumb luck/bug if an admin configured the PAM stack to
> reject all logins that didn't talk to audit, but then ran the login
> untility in the non-init_net namespace, it would work!!  Clearly this
> was a bug, but it is a bug some people expected.
> 
> With the introduction of network namespace support in 3.14-rc1 the two
> bugs stopped cancelling each other out.  Now, containers in the
> non-init_net namespace refused to let users log in (just like PAM was
> configfured!)  Obviously some people were not happy that what used to
> let users log in, now didn't!
> 
> This fix is kinda hacky.  We return ECONNREFUSED for all non-init
> relevant namespaces.  That means that not only will the old broken
> non-init_net setups continue to work, now the broken non-init_pid or
> non-init_user setups will 'work'.  They don't really work, since audit
> isn't logging things.  But it's what most users want.
> 
> In 3.15 we should have patches to support not only the non-init_net
> (3.14) namespace but also the non-init_pid and non-init_user namespace.
> So all will be right in the world.  This just opens the doors wide open
> on 3.14 and hopefully makes users happy, if not the audit system...
> 
> Reported-by: Andre Tomt <andre-59NiGsLHOdY@public.gmane.org>
> Reported-by: Adam Richter <adam_richter2004-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
>  kernel/audit.c | 12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/kernel/audit.c b/kernel/audit.c
> index 3392d3e..95a20f3 100644
> --- a/kernel/audit.c
> +++ b/kernel/audit.c
> @@ -608,9 +608,19 @@ static int audit_netlink_ok(struct sk_buff *skb, u16
> msg_type) int err = 0;
> 
>  	/* Only support the initial namespaces for now. */
> +	/*
> +	 * We return ECONNREFUSED because it tricks userspace into thinking
> +	 * that audit was not configured into the kernel.  Lots of users
> +	 * configure their PAM stack (because that's what the distro does)
> +	 * to reject login if unable to send messages to audit.  If we return
> +	 * ECONNREFUSED the PAM stack thinks the kernel does not have audit
> +	 * configured in and will let login proceed.  If we return EPERM
> +	 * userspace will reject all logins.  This should be removed when we
> +	 * support non init namespaces!!
> +	 */
>  	if ((current_user_ns() != &init_user_ns) ||
>  	    (task_active_pid_ns(current) != &init_pid_ns))
> -		return -EPERM;
> +		return -ECONNREFUSED;
> 
>  	switch (msg_type) {
>  	case AUDIT_LIST:
