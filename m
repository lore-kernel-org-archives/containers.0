From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: lxc and consoles and unix98 ptys (and c/r)
Date: Tue, 27 Apr 2010 17:48:55 -0500
Message-ID: <20100427224855.GA7746@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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

Hi Daniel,

I know you've thought the whole console situation through
a great deal - and I haven't - so plz set me straight as
needed.

liblxc supports 'lxc.pts', which tells it to mount a fresh
/dev/pts.  However, it does this very late in the container
startup, and does not appear to support either lxc.tty consoles
or the 'main' console being in that ptsns.

When I want to checkpoint and restart something which writes
to a container in a hand-built container, what I generally do
is start sshd and screen -dm in the container, ssh in,
screen -r, start my job, detach and logout, then do my
freeze/checkpoint/restart, and then i can ssh back in and
screen -r.

That's obviously less than ideal :)  I'd like to be able to
checkpoint lightweight containers by doing

	lxc-execute -n serge -- myscript
or maybe
	lxc-start -d -n serge -- myscript

and have the container init's fd 0-2 be /dev/pts/0 in the
container's devpts mount.

For that to work, lxc-execute would have to mount its new
devpts instance, then open /dev/pts/0, and start up a proxy
to ferry the console info back and forth.  I thought in the
past you'd talked about that, but I can't recall whether you
said you wanted to do it, or that you thought it was too
heavyweight :)

Have you had any such thing in mind?

The related feature of course woudl be for lxc-start with
lxc.tty=4 to first mount a new devpts instance, then run
getty on /dev/pts/[0-4] and let lxc-console attach to
those.

thanks,
-serge
