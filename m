From: Vaibhav Nagarnaik <vnagarnaik-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [RFC] tracing: Adding cgroup aware tracing functionality
Date: Wed, 6 Apr 2011 11:50:21 -0700
Message-ID: <BANLkTik_jtjWTsOueUzfdQXRx17OcgyDgA__18496.8226742514$1302116094$gmane$org@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Steven
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

All

The cgroup functionality is being used widely in different scenarios. It also
is being integrated with other parts of kernel to take advantage of its
features. One of the areas that is not yet aware of cgroup functionality is
the ftrace framework.

Although ftrace provides a way to filter based on PIDs of tasks to be traced,
it is restricted to specific tracers, like function tracer. Also it becomes
difficult to keep track of all PIDs in a dynamic environment with processes
being created and destroyed in a short amount of time.

An application that creates many processes/tasks is convenient to track and
control with cgroups, but it is difficult to track these processes for the
purposes of tracing. And if child processes are moved to another cgroup, it
makes sense to trace only the original cgroup.

This proposal is to create a file in the tracing directory called
set_trace_cgroup to which a user can write the path of an active cgroup, one
at a time. If no cgroups are specified, no filtering is done and all tasks are
traced. When a cgroup path is added in, it sets a boolean tracing_enabled for
the enabled cgroup in all the hierarchies, which enables tracing for all the
assigned tasks under the specified cgroup.

Though creating a new file in the directory is not desirable, but this
interface seems the most appropriate change required to implement the new
feature.

This tracing_enabled flag is also exported in the cgroupfs directory structure
which can be turned on/off for a specific hierarchy/cgroup combination. This
gives control to enable/disable tracing over a cgroup in a specific hierarchy
only.

This gives more fine-grained control over the tasks being traced. I would like
to know your thoughts on this interface and the approach to make tracing
cgroup aware.


Thanks

Vaibhav Nagarnaik
