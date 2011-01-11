From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 00/11] checkpoint: various mm-related bits
Date: Mon, 10 Jan 2011 21:38:56 -0500
Message-ID: <4D2BC2C0.1060205@cs.columbia.edu>
References: <1287601006-13794-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1287601006-13794-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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

Thanks for the series.

I merged patches 1-3 into v23-rc1.
I posted a reworked version of patches 7-11 for (your) review.
I did not apply 4-6 yet, see my replies to 4,5 first.

Cheers,

Oren

On 10/20/2010 02:56 PM, Nathan Lynch wrote:
> Hi Oren,
> 
> Here is the hugetlb code rebased to latest ckpt-v22-dev, along with
> support for BSR device mappings and a minor fix or two.
> 
> Nathan Lynch (11):
>   checkpoint: fix leak in VMA restore error path
>   checkpoint: check actual array size before dereferencing
>   checkpoint: reformat CKPT_VMA_NOT_SUPPORTED
>   checkpoint: introduce device vma type
>   checkpoint: allow VM_{IO,RESERVED,PFNMAP} mappings
>   checkpoint: enable c/r for bsr driver
>   checkpoint/ipc: allow shmat callers to specify ipc namespace
>   checkpoint/restart of anonymous hugetlb mappings
>   hugetlbfs checkpoint/restart hooks
>   checkpoint/restart of SysV SHM_HUGETLB regions
>   remove VM_HUGETLB from CKPT_VMA_NOT_SUPPORTED
> 
>  drivers/char/bsr.c             |   13 ++
>  fs/hugetlbfs/inode.c           |   24 ++++-
>  include/linux/checkpoint.h     |   17 ++-
>  include/linux/checkpoint_hdr.h |   18 +++
>  include/linux/hugetlb.h        |   11 ++
>  include/linux/shm.h            |    8 +-
>  ipc/checkpoint_shm.c           |  154 ++++++++++++++++++++++--
>  ipc/shm.c                      |   18 ++--
>  mm/checkpoint.c                |   55 ++++++++-
>  mm/hugetlb.c                   |  257 ++++++++++++++++++++++++++++++++++++++++
>  10 files changed, 543 insertions(+), 32 deletions(-)
> 
