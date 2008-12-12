From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [Bugme-new] [Bug 12199] New: /proc/1/exe entry of PID namespace
	init process links to wrong executable
Date: Thu, 11 Dec 2008 17:48:13 -0800
Message-ID: <m1prjymaea.fsf@frodo.ebiederm.org>
References: <bug-12199-10286@http.bugzilla.kernel.org/>
	<20081211091430.ea3d434d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081211091430.ea3d434d.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> (Andrew
	Morton's message of "Thu, 11 Dec 2008 09:14:30 -0800")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org
List-Id: containers.vger.kernel.org

Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> writes:

> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
>
> On Thu, 11 Dec 2008 08:16:55 -0800 (PST) bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org wrote:
>
>> http://bugzilla.kernel.org/show_bug.cgi?id=12199
>> 
>>            Summary: /proc/1/exe entry of PID namespace init process links to
>>                     wrong executable
>>            Product: Process Management
>>            Version: 2.5
>>      KernelVersion: 2.6.27.8
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: low
>>           Priority: P1
>>          Component: Other
>>         AssignedTo: process_other-ztI5WcYan/vQLgFONoPN62D2FQJk+8+b@public.gmane.org
>>         ReportedBy: robert.rex-GD4dBWQXeU/QT0dZR+AlfA@public.gmane.org
>> 
>> 
>> Latest working kernel version:
>> 
>> None known.
>> 
>> Earliest failing kernel version:
>> 
>> 2.6.25.4, 2.6.27.4 and 2.6.27.8 show this behaviour, but I assume that it
>> exists since 2.6.24 with the introduction of PID namespaces.
>> 
>> Distribution: CentOS 5.1
>> 
>> Hardware Environment: x86-64
>> 
>> Software Environment: (see attached test program)
>> 
>> Problem Description:
>> 
>> The /proc/1/exe entry of a new PID namespace does not link to the expected
>> binary if it was started within a chroot. All other processes in this
> namespace
>> link to the expected path.
>> 
>> Steps to reproduce: (see attached test program)
>> 
>> 1) chroot() into an appropriate directory.
>> 2) Create a process, which clone()s a thread in a new PID namespace with
>> CLONE_NEWPID.
>> 3) Mount /proc from within this new namespace.
>> 3) Read the /proc/1/exe link from within this new namespace. It points to the
>> "real" binary, not the (expected) link that is valid in this chroot.
>> 
>> The attached program executes steps 2, 3 and 4 and does a "/bin/ls -la /proc/1
>> /proc/2" in the new namespace. The output below was collected with the
>> following commands:
>> 
>> 1) mkdir /tmp/target
>> 2) mount /dev/sda1 /tmp/target (/dev/sda1 is also mounted on /)
>> 3) chroot /tmp/target
>> 4) ./pid_namespace_chroot
>> 
>> ---------------
>> /proc/1:
>> [...]
>> lrwxrwxrwx   1 root root 0 Dec 11 16:18 exe ->
>> /tmp/target/root/pid_namespace_chroot
>> [...]
>> lrwxrwxrwx   1 root root 0 Dec 11 16:18 root -> /
>> [...]
>> 
>> /proc/2:
>> [...]
>> lrwxrwxrwx   1 root root 0 Dec 11 16:18 exe -> /bin/ls
>> [...]
>> lrwxrwxrwx   1 root root 0 Dec 11 16:18 root -> /
>> [...]
>> ---------------
>> 
>> Hopefully, I do not miss a point, but I assume that this is not intended?!
>> 
>
> Thanks.
>
> There's a test program attached to the bugzilla report.

This behavior is reproducible.

The code just calls d_path with resolves things against current->fs->root.
Which should be the caller.

So I see no apparent reason for this behavior.

Oh.  I see.

You specified NEWNS  in your clone flags, creating a new mount namespace
as well.

Your executable came from a different mount namespace and thus has a different
set of mounts.  Which defeats the logic in d_path to honor current->fs->root
because your executable came from a different universe.

No bugs here just weird corner cases with the mount namespace.

Eric
