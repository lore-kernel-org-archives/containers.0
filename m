From: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH] procfs: change the owner of non-dumpable and writeable
	files
Date: Fri, 20 Jan 2017 00:08:12 +1100
Message-ID: <e7137350-b8a8-c7e5-e35d-8218a7df1147@suse.de>
References: <20170118040159.4751-1-asarai@suse.de>
	<20170119092930.GJ30786@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170119092930.GJ30786-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, dev-IGmTWi+3HBZvNhPySn5qfx2eb7JE58TQ@public.gmane.org, John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Janis Danisevskis <jdanis-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

>> In order to protect against ptrace(2) and similar attacks on container
>> runtimes when they join namespaces, many runtimes set mm->dumpable to
>> SUID_DUMP_DISABLE. However, doing this means that attempting to set up
>> an unprivileged user namespace will fail because an unprivileged process
>> can no longer access /proc/self/{setgroups,{uid,gid}_map} for the
>> container process (which is the same uid as the runtime process).
>>
>> Fix this by changing pid_getattr to *also* change the owner of regular
>> files that have a mode of 0644 (when the process is not dumpable). This
>> ensures that the important /proc/[pid]/... files mentioned above are
>> properly accessible by a container runtime in a rootless container
>> context.
>>
>> The most blantant issue is that a non-dumpable process in a rootless
>> container context is unable to open /proc/self/setgroups, because it
>> doesn't own the file.
>>
>> int main(void)
>> {
>> 	prctl(PR_SET_DUMPABLE, 0, 0, 0, 0);
>> 	unshare(CLONE_NEWUSER);
>>
>> 	/* This will fail. */
>> 	int fd = open("/proc/self/setgroups", O_WRONLY);
>> 	if (fd < 0)
>> 		abort();
>>
>> 	return 0;
>> }
>
> I do agree that failing to open anything in /proc/self/ is more than
> unexepcted! I cannot judge the patch but my gut feeling tells me that
> the fix should be somewhere in the open handler.

Maybe that would suffice as a more specific fix (for the special case of 
/proc/self), but the fact that none of the users and groups are 
correctly set in /proc/[pid] will cause issues for runC and other 
container runtimes (because they don't go through /proc/self -- it's 
accessing /proc/[pid] from another process).

Though I get the feeling that the *correct* fix would be to remove the 
conditional and *always* change the owner -- maybe I'm missing something 
but I can't think of the security issue that this code currently fixes 
(since all of the important permission checks are *in addition* to the 
generic_permission used for /proc/self/..., which use ptrace_may_access).

-- 
Aleksa Sarai
Software Engineer (Containers)
SUSE Linux GmbH
https://www.cyphar.com/
