From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC] tracing: Adding cgroup aware tracing functionality
Date: Thu, 7 Apr 2011 14:06:11 +0200
Message-ID: <20110407120608.GB1798__40630.1843737767$1302178123$gmane$org@nowhere>
References: <BANLkTik_jtjWTsOueUzfdQXRx17OcgyDgA@mail.gmail.com>
	<20110407013349.GH1867@nowhere>
	<BANLkTinKsYqkEEUu98t+Gn9ciPn_bmsMFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <BANLkTinKsYqkEEUu98t+Gn9ciPn_bmsMFQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vaibhav Nagarnaik <vnagarnaik-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Michael Rubin <mrubin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, David Sharp <dhsharp-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>, Ken Chen <kenchen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Apr 06, 2011 at 08:17:33PM -0700, Vaibhav Nagarnaik wrote:
> On Wed, Apr 6, 2011 at 6:33 PM, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > On Wed, Apr 06, 2011 at 11:50:21AM -0700, Vaibhav Nagarnaik wrote:
> >> All
> >> The cgroup functionality is being used widely in different scenarios. It also
> >> is being integrated with other parts of kernel to take advantage of its
> >> features. One of the areas that is not yet aware of cgroup functionality is
> >> the ftrace framework.
> >>
> >> Although ftrace provides a way to filter based on PIDs of tasks to be traced,
> >> it is restricted to specific tracers, like function tracer. Also it becomes
> >> difficult to keep track of all PIDs in a dynamic environment with processes
> >> being created and destroyed in a short amount of time.
> >>
> >> An application that creates many processes/tasks is convenient to track and
> >> control with cgroups, but it is difficult to track these processes for the
> >> purposes of tracing. And if child processes are moved to another cgroup, it
> >> makes sense to trace only the original cgroup.
> >>
> >> This proposal is to create a file in the tracing directory called
> >> set_trace_cgroup to which a user can write the path of an active cgroup, one
> >> at a time. If no cgroups are specified, no filtering is done and all tasks are
> >> traced. When a cgroup path is added in, it sets a boolean tracing_enabled for
> >> the enabled cgroup in all the hierarchies, which enables tracing for all the
> >> assigned tasks under the specified cgroup.
> >>
> >> Though creating a new file in the directory is not desirable, but this
> >> interface seems the most appropriate change required to implement the new
> >> feature.
> >>
> >> This tracing_enabled flag is also exported in the cgroupfs directory structure
> >> which can be turned on/off for a specific hierarchy/cgroup combination. This
> >> gives control to enable/disable tracing over a cgroup in a specific hierarchy
> >> only.
> >>
> >> This gives more fine-grained control over the tasks being traced. I would like
> >> to know your thoughts on this interface and the approach to make tracing
> >> cgroup aware.
> >
> > So I have to ask, why can't you use perf events to do tracing limited on cgroups?
> > It has this cgroup context awareness.
> >
> 
> The perf event cgroup awareness comes from creating a different hierarchy for
> perf events. When the events and the current task's cgroup match, the events
> are logged. So the changes are pretty specific to the perf events.
> 
> Even in the case where changes are made to handle trace events, the interface
> files are still needed. The interface used to specify perf events uses the
> perf_event syscall which isn't available to specify trace events.
> 
> This is based on my limited understanding of the perf_events cgroup awareness
> patch. Please correct me if I am missing anything.


Ah but perf events can do much more than counting and sampling
hardware events. Trace events can be used as perf events too.

List the events:

	perf list -e tracepoints

List of pre-defined events (to be used in -e):

  skb:kfree_skb                              [Tracepoint event]
  skb:consume_skb                            [Tracepoint event]
  skb:skb_copy_datagram_iovec                [Tracepoint event]
  net:net_dev_xmit                           [Tracepoint event]
  net:net_dev_queue                          [Tracepoint event]
  net:netif_receive_skb                      [Tracepoint event]
  net:netif_rx                               [Tracepoint event]
  napi:napi_poll                             [Tracepoint event]
  scsi:scsi_dispatch_cmd_start               [Tracepoint event]
  scsi:scsi_dispatch_cmd_error               [Tracepoint event]
  scsi:scsi_dispatch_cmd_done                [Tracepoint event]
  scsi:scsi_dispatch_cmd_timeout             [Tracepoint event]
  scsi:scsi_eh_wakeup                        [Tracepoint event]
  drm:drm_vblank_event                       [Tracepoint event]
  drm:drm_vblank_event_queued                [Tracepoint event]
  drm:drm_vblank_event_delivered             [Tracepoint event]
  block:block_rq_abort                       [Tracepoint event]
  block:block_rq_requeue                     [Tracepoint event]
  block:block_rq_complete                    [Tracepoint event]
  block:block_rq_insert                      [Tracepoint event]
  etc...


Trace sched switch events:

	perf record -e sched:sched_switch -a
	^C


Print them:

	perf script

         swapper     0 [000]  1132.964598: sched_switch: prev_comm=swapper prev_pid=0 prev_prio=120 prev_state=R ==> next_comm
     kworker/0:1  4358 [000]  1132.964641: sched_switch: prev_comm=kworker/0:1 prev_pid=4358 prev_prio=120 prev_state=S ==> ne
         syslogd  2703 [000]  1132.964720: sched_switch: prev_comm=syslogd prev_pid=2703 prev_prio=120 prev_state=D ==> next_c
         swapper     0 [000]  1132.965100: sched_switch: prev_comm=swapper prev_pid=0 prev_prio=120 prev_state=R ==> next_comm
            perf  4725 [001]  1132.965178: sched_switch: prev_comm=perf prev_pid=4725 prev_prio=120 prev_state=D ==> next_comm
         swapper     0 [001]  1132.965227: sched_switch: prev_comm=kworker/0:0 prev_pid=0 prev_prio=120 prev_state=R ==> next_
            perf  4725 [001]  1132.965246: sched_switch: prev_comm=perf prev_pid=4725 prev_prio=120 prev_state=D ==> next_comm
	etc...
