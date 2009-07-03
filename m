From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 7/9] [RFC] Support multiply-bindable cgroup subsystems
Date: Fri, 03 Jul 2009 16:36:55 +0800
Message-ID: <4A4DC327.3080004__35046.6154203334$1246610265$gmane$org@cn.fujitsu.com>
References: <20090702020624.14469.47066.stgit@menage.mtv.corp.google.com>
	<20090702021128.14469.3360.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090702021128.14469.3360.stgit-u3IScbYxn0zHt/MElyovVYaSKrA+ACpX0E9HWUfgJXw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> [RFC] Support multiply-bindable cgroup subsystems
> 
> This patch allows a cgroup subsystem to be marked as bindable on
> multiple cgroup hierarchies independently, when declared in
> cgroup_subsys.h via MULTI_SUBSYS() rather than SUBSYS().
> 
> The state for such subsystems cannot be accessed directly from a
> task->cgroups (since there's no unique mapping for a task) but instead
> must be accessed via a particular control group object.
> 
> Multiply-bound subsystems are useful in cases where there's no direct
> correspondence between the cgroup configuration and some property of
> the kernel outside of the cgroups subsystem.  So this would not be
> applicable to e.g. the CFS cgroup, since there has to a unique mapping
> from a task to its CFS run queue.
> 
> As an example, the "debug" subsystem is marked multiply-bindable,
> since it has no state outside the cgroups framework itself.
> 

Great, this makes the debug subsystem more useful. Sometimes
I want to see some debug info in different hierarchies, but
I can't just because it can only be bound to one hierarchy.

> Example usage:
> 
> mount -t cgroup -o name=foo,debug,cpu cgroup /mnt1
> mount -t cgroup -o name=bar,debug,memory cgroup /mnt2
> 
> Open Issues:
> 
> - in the current version of this patch, mounting a cgroups hierarchy
>   with no options does *not* get you any of the multi-bindable
>   subsystems; possibly for consistency it should give you all of the
>   multi-bindable subsystems as well as all of the single-bindable
>   subsystems.
> 

Yeah, the latter is preferrable.

> - how can we avoid the checkpatch.pl errors due to creative use of
>   macros to generate enum names?

checkpatch.pl can sometimes generate false-positive, let's happily
ignore those "errors". ;)

But it whould be better if those macros can be handled in a cleaner way.
