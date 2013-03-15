From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 0/4] fix depvpts in user namespaces
Date: Fri, 15 Mar 2013 03:26:25 -0700
Message-ID: <87boalt0vi.fsf@xmission.com>
References: <1363338823-25292-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1363338823-25292-1-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
	(Glauber Costa's message of "Fri, 15 Mar 2013 13:13:39 +0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:

> Hi,
>
> devpts mounts in user namespaces is queued for 3.9. However, while playing
> with it I found it to be less than ideal. Although it could possibly work
> with custom software that can be made to point to /dev/pts/ptmx, a few things
> prevent it from working correctly for people that, like us, are booting full
> distributions.

Full distributions that have not been modified to be minimally container
aware.

> In those scenarios, things like udev will kick in, maybe remount /dev undoing
> any setup we might have done, and then software like sshd or anything else
> calling openpty will search for /dev/ptmx, not /dev/pts/ptmx.

I believe udev stopped running in containers a year or so ago.

> One of the problems that I am addressing in here is that we are disallowing
> mknod in usernamespaces. Although I understand the motivation for that, I
> believe that to be too restrictive, specially because we already control access
> to the files separately. There should be no harm in mknod'ing something per se,
> if manipulating it is forbidden.

mknod in userspace needs to be a separate patchset.  There is no need to
solve mknod in userspace to solve devpts.


> Last, /dev/ptmx will still always be the global ptmx device. We need to somehow
> link it to our namespaces'. My proposal is to multiplex it and return the
> correct "root ptmx" depending on which userns is reading that device.

Doable.  I still strongly prefer my version of having /dev/ptmx act like
a link to /dev/pts/ptmx.  Letting the mount namespace control it.

In testing that works, and it allows a lot of devpts complexity to just
go away.  For older versions of udev you can even configure them with a
rule to make /dev/ptmx a symlink to /dev/pts/ptmx.  Newer versions of
udev completely gave up on creating devices and can longer be configured
to do anything useful in this regard.

So we might even be able to just get away with a bit of udev and
devtmpfs configuration.  And treat devpts as if newinstance is always
specified.  Certainly that has worked in my testing so far.

Eric
