From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] Fix restoring pipes with full buffers
Date: Sat, 29 Jan 2011 00:38:16 -0500
Message-ID: <4D43A7C8.6010403@cs.columbia.edu>
References: <1296240311-5050-1-git-send-email-danms@us.ibm.com>
	<20110128230822.GE16432@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110128230822.GE16432-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org



On 01/28/2011 06:08 PM, Matt Helsley wrote:
> On Fri, Jan 28, 2011 at 10:45:11AM -0800, Dan Smith wrote:
>> While this fixes restoring pipes that were completely full, it actually
>> corrects a potential issue with restoring any pipe buffers.  By using
>> splice() to do this work when we are reading the image from another pipe,
>> we depend on userspace setting up the buffers in the pipe perfectly
>> such that the data to be restored is oriented in the pipe in the same
>> way as it is expected (or required) to be in the restored pipe.  The
>> "full" case is the hardest to get right, but userspace could break things
>> if it loaded up the inbound pipe with lots of small buffers which would
>> cause splice() to hit the PIPE_BUFFERS limit before having read the
>> requested amount of data.
>>
>> Instead, drop the optimization and just read() and write() data into
>> the pipe.
> 
> Looks good:
> 
> Reviewed-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> 
> While it seems like it should be possible to modify splice internals to
> handle this Oren's checkpoint/restart tree doesn't seem like the right
> place to attempt that work.
> 
>>
>> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>> ---
>>  fs/pipe.c |   49 ++++++++++++++++++++++++++++++++++++++++++++++---
>>  1 files changed, 46 insertions(+), 3 deletions(-)
>>
>> diff --git a/fs/pipe.c b/fs/pipe.c
>> index 9664e4f..0da1e3a 100644
>> --- a/fs/pipe.c
>> +++ b/fs/pipe.c
>> @@ -926,17 +926,60 @@ static int pipe_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
>>  	return ret;
>>  }
>>
>> +static int restore_pipe_buffer(struct ckpt_ctx *ctx,
>> +			       struct file *dest,
>> +			       int len)
>> +{
>> +	char *buf;
>> +	int ret;
>> +	int nread;
>> +	int nwrote;
>> +	int nleft = len;
>> +
>> +	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
>> +	if (!buf)
>> +		return -ENOMEM;
>> +
>> +	for (nleft = len; nleft > 0; nleft -= nread) {
>> +		int size = nleft < PAGE_SIZE ? nleft : PAGE_SIZE;
>> +		loff_t pos;
>> +
>> +		pos = file_pos_read(ctx->file);
>> +		nread = kernel_read(ctx->file, pos, buf, size);
>> +		if (nread < 0) {
>> +			ret = nread;
>> +			goto out;
>> +		}
>> +		file_pos_write(ctx->file, pos + nread);
>> +
>> +		pos = file_pos_read(dest);
>> +		nwrote = kernel_write(dest, pos, buf, nread);

Actually, this is wrong: it works if checkpoint first found the
write-end and then the read-end; but the opposite case fails 
because the code will try to write to the read-end file. (It did
work before because we used the pipe directly).

>> +		if (nwrote < 0) {
>> +			ret = nwrote;
>> +			goto out;
>> +		}
>> +		file_pos_write(dest, pos + nwrote);
>> +
>> +		if (nwrote != nread) {
>> +			ret = -EPIPE;
>> +			goto out;
>> +		}
>> +	}
>> +	ret = len;
>> + out:
>> +	kfree(buf);
>> +	return ret;
>> +}
> 
> Could you make this more generic and just take a source struct file *
> as a parameter too (instead of the struct ckpt_ctx *)? Perhaps rename it
> copy_pipe_to_pipe(src_file, dest_file, len) or some such? Seems like a
> helper like this should already exist somewhere...

Yes - like ckpt_write, and _ckpt_write()...

Oren.
