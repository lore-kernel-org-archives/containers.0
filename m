From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v5 2/3] cgroups: add can_attach callback for checking all
	threads in a group
Date: Mon, 23 Aug 2010 16:31:47 -0700
Message-ID: <AANLkTind=V+V8vz1PGWiB8bCGVmfPJgC1q_XRmi5t_Eq__4954.22647004506$1282606356$gmane$org@mail.gmail.com>
References: <20100730235649.GA22644@ghc17.ghc.andrew.cmu.edu>
	<20100811054604.GA8743@ghc17.ghc.andrew.cmu.edu>
	<20100811054814.GC8743@ghc17.ghc.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100811054814.GC8743-dJQ2lsn+DImqwBT9kiuFm8WGCVk0P7UB@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Aug 10, 2010 at 10:48 PM, Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:
>
> Add cgroup wrapper for safely calling can_attach on all threads in a threadgroup
>
> From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
>
> This patch adds a function cgroup_can_attach_per_thread which handles iterating
> over each thread in a threadgroup safely with respect to the invariants that
> will be used in cgroup_attach_proc. Also, subsystems whose can_attach calls
> require per-thread validation are modified to use the per_thread wrapper to
> avoid duplicating cgroup-internal code.
>
> This is a pre-patch for cgroup-procs-writable.patch.
>
> Signed-off-by: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Some of the can_attach() methods could be simplified slightly by
directly returning the result of cgroup_can_attach_per_thread()

Paul
