From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [RFD] reboot / shutdown of a container
Date: Thu, 13 Jan 2011 22:32:19 +0100
Message-ID: <4D2F6F63.8090904__13796.9825220809$1294970906$gmane$org@free.fr>
References: <4D2F299B.4000509@free.fr> <20110113210918.48f3e85e@neptune.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110113210918.48f3e85e-hY15tx4IgV39zxVx7UNMDg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: =?ISO-8859-1?Q?Bruno_Pr=E9mont?= <bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 01/13/2011 09:09 PM, Bruno Pr=E9mont wrote:
> On Thu, 13 January 2011 Daniel Lezcano<daniel.lezcano-GANU6spQydw@public.gmane.org>  wrote:
>> in the container implementation, we are facing the problem of a process
>> calling the sys_reboot syscall which of course makes the host to
>> poweroff/reboot.
>>
>> If we drop the cap_sys_reboot capability, sys_reboot fails and the
>> container reach a shutdown state but the init process stay there, hence
>> the container becomes stuck waiting indefinitely the process '1' to exit.
>>
>> The current implementation to make the shutdown / reboot of the
>> container to work is we watch, from a process outside of the container,
>> the<rootfs>/var/run/utmp file and check the runlevel each time the file
>> changes. When the 'reboot' or 'shutdown' level is detected, we wait for
>> a single remaining in the container and then we kill it.
>>
>> That works but this is not efficient in case of a large number of
>> containers as we will have to watch a lot of utmp files. In addition,
>> the /var/run directory must *not* mounted as tmpfs in the distro.
>> Unfortunately, it is the default setup on most of the distros and tends
>> to generalize. That implies, the rootfs init's scripts must be modified
>> for the container when we put in place its rootfs and as /var/run is
>> supposed to be a tmpfs, most of the applications do not cleanup the
>> directory, so we need to add extra services to wipeout the files.
>>
>> More problems arise when we do an upgrade of the distro inside the
>> container, because all the setup we made at creation time will be lost.
>> The upgrade overwrite the scripts, the fstab and so on.
>>
>> We did what was possible to solve the problem from userspace but we
>> reach always a limit because there are different implementations of the
>> 'init' process and the init's scripts differ from a distro to another
>> and the same with the versions.
>>
>> We think this problem can only be solved from the kernel.
>>
>> The idea was to send a signal SIGPWR to the parent of the pid '1' of the
>> pid namespace when the sys_reboot is called. Of course that won't occur
>> for the init pid namespace.
> Wouldn't sending SIGKILL to the pid '1' process of the originating PID
> namespace be sufficient (that would trigger a SIGCHLD for the parent
> process in the outer PID namespace.

This is already the case. The question is : when do we send this signal ?
We have to wait for the container system shutdown before killing it.

> (as far as I remember the PID namespace is killed when its 'init' exits,
> if this is not the case all other processes in the given namespace would
> have to be killed as well)

Yes, absolutely but this is not the point, reaping the container is not =

a problem.

What we are trying to achieve is to shutdown properly the container from =

inside (from outside will be possible too with the setns syscall).

Assuming the process '1234' creates a new process in a new namespace set =

and wait for it.

The new process '1' will exec /sbin/init and the system will boot up. =

But, when the system is shutdown or rebooted, after the down scripts are =

executed the kill -15 -1 will be invoked, killing all the processes =

expect the process '1' and the caller. This one will then call =

'sys_reboot' and exit. Hence we still have the init process idle and its =

parent '1234' waiting for it to die.

If we are able to receive the information in the process '1234' : "the =

sys_reboot was called in the child pid namespace", we can take then kill =

our child pid.  If this information is raised via a signal sent by the =

kernel with the proper information in the siginfo_t (eg. si_code =

contains "LINUX_REBOOT_CMD_RESTART", "LINUX_REBOOT_CMD_HALT", ... ), the =

solution will be generic for all the shutdown/reboot of any kind of =

container and init version.

> Only issue is how to differentiate the various reboot() modes (restart,
> power-off/halt) from outside, though that one also exists with the SIGPWR
> signal.


<javascript:void(0);>
