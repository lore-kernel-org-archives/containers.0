From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v5 1/3] cgroups: read-write lock CLONE_THREAD forking per
	threadgroup
Date: Mon, 23 Aug 2010 16:35:55 -0700
Message-ID: <AANLkTi=e-kwUzfb2Mv8JmwKm_AxyB=ZeTVb+K0dBU4eu__37229.7143018388$1282606808$gmane$org@mail.gmail.com>
References: <20100730235649.GA22644@ghc17.ghc.andrew.cmu.edu>
	<20100811054604.GA8743@ghc17.ghc.andrew.cmu.edu>
	<20100811054711.GB8743@ghc17.ghc.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100811054711.GB8743-dJQ2lsn+DImqwBT9kiuFm8WGCVk0P7UB@public.gmane.org>
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

On Tue, Aug 10, 2010 at 10:47 PM, Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:
>
>
> Adds functionality to read/write lock CLONE_THREAD fork()ing per-threadgroup
>
> From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
>
> This patch adds an rwsem that lives in a threadgroup's signal_struct that's
> taken for reading in the fork path, under CONFIG_CGROUPS. If another part of
> the kernel later wants to use such a locking mechanism, the CONFIG_CGROUPS
> ifdefs should be changed to a higher-up flag that CGROUPS and the other system
> would both depend on.
>
> This is a pre-patch for cgroup-procs-write.patch.
>
> Signed-off-by: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Paul
