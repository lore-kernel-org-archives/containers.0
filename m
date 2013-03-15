From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 0/4] fix depvpts in user namespaces
Date: Fri, 15 Mar 2013 14:02:29 -0700
Message-ID: <87txoce5qy.fsf__19813.1492281847$1363381392$gmane$org@xmission.com>
References: <1363338823-25292-1-git-send-email-glommer@parallels.com>
	<87boalt0vi.fsf@xmission.com> <20130315140040.GB3782@sergelap>
	<5143333E.1040100@parallels.com> <20130315152133.GB24305@sergelap>
	<51433DBE.9020109@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <51433DBE.9020109-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> (Glauber Costa's message of
	"Fri, 15 Mar 2013 19:26:54 +0400")
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:

> On 03/15/2013 07:21 PM, Serge Hallyn wrote:
>> Quoting Glauber Costa (glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
>>> On 03/15/2013 06:00 PM, Serge Hallyn wrote:
>>>> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>>>>> Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:
>>>>>

>> Well shoot, I can't find it right now.  Not even in Eric's git tree.
>> IIRC upon lookup of /dev/pts it tried to find $rootfs/dev/pts/ptmx
>> and open that instead.
>>
> Which gives a very good explanation about why haven't I seen it =)
> Eric ?

It is definitely in the development branches of my git tree.  I have
half a dozen patches that touch devpts.  I believe the latest dev branch
I have published is userns-always-map-user-v110.  And the code is in
there.

They have not reached the top of my queue in importance at this time,
and last time I was testing them there was a subtle race in something.
I expect it was just a change in pty layer that I haven't followed
closely enough.

> What it a /dev/ptmx already exist? will it use it? That would be bad,
> since that /dev/ptmx could be a host-side one. I actually believe
> linking to $rootfs/dev/pts/ptmx is more robust than my solution against
> remounts. So provided it can guarantee that the ptmx is not ever the
> root ptmx, I would ack that.

For those playing with udev, especially older udev where udev is still
udev and creates devices you can use the following udev rule to create
the pts/ptmx symlink.

KERNEL=="ptmx" NAME:="pts/ptmx" SYMLINK="ptmx"

Before we do anything clever in the kernel it is definitely worth seeing
how far we can take that little udev rule.

I have heard of no container that runs a distro's initrd, or uses the
distro's code to mount root.  So containers even for old distro's can
and do tweak the distro's a little.   It is worth keeping the tweaks
small but udev and their kin are an important bit of that.

As much as I hate the notion I suspect for most of device management
what we want is to act like devtmpfs, and run all of the device node
creation etc outside of the container (possibly even with bind mounts).

Acting like devtmpfs should be something that is possible with no kernel
changes.   Whereas allowing unprivileged processes to create device
nodes probably has issues I haven't thought of yet.

Eric
