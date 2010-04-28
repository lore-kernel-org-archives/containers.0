From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: lxc and consoles and unix98 ptys (and c/r)
Date: Wed, 28 Apr 2010 10:36:16 -0500
Message-ID: <20100428153616.GA5808@us.ibm.com>
References: <20100427224855.GA7746@us.ibm.com>
 <4BD843F6.9040304@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4BD843F6.9040304-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Daniel Lezcano (dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
> Serge E. Hallyn wrote:
> >Hi Daniel,
> 
> Hi Serge,
> 
> >I know you've thought the whole console situation through
> >a great deal - and I haven't - so plz set me straight as
> >needed.
> >
> >liblxc supports 'lxc.pts', which tells it to mount a fresh
> >/dev/pts.  However, it does this very late in the container
> >startup, and does not appear to support either lxc.tty consoles
> >or the 'main' console being in that ptsns.
> 
> maybe I am misunderstanding but I think you should look at the
> 'lxc_create_console' and the 'setup_console' functions, that will
> show why new pts instance and console / tty are not correlated.

Ok thanks, Daniel, I'll look at lxc/src/lxc some more until I can
be more specific.

> >When I want to checkpoint and restart something which writes
> >to a container in a hand-built container, what I generally do
> >is start sshd and screen -dm in the container, ssh in,
> >screen -r, start my job, detach and logout, then do my
> >freeze/checkpoint/restart, and then i can ssh back in and
> >screen -r.
> >
> >That's obviously less than ideal :)  I'd like to be able to
> >checkpoint lightweight containers by doing
> >
> >	lxc-execute -n serge -- myscript
> >or maybe
> >	lxc-start -d -n serge -- myscript
> >
> >and have the container init's fd 0-2 be /dev/pts/0 in the
> >container's devpts mount.
> >
> >For that to work, lxc-execute would have to mount its new
> >devpts instance, then open /dev/pts/0, and start up a proxy
> >to ferry the console info back and forth.  I thought in the
> >past you'd talked about that, but I can't recall whether you
> >said you wanted to do it, or that you thought it was too
> >heavyweight :)
> 
> lxc-start which runs system container does that if it is specified
> in the configuration.
> 
> >Have you had any such thing in mind?
> 
> lxc-execute is for running application containers and the *stdio*
> are inherited in the container.

I *guess* what I'd like is a way to do an lxc-execute -d, where I
can then re-connect to the console with lxc-console.  So I don't
want a system container (no /sbin/init), I just want the application
to be detached from my console, running in /dev/pts/0 in its own
devpts mount.

> I suppose it may be possible to generalize the console, the ttys and
> the stdio.
> 
> >The related feature of course woudl be for lxc-start with
> >lxc.tty=4 to first mount a new devpts instance, then run
> >getty on /dev/pts/[0-4] and let lxc-console attach to
> >those.
> 
> I am a bit lost, what do you want to do ? Do you plan to make tty,
> console and stdio using the same mechanism and get rid of the actual
> bind mount of <rootfs>/dev/console|tty ?

Well to focus on the specific problem I'm trying to solve: I want to be
able to checkpoint and restart an application container started with
lxc-execute.  In order to be able to do that without doing fancy
plugging of stdin/out/err of the container init at restart, we would
need container init's console to be isolated in the container.  That's
weird of course since we must connect it to the caller's console
somehow.

> Can you elaborate a bit and send a draft-patch to illustrate your idea ?

Will keep thinking for awhile and hopefully come back with something.

thanks,
-serge
