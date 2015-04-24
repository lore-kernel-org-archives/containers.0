From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH V6 00/10] namespaces: log namespaces per task
Date: Fri, 24 Apr 2015 14:36:16 -0500
Message-ID: <87bnid9v4f.fsf__24369.7844249711$1429904462$gmane$org@x220.int.ebiederm.org>
References: <cover.1429252659.git.rgb@redhat.com>
	<87vbgqw163.fsf@x220.int.ebiederm.org>
	<20150423030751.GA6712@madcap2.tricolour.ca>
	<20150423204429.GA25794@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150423204429.GA25794-bcJWsdo4jJjeVoXN4CMphl7TgLCtbB0G@public.gmane.org> (Richard Guy
	Briggs's message of "Thu, 23 Apr 2015 16:44:29 -0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> On 15/04/22, Richard Guy Briggs wrote:
>> On 15/04/20, Eric W. Biederman wrote:
>> > Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
>> > 
>> > > The purpose is to track namespace instances in use by logged processes from the
>> > > perspective of init_*_ns by logging the namespace IDs (device ID and namespace
>> > > inode - offset).
>> > 
>> > In broad strokes the user interface appears correct.
>> > 
>> > Things that I see that concern me:
>> > 
>> > - After Als most recent changes these inodes no longer live in the proc
>> >   superblock so the device number reported in these patches is
>> >   incorrect.
>> 
>> Ok, found the patchset you're talking about:
>> 	3d3d35b kill proc_ns completely
>> 	e149ed2 take the targets of /proc/*/ns/* symlinks to separate fs
>> 	f77c801 bury struct proc_ns in fs/proc
>> 	33c4294 copy address of proc_ns_ops into ns_common
>> 	6344c43 new helpers: ns_alloc_inum/ns_free_inum
>> 	6496452 make proc_ns_operations work with struct ns_common * instead of void *
>> 	3c04118 switch the rest of proc_ns_operations to working with &...->ns
>> 	ff24870 netns: switch ->get()/->put()/->install()/->inum() to working with &net->ns
>> 	58be2825 make mntns ->get()/->put()/->install()/->inum() work with &mnt_ns->ns
>> 	435d5f4 common object embedded into various struct ....ns
>> 
>> Ok, I've got some minor jigging to do to get inum too...
>
> Do I even need to report the device number anymore since I am concluding
> s_dev is never set (or always zero) in the nsfs filesystem by
> mount_pseudo() and isn't even mountable? 

We still need the dev. We do have a device number get_anon_bdev fills it in.

> In fact, I never needed to
> report the device since proc ida/idr and inodes are kernel-global and
> namespace-oblivious.

This is the bit I really want to keep to be forward looking.  If we
every need to preserve the inode numbers across a migration we could
have different super blocks with different inode numbers for the same
namespace.

>> > - I am nervous about audit logs being flooded with users creating lots
>> >   of namespaces.  But that is more your lookout than mine.
>> 
>> There was a thought to create a filter to en/disable this logging...
>> It is an auxiliary record to syscalls, so they can be ignored by userspace tools.
>> 
>> > - unshare is not logging when it creates new namespaces.
>> 
>> They are all covered:
>> sys_unshare > unshare_userns > create_user_ns
>> sys_unshare > unshare_nsproxy_namespaces > create_new_namespaces > copy_mnt_ns
>> sys_unshare > unshare_nsproxy_namespaces > create_new_namespaces > copy_utsname > clone_uts_ns
>> sys_unshare > unshare_nsproxy_namespaces > create_new_namespaces > copy_ipcs > get_ipc_ns
>> sys_unshare > unshare_nsproxy_namespaces > create_new_namespaces > copy_pid_ns > create_pid_namespace
>> sys_unshare > unshare_nsproxy_namespaces > create_new_namespaces > copy_net_ns

Then why the special change to fork?  That was not reflected on
the unshare path as far as I could see.

>> > As small numbers are nice and these inodes all live in their own
>> > superblock now we should be able to remove the games with
>> > PROC_DYNAMIC_FIRST and just use small numbers for these inodes
>> > everywhere.
>> 
>> That is compelling if I can untangle the proc inode allocation code from the
>> ida/idr.  Should be as easy as defining a new ns_alloc_inum (and ns_free_inum)
>> to use instead of proc_alloc_inum with its own ns_inum_ida and ns_inum_lock,
>> then defining a NS_DYNAMIC_FIRST and defining NS_{IPC,UTS,USER,PID}_INIT_INO in
>> the place of the existing PROC_*_INIT_INO.

Something like that.  Just a new ida/idr allocator specific to that
superblock.

Yeah.  It is somewhere on my todo, but I have been prioritizing getting
the bugs that look potentially expoloitable fixed in the mount
namespace.  Al made things nice for one case but left a mess for a bunch
of others.

>> > I honestly don't know how much we are going to care about namespace ids
>> > during migration.  So far this is not a problem that has come up.
>> 
>> Not for CRIU, but it will be an issue for a container auditor that aggregates
>> information from individually auditted hosts.
>> 
>> > I don't think migration becomes a practical concern (other than
>> > interface wise) until achieve a non-init namespace auditd.  The easy way
>> > to handle migration would be to log a setns of every process from their
>> > old namespaces to their new namespaces.  As you appear to have a setns
>> > event defined.
>> 
>> Again, this would be taken care of by a layer above that is container-aware
>> across multiple hosts.


>> > How to handle the more general case beyond audit remains unclear.  I
>> > think it will be a little while yet before we start dealing with
>> > migrating applications that care.  When we do we will either need to
>> > generate some kind of hot-plug event that userspace can respond to and
>> > discover all of the appropriate file-system nodes have changed, or we
>> > will need to build a mechanism in the kernel to preserve these numbers.
>> 
>> I don't expect to need to preserve these numbers.  The higher layer application
>> will be able to do that translation.

We need to be very aware of what is happening.

The situation I am concerned about looks something like.

Program A:
  fd1 = open(/proc/self/ns/net);
  fstat(fd1, &stat1)

  ... later ...

  fd2 = open(/var/run/netns/johnny);
  fstat(fd2, &stat2);

  if ((stat1.st_dev == stat2.st_dev) &&
      (stat1.st_ino == stat2.st_ino)) {
	/* Same netns do something... */
  }


What happens when we migrate Program A with it's cached stat data of
of a network namespace file?

This requires either a hotplug event that Program A listens to or that
the inode number and device number are preserved across migration.

Exactly what we do depends on where we are when it comes up.  But this
is not something some layer about the program can abstract it all out so
we don't need to worry about it.

Eric
