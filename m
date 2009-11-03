From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC][PATCH 0/3] cgroups: support for module-loadable subsystems
Date: Tue, 03 Nov 2009 10:03:42 +0800
Message-ID: <4AEF8F7E.1000007__33321.665498852$1257213923$gmane$org@cn.fujitsu.com>
References: <20091102212825.GA13692@andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091102212825.GA13692-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Ben Blum wrote:
> This patch series implements simple support for building and loading
> subsystems as modules, both within and outside the kernel source tree.
> Module unloading is as yet unimplemented - it will require more advanced
> reference counting in the mount/unmount code, and I plan to work on this
> soon.
> 

I doubt the value of module-loadable subsystems. A cgroup subsystem
is usually a kernel resource controller, and normally it needs to
add some hooks in some in-kernel structures and functions, which
makes it impossible to be a module.

In fact, net_cls is the only subsystem that can be a module, and
make it a module doesn't seem to have real benefit?

> Patch #1 sets up the subsys[] array so its contents can be dynamic as
> modules appear and (eventually) disappear. I introduce an rwsem called
> subsys_mutex to protect against concurrent loads/unloads/reads, and
> modify iterations over the array to handle when subsystems are absent.
> 
> Patch #2 implements an interface for modules to load subsystems, called
> cgroup_load_subsys, similar to cgroup_init_subsys, and adds a module
> pointer in struct cgroup_subsys.
> 
> Patch #3 modifies the net_cls subsystem, which already had some module
> declarations, to be configurable as a module, which also serves as a
> simple proof-of-concept.
> 
> -- bblum
>  
