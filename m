From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/6][lxc][v3] Link LXC with USERCR
Date: Wed, 31 Mar 2010 15:12:40 -0500
Message-ID: <20100331201240.GA26773@us.ibm.com>
References: <20100331070440.GA21570@us.ibm.com> <4BB3A981.4020709@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4BB3A981.4020709-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Daniel Lezcano (dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
> Sukadev Bhattiprolu wrote:
> >lxc-checkpoint, lxc-restart in the LXC source tree are currently stubs.
> >Following set of patches, when applied to LXC and built with USERCR as
> >described below, enable enable lxc-checkpoint and lxc-restart of some
> >simple containers
> 
> [ ... ]
> 
> >3. Checkpoint/restart a simple LXC container
> >
> >	$ lxc-execute --name foo --rcfile lxc-no-netns.conf -- /bin/sleep 1000
> >
> >	$ lxc-checkpoint --name foo --image /root/lxc-foo.ckpt
> >
> >	$ lxc-stop --name foo
> >
> >	$ lxc-restart --name foo --image /root/lxc-foo.ckpt
> 
> Finally, using ckpt-v20-dev, I succeeded to checkpoint sleep but
> when I restart, I got the error:
> 
> <4534>number of tasks: 2
> <4534>number of vpids: 0
> <4534>total tasks (including ghosts): 2
> <4534>pid 2: inherit sid 0
> <4534>pid 2: creator set to 1
> <4534>====== TASKS
> <4534>	[0] pid 1 ppid 0 sid 0 creator 0
> <4534>	[1] pid 2 ppid 1 sid 0 creator 1
> <4534>............
> <4534>task[0].vidx = -1
> <4534>task[1].vidx = -1
> <4534>new pidns with init
> <4534>forking child vpid 1 flags 0x321
> <4534>task 1 forking with flags 20020011 numpids 1
> <4534>task 1 pid[0]=0
> <4535>====== PIDS ARRAY
> <4535>[0] pid 1 ppid 0 sid 0 pgid 0
> <4535>[1] pid 2 ppid 1 sid 0 pgid 0
> <4535>............
> Error: /dev/ptmx must be a link to /dev/pts/ptmx
> <4534>forked child vpid 4536 (asked 1)
> root task exited status 0
> 
> What can I do to prevent this error ?

test -e /dev/pts/ptmx || (echo "Don't go through with the rest of this" && exit)
rm -f /dev/ptmx
ln -s /dev/pts/ptmx /dev/ptmx
chmod 666 /dev/ptmx

Unfortunately with udev i tend to always have to do this after every
mount (So I do it in the same script that mounts freezer)
