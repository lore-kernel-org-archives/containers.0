From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH 1/2] userns: Better restrictions on when proc and
	sysfs can be mounted
Date: Fri, 15 Nov 2013 00:37:13 -0800
Message-ID: <87d2m2t612.fsf@xmission.com>
References: <878uzmhkqg.fsf@xmission.com> <52749663.2000701@cn.fujitsu.com>
	<527C4D88.10907@cn.fujitsu.com> <87k3gigmgj.fsf@xmission.com>
	<5283299B.8080702@cn.fujitsu.com> <5284AF90.7060506@cn.fujitsu.com>
	<CALCETrXtWtF=JgiwENNzh7UZKnXijHauOQ5ZjHYxYJC-BAU5Aw@mail.gmail.com>
	<528575EC.2030309@cn.fujitsu.com> <87txfexo25.fsf@xmission.com>
	<5285BBE2.7010001@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5285BBE2.7010001-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> (Gao feng's message of "Fri, 15
	Nov 2013 14:14:58 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org

Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:

> Ok,I agree with you that we should make container security by default.
>
> What's your idea that introduces option MS_NOT_A_LOCK just like Andy's
> advisement?

It might be doable but it is unnecessary.

> In libvirt, host creates dev and devpts directories for container,then
> mount devpts, tmpfs on them and create device nodes inside these dirs
> for container. and then in container, these filesystems are moved to
> container's /dev/ /dev/pts directory. We really have no need to lock
> these mounts. they are just created for container.

If the global root creates the namespace and performs all of the mounts
it is unnecessary.

Now I believe you can create those directories for the most part as
non-root in libvirt and gain some interesting applications.

That said if you don't want locked mounts you just just be able to
create a temporary mount namespace as the global root, and do your prep
work.

Then create your unprivileged mount namespace and bind mount the
directories where you want them, and then pivot_root away the bits you
don't want.

There is already more mechanism than I like to deal with the mount
namespace I would really rather not invent/debug/support any more.

Eric
