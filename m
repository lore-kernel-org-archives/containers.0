From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v3][PATCH 8/9] File descriprtors (dump)
Date: Thu, 04 Sep 2008 10:43:51 -0400
Message-ID: <48BFF427.7040305__2188.59911333329$1220539735$gmane$org@cs.columbia.edu>
References: <Pine.LNX.4.64.0809040354440.460@takamine.ncl.cs.columbia.edu>
	<Pine.LNX.4.64.0809040405250.5982@takamine.ncl.cs.columbia.edu>
	<20080904094740.GY14473@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080904094740.GY14473-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org



Louis Rilling wrote:
> On Thu, Sep 04, 2008 at 04:05:50AM -0400, Oren Laadan wrote:
>> Dump the files_struct of a task with 'struct cr_hdr_files', followed by
>> all open file descriptors. Since FDs can be shared, they are assigned a
>> tag and registered in the object hash.
>>
>> For each open FD there is a 'struct cr_hdr_fd_ent' with the FD, its tag
>> and its close-on-exec property. If the FD is to be saved (first time)
>> then this is followed by a 'struct cr_hdr_fd_data' with the FD state.
>> Then will come the next FD and so on.
>>
>> This patch only handles basic FDs - regular files, directories and also
>> symbolic links.
>>
> 
> [...]
> 
>> diff --git a/checkpoint/ckpt_file.c b/checkpoint/ckpt_file.c
>> new file mode 100644
>> index 0000000..34df371
>> --- /dev/null
>> +++ b/checkpoint/ckpt_file.c
>> @@ -0,0 +1,224 @@
>> +/*
>> + *  Checkpoint file descriptors
>> + *
>> + *  Copyright (C) 2008 Oren Laadan
>> + *
>> + *  This file is subject to the terms and conditions of the GNU General Public
>> + *  License.  See the file COPYING in the main directory of the Linux
>> + *  distribution for more details.
>> + */
>> +
>> +#include <linux/kernel.h>
>> +#include <linux/sched.h>
>> +#include <linux/file.h>
>> +#include <linux/fdtable.h>
>> +#include <linux/ckpt.h>
>> +#include <linux/ckpt_hdr.h>
>> +
>> +#include "ckpt_file.h"
>> +
>> +#define CR_DEFAULT_FDTABLE  256
>> +
>> +/**
>> + * cr_scan_fds - scan file table and construct array of open fds
>> + * @files: files_struct pointer
>> + * @fdtable: (output) array of open fds
>> + * @return: the number of open fds found
>> + *
>> + * Allocates the file descriptors array (*fdtable), caller should free
>> + */
>> +int cr_scan_fds(struct files_struct *files, int **fdtable)
>> +{
>> +	struct fdtable *fdt;
>> +	int *fdlist;
>> +	int i, n, max;
>> +
>> +	max = CR_DEFAULT_FDTABLE;
>> +
>> + repeat:
>> +	n = 0;
>> +	fdlist = kmalloc(max * sizeof(*fdlist), GFP_KERNEL);
>> +	if (!fdlist)
>> +		return -ENOMEM;
>> +
>> +	spin_lock(&files->file_lock);
>> +	fdt = files_fdtable(files);
>> +	for (i = 0; i < fdt->max_fds; i++) {
>> +		if (fcheck_files(files, i)) {
>> +			if (n == max) {
>> +				spin_unlock(&files->file_lock);
>> +				kfree(fdlist);
>> +				max *= 2;
>> +				if (max < 0) {	/* overflow ? */
>> +					n = -EMFILE;
>> +					break;
>> +				}
>> +				goto repeat;
> 
> 				fdlist = krealloc(fdlist, max, GFP_KERNEL)?
> 
> Sorry, I should have suggested this in my first review.

That's a good point; I did it this way to be paranoid, even though the
the checkpointee is supposed to be frozen (e.g., if the checkpointee is
forcefully killed by, say, OOM, and it's fdt->max_fds goes to zero. But
now I notice that check_files() already tests for this. I'm not sure it
makes the code simpler, but I'll fix that.

Oren.

> 
> Louis
> 
>> +			}
>> +			fdlist[n++] = i;
>> +		}
>> +	}
>> +	spin_unlock(&files->file_lock);
>> +
>> +	*fdtable = fdlist;
>> +	return n;
>> +}
>> +
> 
