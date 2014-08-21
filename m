From: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
Subject: Re: [GIT PULL] namespace updates for v3.17-rc1
Date: Thu, 21 Aug 2014 08:29:59 +0200
Message-ID: <53F591E7.3010509__4144.221955403$1408603017$gmane$org@nod.at>
References: <87fvhav3ic.fsf@x220.int.ebiederm.org>	<CAFLxGvwi-iJRyfwv8v9fcRkiSu2d-az8W55xMPbp_d8wQKmwjg@mail.gmail.com>
	<87vbpm4f4y.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87vbpm4f4y.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: "libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Am 21.08.2014 06:53, schrieb Eric W. Biederman:
> The bugs fixed are security issues, so if we have to break a small
> number of userspace applications we will.  Anything that we can
> reasonably do to avoid regressions will be done.
> 
> Could you please look at my user-namespace.git#for-next branch I have a
> fix for at least one regresion causing issue in there.  I think it may
> fix your issues but I am not fully certain more comments below.

I'll run this on my LXC testbed today.

>>         /*
>>          * We can't immediately set the MS_RDONLY flag when mounting filesystems
>>          * because (in at least some kernel versions) this will propagate back
>>          * to the original mount in the host OS, turning it readonly too. Thus
>>          * we mount the filesystem in read-write mode initially, and then do a
>>          * separate read-only bind mount on top of that.
>>          */
>>         bindOverReadonly = !!(mnt_mflags & MS_RDONLY);
>>
>>         VIR_DEBUG("Mount %s on %s type=%s flags=%x",
>>                   mnt_src, mnt->dst, mnt->type, mnt_mflags & ~MS_RDONLY);
>>         if (mount(mnt_src, mnt->dst, mnt->type, mnt_mflags &
>> ~MS_RDONLY, NULL) < 0) {
>>
>> ^^^^ Here it fails for sysfs because with user namespaces we bind the
>> existing /sys into the container
>> and would have to read out all existing mount flags from the current /sys mount.
>> Otherwise mount() fails with EPERM.
>> On my test system /sys is mounted with
>> "rw,nosuid,nodev,noexec,relatime" and libvirt
>> misses the realtime...
> 
> Not specifying any atime flags to mount should be safe as that asks for
> the default atime flags which for remount I have made the default atime
> flags the existing atime flags.  So I am scratching my head a little on
> this one.

Okay, let me find out why exactly libvirt gets a EPERM here.
Maybe there are more odds hidden.

>>
>>             virReportSystemError(errno,
>>                                  _("Failed to mount %s on %s type %s flags=%x"),
>>                                  mnt_src, mnt->dst, NULLSTR(mnt->type),
>>                                  mnt_mflags & ~MS_RDONLY);
>>             goto cleanup;
>>         }
>>
>>         if (bindOverReadonly &&
>>             mount(mnt_src, mnt->dst, NULL,
>>                   MS_BIND|MS_REMOUNT|MS_RDONLY, NULL) < 0) {
>>
>> ^^^ Here it fails because now we'd have to specify all flags as used
>> for the first
>> mount. For the procfs case MS_NOSUID|MS_NOEXEC|MS_NODEV.
>> See lxcBasicMounts[].
>> In this case the fix is easy, add mnt_mflags to the mount flags.
> 
> That has always been a bug in general because remount has always
> required specifying the complete set of mount flags you want to have.
> 
> That fact that flags such as nosuid are now properly locked so you can
> not change them if you are not the global root user just makes this
> obvious.
> 
> Andy Lutermorski has observed that statvfs will return the mount flags
> making reading them simple.

Thanks for the clarification, I'll create a fix for libvirt.

Thanks,
//richard
