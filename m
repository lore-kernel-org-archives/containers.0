From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v14-rc][PATCH 14/23] A new file type (CR_FD_OBJREF) for
	a	file descriptor already setup
Date: Fri, 20 Mar 2009 17:02:41 -0400
Message-ID: <49C40471.4090407@cs.columbia.edu>
References: <1237574868-3371-1-git-send-email-orenl@cs.columbia.edu>	
	<1237574868-3371-15-git-send-email-orenl@cs.columbia.edu>
	<1237579888.8286.244.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1237579888.8286.244.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



Dave Hansen wrote:
> On Fri, 2009-03-20 at 14:47 -0400, Oren Laadan wrote:
>>
>> +/* cr_write_fd_file - for regular files, directories, symbolic links
>> */
>> +static int cr_write_fd_file(struct cr_ctx *ctx, struct file *file)
>> +{
>> +       return cr_write_fname(ctx, &file->f_path, &ctx->fs_mnt);
>> +}
>> +
>> +/* cr_inode_to_fdtype - determine the fd type given an inode */
>> +static inline enum fd_type cr_inode_to_fdtype(struct inode *inode)
>> +{
>> +       switch (inode->i_mode & S_IFMT) {
>> +       case S_IFREG:
>> +               return CR_FD_FILE;
>> +       case S_IFDIR:
>> +               return CR_FD_DIR;
>> +       }
>> +       /* file type unsupported */
>> +       return -EBADF;
>> +}
> 
> These are cleanups and abstractions of a previous patch.  Please either
> put them in that patch or separate them from the CR_FD_OBJREF patch.
> They don't belong together.
> 
> -- Dave

Sounds good. Will split.

Oren.
