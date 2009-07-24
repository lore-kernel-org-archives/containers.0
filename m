From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 4/4] Allow cgroup hierarchies to be created with no bound
	subsystems
Date: Fri, 24 Jul 2009 13:21:42 +0800
Message-ID: <4A6944E6.1090405__8536.43662198937$1248413137$gmane$org@cn.fujitsu.com>
References: <20090722194644.7481.47805.stgit@menage.mtv.corp.google.com>
	<20090722195045.7481.62013.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090722195045.7481.62013.stgit-u3IScbYxn0zHt/MElyovVYaSKrA+ACpX0E9HWUfgJXw@public.gmane.org>
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
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> Allow cgroup hierarchies to be created with no bound subsystems
> 
> This patch removes the restriction that a cgroup hierarchy must have
> at least one bound subsystem.  The mount option "none" is treated as
> an explicit request for no bound subsystems.
> 
> A hierarchy with no subsystems can be useful for plain task tracking,
> and is also a step towards the support for multiply-bindable
> subsystems.
> 
> As part of this change, the hierarchy id is no longer calculated from
> the bitmask of subsystems in the hierarchy (since this is not
> guaranteed to be unique) but is allocated via an ida.  Reference
> counts on cgroups from css_set objects are now taken explicitly one
> per hierarchy, rather than one per subsystem.
> 
> Example usage:
> 
> mount -t cgroup -o none,name=foo cgroup /mnt/cgroup
> 
> Based on the "no-op"/"none" subsystem concept proposed by
> kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
> 
> Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 

Reviewed-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
