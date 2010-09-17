From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 0/8] checkpoint/restart: sysvshm fixes and hugetlb support
Date: Thu, 16 Sep 2010 20:37:05 -0400
Message-ID: <4C92B831.40400@cs.columbia.edu>
References: <1284494530-25946-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1284494530-25946-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Nathan,

Thanks for the patch series. For starters, I'll pull
patches 1-3 for ckpt-v22-dev. I'll wait for reviews
for the others.

Oren.

On 09/14/2010 04:02 PM, Nathan Lynch wrote:
> The following patches implement c/r for huge pages and fix a couple of
> minor issues in the SysV shm c/r code I noticed in the process.
> 
> Tested on i386, x86_64, and ppc64.
> 
> Nathan Lynch (8):
>   sysvshm: check for hugetlb before assuming shmem
>   sysvshm: report error on failure to reattach, avoid crash
>   checkpoint/sysvshm: release rwsem earlier during restore
>   checkpoint/ipc: allow shmat callers to specify ipc namespace
>   checkpoint/restart of anonymous hugetlb mappings
>   remove VM_HUGETLB and VM_RESERVED from CKPT_VMA_NOT_SUPPORTED
>   hugetlbfs checkpoint/restart hooks
>   checkpoint/restart of SysV SHM_HUGETLB regions
> 
>  fs/hugetlbfs/inode.c           |   24 ++++-
>  include/linux/checkpoint.h     |    7 +-
>  include/linux/checkpoint_hdr.h |   16 +++
>  include/linux/hugetlb.h        |   11 ++
>  include/linux/shm.h            |    8 +-
>  ipc/checkpoint_shm.c           |  172 ++++++++++++++++++++++++---
>  ipc/shm.c                      |   17 ++--
>  mm/checkpoint.c                |   13 ++
>  mm/hugetlb.c                   |  257 ++++++++++++++++++++++++++++++++++++++++
>  9 files changed, 491 insertions(+), 34 deletions(-)
> 
