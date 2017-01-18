From: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH] procfs: change the owner of non-dumpable and writeable
	files
Date: Thu, 19 Jan 2017 10:34:02 +1100
Message-ID: <45b680a7-cdc7-8c53-1cf9-92a5afc5f55f@suse.de>
References: <20170118040159.4751-1-asarai@suse.de>
	<CAGXu5jL4R-rqv-33XvvsMOqcxBgPRm-eAeRThdN515Ux3TSiFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAGXu5jL4R-rqv-33XvvsMOqcxBgPRm-eAeRThdN515Ux3TSiFw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Michal Hocko <mhocko-IBi9RG/b67k@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, dev-IGmTWi+3HBZvNhPySn5qfx2eb7JE58TQ@public.gmane.org, John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Janis Danisevskis <jdanis-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
>
> This changes a lot more than just setgroups, doesn't it? This bypasses
> the task_dumpable check for all kinds of things.

Yeah. I can special case /proc/self/setgroups as well as uid_map, 
gid_map and the other *specific* things that runC needs. But ultimately 
I think we should come up with agreement on what things should always 
appear to be owned by the process's user.

> Though, I expect the
> has_pid_permissions() check to be the harder one to pass. Why does
> has_pid_permissions() succeed in the case you've given?

Because the group id of the container process is the same as the parent 
process, so is_group_p() will succeed. Also hide_pid_min is set such 
that it will work in either case.

-- 
Aleksa Sarai
Software Engineer (Containers)
SUSE Linux GmbH
https://www.cyphar.com/
