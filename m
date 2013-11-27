From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH 3/3] vfs: Fix a regression in mounting proc
Date: Tue, 26 Nov 2013 16:36:00 -0800
Message-ID: <87haayy93j.fsf@xmission.com>
References: <20131115164123.GN28794@redhat.com>
	<20131116164840.GA4441@mail.hallyn.com>
	<20131117030653.GA7670@mail.hallyn.com>
	<20131118031932.GA17621@mail.hallyn.com>
	<52899D09.5080202@cn.fujitsu.com>
	<20131118140830.GA22075@mail.hallyn.com>
	<20131118180134.GA24156@mail.hallyn.com> <87k3g5gnuv.fsf@xmission.com>
	<20131126181043.GA25492@mail.hallyn.com>
	<87siui1z1g.fsf_-_@xmission.com> <87pppmzoin.fsf_-_@xmission.com>
	<CALCETrVp78EfzY3Oa-LV1Hm8A4Y35apehcxrxdyrzvTb5sp=pA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CALCETrVp78EfzY3Oa-LV1Hm8A4Y35apehcxrxdyrzvTb5sp=pA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Andy Lutomirski's message of "Tue, 26 Nov 2013 16:21:51 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Cc: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> writes:

> On Tue, Nov 26, 2013 at 4:17 PM, Eric W. Biederman
> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>>
>> Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> reported that commit
>> e51db73532955dc5eaba4235e62b74b460709d5b
>> userns: Better restrictions on when proc and sysfs can be mounted
>> caused a regression on mounting a new instance of proc in a mount
>> namespace created with user namespace privileges, when binfmt_misc
>> is mounted on /proc/sys/fs/binfmt_misc.
>>
>> This is an unintended regression caused by the absolutely bogus empty
>> directory check in fs_fully_visible.  The check fs_fully_visible replaced
>> didn't even bother to attempt to verify proc was fully visible and
>> hiding proc files with any kind of mount is rare.  So for now fix
>> the userspace regression by allowing directory with nlink == 1
>> as /proc/sys/fs/binfmt_misc has.
>>
>> I will have a better patch but it is not stable material, or
>> last minute kernel material.  So it will have to wait.
>
> Is the better fix to fix procfs to set nlink == 2?

The better fix should be to drop locks, read the directory
(f_op->iterate?) and ensure it is empty and then take locks again.
nlink is insufficient to check if a directory is empty and a mount is
covering a file with something interesting.

Only under /proc/sys/... do directories have nlink == 1 so the nlink
check continues to provide value for now.

The only real world reasonable cases are mounting over an empty
directory in /proc or /sys or mounting over the filesystem entirely and
the nlink check actually catches the latter because the nlink count is
correct on the root directories.

Eric
