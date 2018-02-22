From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v6 2/5] fuse: Fail all requests with invalid uids or gids
Date: Thu, 22 Feb 2018 12:15:00 -0600
Message-ID: <87eflc99i3.fsf@xmission.com>
References: <878tbmf5vl.fsf@xmission.com>
	<20180221202908.17258-2-ebiederm@xmission.com>
	<CAOssrKeYuVj6ZWUrXp7R_d+wdoArnJ=mhRp22qE9JBW3x-7tfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAOssrKeYuVj6ZWUrXp7R_d+wdoArnJ=mhRp22qE9JBW3x-7tfw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Miklos Szeredi's message of "Thu, 22 Feb 2018 11:26:22 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> On Wed, Feb 21, 2018 at 9:29 PM, Eric W. Biederman
> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>> Upon a cursory examinination the uid and gid of a fuse request are
>> necessary for correct operation.  Failing a fuse request where those
>> values are not reliable seems a straight forward and reliable means of
>> ensuring that fuse requests with bad data are not sent or processed.
>>
>> In most cases the vfs will avoid actions it suspects will cause
>> an inode write back of an inode with an invalid uid or gid.  But that does
>> not map precisely to what fuse is doing, so test for this and solve
>> this at the fuse level as well.
>>
>> Performing this work in fuse_req_init_context is cheap as the code is
>> already performing the translation here and only needs to check the
>> result of the translation to see if things are not representable in
>> a form the fuse server can handle.
>>
>> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> ---
>>  fs/fuse/dev.c | 20 +++++++++++++-------
>>  1 file changed, 13 insertions(+), 7 deletions(-)
>>
>> diff --git a/fs/fuse/dev.c b/fs/fuse/dev.c
>> index 0fb58f364fa6..216db3f51a31 100644
>> --- a/fs/fuse/dev.c
>> +++ b/fs/fuse/dev.c
>> @@ -112,11 +112,13 @@ static void __fuse_put_request(struct fuse_req *req)
>>         refcount_dec(&req->count);
>>  }
>>
>> -static void fuse_req_init_context(struct fuse_conn *fc, struct fuse_req *req)
>> +static bool fuse_req_init_context(struct fuse_conn *fc, struct fuse_req *req)
>>  {
>> -       req->in.h.uid = from_kuid_munged(&init_user_ns, current_fsuid());
>> -       req->in.h.gid = from_kgid_munged(&init_user_ns, current_fsgid());
>> +       req->in.h.uid = from_kuid(&init_user_ns, current_fsuid());
>> +       req->in.h.gid = from_kgid(&init_user_ns, current_fsgid());
>>         req->in.h.pid = pid_nr_ns(task_pid(current), fc->pid_ns);
>> +
>> +       return (req->in.h.uid != ((uid_t)-1)) && (req->in.h.gid != ((gid_t)-1));
>>  }
>>
>>  void fuse_set_initialized(struct fuse_conn *fc)
>> @@ -162,12 +164,13 @@ static struct fuse_req *__fuse_get_req(struct fuse_conn *fc, unsigned npages,
>>                         wake_up(&fc->blocked_waitq);
>>                 goto out;
>>         }
>> -
>> -       fuse_req_init_context(fc, req);
>>         __set_bit(FR_WAITING, &req->flags);
>>         if (for_background)
>>                 __set_bit(FR_BACKGROUND, &req->flags);
>> -
>> +       if (unlikely(!fuse_req_init_context(fc, req))) {
>> +               fuse_put_request(fc, req);
>> +               return ERR_PTR(-EOVERFLOW);
>> +       }
>>         return req;
>>
>>   out:
>> @@ -256,9 +259,12 @@ struct fuse_req *fuse_get_req_nofail_nopages(struct fuse_conn *fc,
>>         if (!req)
>>                 req = get_reserved_req(fc, file);
>>
>> -       fuse_req_init_context(fc, req);
>>         __set_bit(FR_WAITING, &req->flags);
>>         __clear_bit(FR_BACKGROUND, &req->flags);
>> +       if (unlikely(!fuse_req_init_context(fc, req))) {
>> +               fuse_put_request(fc, req);
>> +               return ERR_PTR(-EOVERFLOW);
>> +       }
>
> I think failing the "_nofail" variant is the wrong thing to do.  This
> is called to allocate a FLUSH request on close() and in readdirplus to
> allocate a FORGET request.  Failing the latter results in refcount
> leak in userspace.   Failing the former results in missing unlock on
> close() of posix locks.

Doh!  You are quite correct.

Modifying fuse_get_req_nofail_nopages to fail is a bug.

I am thinking the proper solution is to write:

    static void fuse_req_init_context_nofail(struct fuse_req *req)
    {
            req->in.h.uid = 0;
            req->in.h.gid = 0;
            req->in.h.pid = 0;
    }

And use that in the nofail case.  As it appears neither flush nor
the eviction of inodes is a user space triggered action and as such
user space identifiers are nonsense in those cases.

I will respin this patch shortly.

Eric
