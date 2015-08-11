From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [CFT][PATCH 09/10] sysfs: Create mountpoints with
	sysfs_create_empty_dir
Date: Tue, 11 Aug 2015 13:57:56 -0500
Message-ID: <877fp1hcuj.fsf__35343.030098784$1439319905$gmane$org@x220.int.ebiederm.org>
References: <87pp63jcca.fsf@x220.int.ebiederm.org>
	<878ucrhxi9.fsf@x220.int.ebiederm.org>
	<20150811184426.GH23408@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150811184426.GH23408-qYNAdHglDFBN0TnZuCh8vA@public.gmane.org> (Tejun Heo's message of
	"Tue, 11 Aug 2015 14:44:26 -0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Kenton Varda <kenton-AuYgBwuPrUQTaNkGU808tA@public.gmane.org>, Michael Kerrisk-manpages <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> writes:

> On Thu, May 14, 2015 at 12:36:30PM -0500, Eric W. Biederman wrote:
>> 
>> This allows for better documentation in the code and
>> it allows for a simpler and fully correct version of
>> fs_fully_visible to be written.
>> 
>> The mount points converted and their filesystems are:
>> /sys/hypervisor/s390/       s390_hypfs
>> /sys/kernel/config/         configfs
>> /sys/kernel/debug/          debugfs
>> /sys/firmware/efi/efivars/  efivarfs
>> /sys/fs/fuse/connections/   fusectl
>> /sys/fs/pstore/             pstore
>> /sys/kernel/tracing/        tracefs
>> /sys/fs/cgroup/             cgroup
>> /sys/kernel/security/       securityfs
>> /sys/fs/selinux/            selinuxfs
>> /sys/fs/smackfs/            smackfs
>> 
>> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>
> So, this somehow ends up confusing upstart on centos6 based systems
> making it fail to mount tmpfs on /sys/fs/cgroup.  It also skips sunrpc
> and other mounts are different too.  No idea why at this point.  Can
> we please revert this from -stable until we know what's going on?

*Boggle*

The only time this should prevent anything is when in a container when
you are not global root.  And then only mounting sysfs should be
affected.

The only difference in executed code really should be setting an extra
flag on the kernfs, inode.  The kernfs changes will also refuse to add
entries to these directories (but these directories are empty).

If this is causing problems I don't have a problem with a revert but
reverts take a minute, and this seems to be the first report of this
kind.  Can we take a minute and attempt to get a coherent explanation.

From what little information you given above it sounds like something
shifted and when you rebuilt the kernel and now a memory stomp is
hitting something else.  It should be a matter of moments to debug this
issue (once a test environment is setup), and see what is wrong and then
we can act intelligently.  Tracing a single system call is not difficult.

If there really is some weird issue I want to know what it is.

Eric
