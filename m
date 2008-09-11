From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v4][PATCH 8/9] File descriprtors (dump)
Date: Thu, 11 Sep 2008 02:37:00 -0400
Message-ID: <48C8BC8C.8080704__23499.2152466022$1221115233$gmane$org@cs.columbia.edu>
References: <1220946154-15174-1-git-send-email-orenl@cs.columbia.edu>	
	<1220946154-15174-9-git-send-email-orenl@cs.columbia.edu>
	<28c262360809102202t73c12a09uc6edd5ce93ce36d3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <28c262360809102202t73c12a09uc6edd5ce93ce36d3-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: MinChan Kim <minchan.kim-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org



MinChan Kim wrote:
> On Tue, Sep 9, 2008 at 4:42 PM, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> wrote:

[...]

>> +#define CR_DEFAULT_FDTABLE  256                /* an initial guess */
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
>> +       struct fdtable *fdt;
>> +       int *fdlist;
>> +       int i, n, max;
>> +
>> +       n = 0;
>> +       max = CR_DEFAULT_FDTABLE;
> 
> max is read-only variable so that you don't need to declare local variable.
> You can use macro.

It's actually used below - track size in case of krealloc()

> 
>> +       fdlist = kmalloc(max * sizeof(*fdlist), GFP_KERNEL);
>> +       if (!fdlist)
>> +               return -ENOMEM;
>> +
>> +       spin_lock(&files->file_lock);
>> +       fdt = files_fdtable(files);
>> +       for (i = 0; i < fdt->max_fds; i++) {
>> +               if (!fcheck_files(files, i))
>> +                       continue;
>> +               if (n == max) {
>> +                       /* fcheck_files() is safe with drop/re-acquire
>> +                        * of the lock, as it tests:  fd < max_fds */
>> +                       spin_unlock(&files->file_lock);
>> +                       max *= 2;
>> +                       if (max < 0) {  /* overflow ? */
>> +                               n = -EMFILE;
>> +                               goto out;
>> +                       }
>> +                       fdlist = krealloc(fdlist, max, GFP_KERNEL);
>> +                       if (!fdlist) {
>> +                               n = -ENOMEM;
>> +                               goto out;
>> +                       }
>> +                       spin_lock(&files->file_lock);
>> +               }
>> +               fdlist[n++] = i;
>> +       }
>> +       spin_unlock(&files->file_lock);
>> +
>> +       *fdtable = fdlist;
>> + out:
>> +       return n;
>> +}

[...]

>> +int cr_write_files(struct cr_ctx *ctx, struct task_struct *t)
>> +{
>> +       struct cr_hdr h;
>> +       struct cr_hdr_files *hh = cr_hbuf_get(ctx, sizeof(*hh));
>> +       struct files_struct *files;
>> +       int *fdtable;
>> +       int nfds, n, ret;
>> +
>> +       h.type = CR_HDR_FILES;
>> +       h.len = sizeof(*hh);
>> +       h.parent = task_pid_vnr(t);
>> +
>> +       files = get_files_struct(t);
>> +
>> +       hh->objref = 0; /* will be meaningful with multiple processes */
>> +
>> +       nfds = cr_scan_fds(files, &fdtable);
>> +       if (nfds < 0) {
>> +               ret = nfds;
>> +               goto out;
>> +       }
>> +
>> +       hh->nfds = nfds;
>> +
>> +       ret = cr_write_obj(ctx, &h, hh);
>> +       cr_hbuf_put(ctx, sizeof(*hh));
>> +       if (ret < 0)
>> +               goto clean;
>> +
>> +       cr_debug("nfds %d\n", nfds);
>> +       for (n = 0; n < nfds; n++) {
>> +               ret = cr_write_fd_ent(ctx, files, n);
> 
> I think your intention is not 'n' but 'fdtable[n]' in argument.

Oops ... yes. Thanks.

[...]

Oren.
