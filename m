From: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
Subject: Re: Interaction user namespace, /proc/1 ownership & cap_set
Date: Mon, 01 Jul 2013 18:24:12 +0200
Message-ID: <51D1AD2C.1070505@nod.at>
References: <20130701161625.GQ15954@redhat.com>
	<20130701161946.GR15954@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130701161946.GR15954-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Am 01.07.2013 18:19, schrieb Daniel P. Berrange:
> On Mon, Jul 01, 2013 at 05:16:25PM +0100, Daniel P. Berrange wrote:
>> I'm struggling debugging a strange problem with interaction between user
>> namespaces, cap_set and ownership of files in /proc/1/
>>
>> I'm using a modified version (attached to this mail) of the demo program
>> userns_child_exec.c linked on https://lwn.net/Articles/532593/
>>
>>   $ gcc -lcap -Wall -o userns_child_exec userns_child_exec.c 
>>
>> First normal execution appears to work just fine (as root):
>>
>>   $ ./userns_child_exec -p -m -U -M '0 1000 1' -G '0 1000 1' bash
>>   Launching child init
>>   # umount /proc/sys/fs/binfmt_misc
>>   # umount /proc/sys/fs/binfmt_misc
>>   # umount /proc/fs/nfsd
>>   # umount /proc
>>   # mount -t proc proc /proc/
>>   # ls -al /proc/1/environ 
>>   -r--------. 1 root root 0 Jul  1 17:04 /proc/1/environ
>>
>>
>> My modification adds support for a '-c' arg to call the program to use
>> cap_set() from libcap.so in order to remove the CAP_SYS_MODULE capability.
>>
>> If I run the program with the '-c' arg present, then the files in
>> the /proc/1/ directory all end up owned by nfsnobody.nfsbody
>>
>>   $ ./userns_child_exec -c -p -m -U -M '0 1000 1' -G '0 1000 1' bash
>>   Launching child init
>>   # umount /proc/sys/fs/binfmt_misc
>>   # umount /proc/sys/fs/binfmt_misc
>>   # umount /proc/fs/nfsd
>>   # umount /proc
>>   # mount -t proc proc /proc/
>>   # ls -al /proc/1/environ 
>>   -r--------. 1 nfsnobody nfsnobody 0 Jul  1 17:01 /proc/1/environ
>>
>> Why on earth would calling 'cap_set()' to drop a capability cause
>> the user/group ownership of files in /proc/1/ to change ?
>>
>> Any child processes launched from this point get correct ownership
>> on their /proc/NNN files - only /proc/1/ seems to be affected.
>>
>> Via strace, we can see the libcap code only calls 3 syscalls:
>>
>> capget({_LINUX_CAPABILITY_VERSION_3, 0}, NULL) = 0
>> capget({_LINUX_CAPABILITY_VERSION_3, 0}, {CAP_CHOWN|CAP_DAC_OVERRIDE|CAP_DAC_READ_SEARCH|CAP_FOWNER|CAP_FSETID|CAP_KILL|CAP_SETGID|CAP_SET
>> UID|CAP_SETPCAP|CAP_LINUX_IMMUTABLE|CAP_NET_BIND_SERVICE|CAP_NET_BROADCAST|CAP_NET_ADMIN|CAP_NET_RAW|CAP_IPC_LOCK|CAP_IPC_OWNER|CAP_SYS_MO
>> DULE|CAP_SYS_RAWIO|CAP_SYS_CHROOT|CAP_SYS_PTRACE|CAP_SYS_PACCT|CAP_SYS_ADMIN|CAP_SYS_BOOT|CAP_SYS_NICE|CAP_SYS_RESOURCE|CAP_SYS_TIME|CAP_S
>> YS_TTY_CONFIG|CAP_MKNOD|CAP_LEASE|CAP_AUDIT_WRITE|CAP_AUDIT_CONTROL|CAP_SETFCAP, CAP_CHOWN|CAP_DAC_OVERRIDE|CAP_DAC_READ_SEARCH|CAP_FOWNER
>> |CAP_FSETID|CAP_KILL|CAP_SETGID|CAP_SETUID|CAP_SETPCAP|CAP_LINUX_IMMUTABLE|CAP_NET_BIND_SERVICE|CAP_NET_BROADCAST|CAP_NET_ADMIN|CAP_NET_RA
>> W|CAP_IPC_LOCK|CAP_IPC_OWNER|CAP_SYS_MODULE|CAP_SYS_RAWIO|CAP_SYS_CHROOT|CAP_SYS_PTRACE|CAP_SYS_PACCT|CAP_SYS_ADMIN|CAP_SYS_BOOT|CAP_SYS_N
>> ICE|CAP_SYS_RESOURCE|CAP_SYS_TIME|CAP_SYS_TTY_CONFIG|CAP_MKNOD|CAP_LEASE|CAP_AUDIT_WRITE|CAP_AUDIT_CONTROL|CAP_SETFCAP, 0}) = 0
>> capset({_LINUX_CAPABILITY_VERSION_3, 0}, {CAP_CHOWN|CAP_DAC_OVERRIDE|CAP_DAC_READ_SEARCH|CAP_FOWNER|CAP_FSETID|CAP_KILL|CAP_SETGID|CAP_SETUID|CAP_SETPCAP|CAP_LINUX_IMMUTABLE|CAP_NET_BIND_SERVICE|CAP_NET_BROADCAST|CAP_NET_ADMIN|CAP_NET_RAW|CAP_IPC_LOCK|CAP_IPC_OWNER|CAP_SYS_RAWIO|CAP_SYS_CHROOT|CAP_SYS_PTRACE|CAP_SYS_PACCT|CAP_SYS_ADMIN|CAP_SYS_BOOT|CAP_SYS_NICE|CAP_SYS_RESOURCE|CAP_SYS_TIME|CAP_SYS_TTY_CONFIG|CAP_MKNOD|CAP_LEASE|CAP_AUDIT_WRITE|CAP_AUDIT_CONTROL|CAP_SETFCAP, CAP_CHOWN|CAP_DAC_OVERRIDE|CAP_DAC_READ_SEARCH|CAP_FOWNER|CAP_FSETID|CAP_KILL|CAP_SETGID|CAP_SETUID|CAP_SETPCAP|CAP_LINUX_IMMUTABLE|CAP_NET_BIND_SERVICE|CAP_NET_BROADCAST|CAP_NET_ADMIN|CAP_NET_RAW|CAP_IPC_LOCK|CAP_IPC_OWNER|CAP_SYS_RAWIO|CAP_SYS_CHROOT|CAP_SYS_PTRACE|CAP_SYS_PACCT|CAP_SYS_ADMIN|CAP_SYS_BOOT|CAP_SYS_
 NICE|CAP_SYS_RESOURCE|CAP_SYS_TIME|CAP_SYS_TTY_CONFIG|CAP_MKNOD|CAP_LEASE|CAP_AUDIT_WRITE|CAP_AUDIT_CONTROL|CAP_SETFCAP, 0}) = 0
>>
>> though, for added fun, when running the demo program via strace
>> the problem does not appear :-(
>>
>>
>>
>> On a slightly related topic, I've noticed that it is not possible to
>> invoke prctl(PR_CAPBSET_DROP) to clear the bounding set for processes
>> inside a container. The kernel code uses capable() instead of ns_capable().
>> Is this intended, or a missing conversion ?
>>
>> Indeed, even ignoring namespaces for a minute, I'm curious as to why
>> CAP_SETPCAP is required at all for PR_CAPBSET_DROP ?  Is it really
>> a security risk to allow a non-privileged user to remove bits from
>> the bounding set ? For KVM I'd like to be able to use PR_CAPBSET_DROP
>> to prevent a compromised KVM process from using any setuid program to
>> re-gain any kind of capabilities.  Similarly I think a container admin
>> may well wish to make use of PR_CAPBSET_DROP to lock down applications
>> there.
> 
> 
> Opps, I should have mentioned that I'm using 3.9.4 kernel. Basically the
> Fedora 3.9.4-303 build, but with CONFIG_XFS_FS=n and CONFIG_USER_NS=y
> set in the Kconfig.

FWIW, I can reproduce the issue on v3.10 vanilla.

Thanks,
//richard
