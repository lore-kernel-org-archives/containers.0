From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0/4] x86: Add Cache QoS Monitoring (CQM) support
Date: Fri,  3 Jan 2014 12:34:41 -0800
Message-ID: <1388781285-18067-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
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
To: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

This patchset adds support for the new Cache QoS Monitoring (CQM)
feature found in future Intel Xeon processors.

CQM allows a process, or set of processes, to be tracked by the CPU
to determine the cache usage of that task group.  Using this data
from the CPU, software can be written to extract this data and
report cache usage and occupancy for a particular process, or
group of processes.

More information about Cache QoS Monitoring can be found in the
Intel (R) x86 Architecture Software Developer Manual, section 17.14.

This series is also laying the framework for additional Platform
QoS features in future Intel Xeon processors.

The CPU features themselves are relatively straight-forward, but
the presentation of the data is less straight-forward.  Since this
tracks cache usage and occupancy per process (by swapping Resource
Monitor IDs, or RMIDs, when processes are rescheduled), perf would
not be a good fit for this data, which does not report on a
per-process level.  Therefore, a new cgroup subsystem, cacheqos, has
been added.  This operates very similarly to the cpu and cpuacct
cgroup subsystems, where tasks can be grouped into sub-leaves of the
root-level cgroup.

Peter P Waskiewicz Jr (4):
      x86: Add support for Cache QoS Monitoring (CQM) detection
      x86: Add Cache QoS Monitoring support to x86 perf uncore
      cgroup: Add new cacheqos cgroup subsys to support Cache QoS Monitoring
      Documentation: Add documentation for cacheqos cgroup
