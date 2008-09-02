From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH 0/8][v2]: Enable multiple mounts of devpts
Date: Tue, 02 Sep 2008 03:00:47 -0700
Message-ID: <m1vdxeeuk0.fsf@frodo.ebiederm.org>
References: <20080821022126.GA29449@us.ibm.com> <48ACD6CB.5030706@zytor.com>
	<20080821031028.GB30205@us.ibm.com> <48ACDDC7.3000704@zytor.com>
	<48AD991F.9010906@fr.ibm.com> <48AD9A97.6000807@zytor.com>
	<48AD9DCD.3060306@fr.ibm.com> <m1fxoys1ng.fsf@frodo.ebiederm.org>
	<48ADD7D3.7080400@fr.ibm.com> <48B7BB3C.5080404@fr.ibm.com>
	<20080902030426.GB12277@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080902030426.GB12277-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Mon, 1 Sep 2008 22:04:26 -0500")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, Dave Hansen <dave-gkUM19QKKo4@public.gmane.org>, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:

>>     (3.2) mnt namespace maybe ?
>
> I think the last one is the way to go.
>
> mnt_namespace points to mq_ns.
>
> At clone(CLONE_NEWMNT), the new mnt namespace receives a copy of the
> parent's mq_ns.
>
> If a task does
> 	mount -o newinstance -t mqueue none /dev/mqueue
> then its current->nsproxy->mnt_namespace->mqns is switched
> to point to a new instance of the mq_ns.
>
> mnt_ns->mq_ns has pointers to the sb (and hence root dentry) of the
> devpts fs.
>
> When a task does mq_open(name, flag), then name is in the mqueuefs
> found in current->nsproxy->mnt_namespace->mqns.
>
> But if a task does
>
> 	clone(CLONE_NEWMNT);
> 	mount --move /dev/mqueue /oldmqueue
> 	mount -o newinstance -t mqueue none /dev/mqueue
>
> then that task can find files for the old mqueuefs under
> /oldmqueue, while mq_open() uses /dev/mqueue since that's
> what it finds through its mnt_namespace.

Serge if we can make the lookup a pure mount namespace operation
i.e. a well known path.  Than I don't have any problems with it.
Otherwise it looks like abuse of the mount namespace.

In particular.  The best approximation I have is to change the
kernel to simply lookup "/dev/mqueue" and if not found fallback
to the initial kernel instance.

I'm staring at the code as I really haven't looked at it enough
but it sure looks like we can transform it into a proper filesystem
with just a touch of backwards compatibility logic.
- put the current mq_namespace in the superblock.
- Have open/unlink lookup "/dev/mqueue" to find the filesystem
  if nothing is found fallback to the internal mount otherwise error.
- Possibly put the tunables in a subdirectory? and 
  bind mount that subdirectory on top of /proc/sys/fs/mqueue/

  I'm too thrilled about the tunables but still.

Are there any security holes or other oddness we would encounter
if we did that?

If we can turn the posix mqueue stuff into an honest to goodness
filesystem then we completely avoid nsproxy, and have something
that is much nicer to deal with long term.

Eric
