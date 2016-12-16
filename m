From: Alban Crequy <alban.crequy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v4 0/3] perf: add support for analyzing events for
	containers
Date: Fri, 16 Dec 2016 13:14:01 +0100
Message-ID: <CAMXgnP5o=rVuOAvVa8L43CVpVGHc5nFceOA4128ahNb6awUH8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Hari Bathini <hbathini-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, ananth-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, alexander.shishkin-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, kernel-6AxghH7DbtA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, aravinda-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

> Currently, there is no trivial mechanism to analyze events based on
> containers. perf -G can be used, but it will not filter events for the
> containers created after perf is invoked, making it difficult to assess/
> analyze performance issues of multiple containers at once.
>
> This patch-set overcomes this limitation by using cgroup identifier as
> container unique identifier. A new PERF_RECORD_NAMESPACES event that
> records namespaces related info is introduced, from which the cgroup
> namespace's device & inode numbers are used as cgroup identifier. This
> is based on the assumption that each container is created with it's own
> cgroup namespace allowing assessment/analysis of multiple containers
> using cgroup identifier.
>
> The first patch introduces PERF_RECORD_NAMESPACES in kernel while the
> second patch makes the corresponding changes in perf tool to read this
> PERF_RECORD_NAMESPACES events. The third patch adds a cgroup identifier
> column in perf report, which contains the cgroup namespace's device and
> inode numbers.

I have a question for the pid namespace: does the new perf event gives
the pid namespace of the task, or the pid_ns_for_children from the
nsproxy? From my limited understanding, v4 seems to do the former, as
opposed to v3.

When synthesizing events from /proc/$PID/ns/pid, it cannot take the
pid_ns_for_children, so I wanted to make sure it is consistent.

Cheers,
Alban
