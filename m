From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [CFT][PATCH 09/10] sysfs: Create mountpoints with
	sysfs_create_empty_dir
Date: Tue, 11 Aug 2015 12:21:54 -0700
Message-ID: <CALCETrXE=fKa3XkEEo6y2=ZNtsuBfX=kaoyDwiP0C2BwqKJWjw__35928.0177778148$1439320947$gmane$org@mail.gmail.com>
References: <87pp63jcca.fsf@x220.int.ebiederm.org>
	<878ucrhxi9.fsf@x220.int.ebiederm.org>
	<20150811184426.GH23408@mtj.duckdns.org>
	<877fp1hcuj.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <877fp1hcuj.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: Kenton Varda <kenton-AuYgBwuPrUQTaNkGU808tA@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Michael Kerrisk-manpages <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Aug 11, 2015 at 11:57 AM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> writes:
>
>> On Thu, May 14, 2015 at 12:36:30PM -0500, Eric W. Biederman wrote:
>>>
>>> This allows for better documentation in the code and
>>> it allows for a simpler and fully correct version of
>>> fs_fully_visible to be written.
>>>
>>> The mount points converted and their filesystems are:
>>> /sys/hypervisor/s390/       s390_hypfs
>>> /sys/kernel/config/         configfs
>>> /sys/kernel/debug/          debugfs
>>> /sys/firmware/efi/efivars/  efivarfs
>>> /sys/fs/fuse/connections/   fusectl
>>> /sys/fs/pstore/             pstore
>>> /sys/kernel/tracing/        tracefs
>>> /sys/fs/cgroup/             cgroup
>>> /sys/kernel/security/       securityfs
>>> /sys/fs/selinux/            selinuxfs
>>> /sys/fs/smackfs/            smackfs
>>>
>>> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>>> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>>
>> So, this somehow ends up confusing upstart on centos6 based systems
>> making it fail to mount tmpfs on /sys/fs/cgroup.  It also skips sunrpc
>> and other mounts are different too.  No idea why at this point.  Can
>> we please revert this from -stable until we know what's going on?
>
> *Boggle*
>
> The only time this should prevent anything is when in a container when
> you are not global root.  And then only mounting sysfs should be
> affected.

Before:

open("/sys/kernel/debug/asdf", O_WRONLY|O_CREAT|O_NOCTTY|O_NONBLOCK,
0666) = -1 EACCES (Permission denied)


After:

open("/sys/kernel/debug/asdf", O_WRONLY|O_CREAT|O_NOCTTY|O_NONBLOCK,
0666) = -1 ENOENT (No such file or directory)

Something broke.  I don't know whether CentOS cares about that change,
but there could be other odd side effects.

--Andy
