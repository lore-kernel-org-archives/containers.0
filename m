From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 2/2] Notify container-init parent a 'reboot' occured
Date: Fri, 12 Aug 2011 11:29:08 -0500
Message-ID: <20110812162908.GA9304@peqn>
References: <1313094241-3674-1-git-send-email-daniel.lezcano@free.fr>
	<1313094241-3674-3-git-send-email-daniel.lezcano@free.fr>
	<20110811210951.GA17349@peqn> <4E444A04.3070403@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4E444A04.3070403-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
...
> > Doesn't this mean that an unprivileged task in a container can shut
> > down the container?
> 
> Ha ha ! Right, good catch :)
> 
> Yes, rethinking about it, we can do what initially proposed Bruno by
> just preventing to reboot when we are not in the init_pid_ns. Actually, 
> the sys_reboot occurs after the services shutdown and "kill -1 SIGTERM"
> and "kill -1 SIGKILL", and would not make sense to do that in a child
> pid namespace, except if we are in a container where we don't want to
> reboot :)
> 
> So IMO, it is safe to do:
> 
> 	if (!ns_capable(current_pid_ns()->user_ns, CAP_SYS_BOOT))
>  		return -EPERM;
> 	
> 	if (pid_ns != &init_pid_ns)
> 		return pid_namespace_reboot(pid_ns, cmd, buffer);

So I don't know if you want to prepend
http://kernel.ubuntu.com/git?p=serge/linux-syslogns.git;a=commit;h=63556e9a39bcd75ec4a88333425800905013c73e
to your patchset, or just check nsown_capable(CAP_SYS_BOOT) for now,
but as soon as you resend with that I'll happily, nay,
ecstatically ack.

thanks,
-serge
