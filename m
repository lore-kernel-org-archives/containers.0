From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC] cgroup: removing css reference drain wait during cgroup
	removal
Date: Tue, 13 Mar 2012 15:05:51 -0700
Message-ID: <20120313220551.GF7349__31193.6852559031$1331676367$gmane$org@google.com>
References: <20120312213155.GE23255@google.com>
	<20120313214526.GG19584@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120313214526.GG19584-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: linux-mm-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hey, Matt.

On Tue, Mar 13, 2012 at 02:45:26PM -0700, Matt Helsley wrote:
> If you want to spend your time doing archaeology there are some old threads
> that touch on this idea (roughly around 2003-2005). One point against the
> idea that I distinctly recall:
> 
> Somewhat like configfs, object lifetimes in cgroups are determined
> primarily by the user whereas sysfs object lifetimes are primarily
> determined by the kernel. I think the closest we come to user-determined
> objects in sysfs occur through debugfs, and module loading/unloading.
> However those involve mount/umount and modprobe/rmmod rather than
> mkdir/rmdir to create and remove the objects.

The thing is that sysfs itself has been almost completely rewritten
since that time to 1. decouple internal representation from vfs
objects and 2. provide proper isolation between the userland and
kernel code exposing data through sysfs.

#1 began mostly due to the large size of dentries and inodes but, with
the benefit of hindsight, I think it just was a bad idea to piggyback
on vfs objects for object life-cycle management and locking for stuff
which is wholely described in memory with simplistic locking.

#2 was necessary to avoid hanging device detach due to open sysfs file
from userland.  sysfs now has notion of "active access" encompassing
only each show/store op invocation and it only guarantees that the
associated device doesn't go away while active accesses are in
progress.

The sysfs heritage is almost recognizable and unfortunately almost the
same set of problems (nobody wants show/store ops to be called on
unlinked css waiting for references to be drained).  As refactoring
and sharing sysfs won't be a trivial task, my plan is to first augment
cgroupfs as necessary with longer term goal of converging and later
sharing the same code with sysfs.

Thanks.

-- 
tejun
