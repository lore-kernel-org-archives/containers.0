From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Interaction user namespace, /proc/1 ownership & cap_set
Date: Tue, 02 Jul 2013 02:57:34 -0700
Message-ID: <87ehbhthbl.fsf@xmission.com>
References: <20130701161625.GQ15954@redhat.com>
	<51D261D3.3030002@cn.fujitsu.com> <87wqp9uz9a.fsf@xmission.com>
	<51D295C5.1080003@nod.at> <20130702092554.GD2524@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130702092554.GD2524-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (Daniel P. Berrange's message
	of "Tue, 2 Jul 2013 10:25:54 +0100")
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
Cc: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

"Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> On Tue, Jul 02, 2013 at 10:56:37AM +0200, Richard Weinberger wrote:
>> Am 02.07.2013 10:44, schrieb Eric W. Biederman:
>> > Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:
>> > 
>> >> On 07/02/2013 12:16 AM, Daniel P. Berrange wrote:
>> >>> I'm struggling debugging a strange problem with interaction between user
>> >>> namespaces, cap_set and ownership of files in /proc/1/
>> >>>
>> >>
>> >> This problem is occured after we call setuid/gid.
>> >>
>> >> for example, a task whose pid is 1234 calls
>> >> setregid(10,10);
>> >> setreuid(10,10);
>
> If seems to get reset to the right values (0:0) when we execve()
> the init binary though.  This doesn't happen if we have invoked
> the capset() syscall in between the setregid & the execve() calls.

Yes, execve() should reset the dumpable state.

I took a quick look and I don't see a way around set_dumpable calls in
setup_new_exec.  Why the process remains undumpable after exec is worth
investigating.  That logic should not be user namespace specific
however.

>> >> The uid/gid of the /proc/1234 is 10:0
>> >> ll /proc/1234 -d
>> >> dr-xr-xr-x 8 uucp wheel 0 Jul  2 10:57 /proc/1234
>> >>
>> >> the uid/gid of the files under /proc/1234 are two kinds...
>> >> ll /proc/1234
>> >> dr-xr-xr-x 2 uucp wheel 0 Jul  2 10:58 attr
>> >> -rw-r--r-- 1 root root 0 Jul  2 10:58 autogroup
>> >> ...
>> >> dr-xr-xr-x 5 uucp wheel 0 Jul  2 10:58 net
>> >> dr-x--x--x 2 root root 0 Jul  2 10:58 ns
>> >> ...
>> >> dr-xr-xr-x 3 uucp wheel 0 Jul  2 10:58 task
>> >>
>> >> I checked the pre_revalidate and found the owner of the files under /proc/<pid>
>> >> will be set to the GLOBAL_ROOT_UID if the task executed setuid/setgid(task_dumpable is false).
>> >> Is this what we expected? why? 
>> > 
>> > Expected yes.  Perfect perhaps not.
>> > 
>> > That piece of code has not been examined to see if it is safe to use
>> > make_kuid(task_user_ns(task), 0), instead of GLOBAL_ROOT_UID.
>> > 
>> >> For user namespace,the owner of /proc/1/* is incorrect and
>> >> after task call setuid/gid in user namespace, the owner of /proc/<pid-of-this-task>/* is incorrect
>> >> too.
>> > 
>> > From the current semantics of dumpable GLOBAL_ROOT_UID is correct.
>> > 
>> > Please double check but I believe /proc/self should continue to work,
>> > despite this.
>> 
>> /proc/self is not an option. systemd (in particular some of it's
>> tools with pid != 1) read from /proc/1/environ to find out what
>> environment variables it got to detect LXC and other visualization
>> environments.  With userns enabled this check fails and systemd goes
>> nuts because it thinks that it lives on top of a "real" Linux.

How odd.  Last I was paying attention it was the selinux policy that you
could only access your own proc files, because of the way ptrace was
limited.

As for systemd doing the wrong thing, it sounds like Richard has found a
fertile source of imperfections.

> I don't even see how /proc/self would solve this, since it
> is just a symlink pointing to /proc/1 in this scenario, so
> the ownership of files at /proc/1/XXXX would still be wrong.
>
> This isn't really a systemd specific problem either, I think
> any app would expect to be able to read its own files under
> /proc/$PID/

I meant there is a special case in the permission check for accessing
your own files as you must do when going through /proc/self.  It is
worth verifying that special case for accessing your own files continues
to work even when you are in a user namespace.

Eric
