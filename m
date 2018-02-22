From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v6 1/5] fuse: Remove the buggy retranslation of pids in
	fuse_dev_do_read
Date: Thu, 22 Feb 2018 13:04:32 -0600
Message-ID: <87fu5s7sn3.fsf@xmission.com>
References: <878tbmf5vl.fsf@xmission.com>
	<20180221202908.17258-1-ebiederm@xmission.com>
	<CAOssrKch20vj8phkjfjMe=07-8uQiuXfOuCTDjrMzPbkg6DoxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAOssrKch20vj8phkjfjMe=07-8uQiuXfOuCTDjrMzPbkg6DoxA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Miklos Szeredi's message of "Thu, 22 Feb 2018 11:13:36 +0100")
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
>> At the point of fuse_dev_do_read the user space process that initiated the
>> action on the fuse filesystem may no longer exist.  The process have been
>> killed or may have fired an asynchronous request and exited.
>>
>> If the initial process has exited the code "pid_vnr(find_pid_ns(in->h.pid,
>> fc->pid_ns)" will either return a pid of 0, or in the unlikely event that
>> the pid has been reallocated it can return practically any pid.  Any pid is
>> possible as the pid allocator allocates pid numbers in different pid
>> namespaces independently.
>>
>> The only way to make translation in fuse_dev_do_read reliable is to call
>> get_pid in fuse_req_init_context, and pid_vnr followed by put_pid in
>> fuse_dev_do_read.  That reference counting in other contexts has been shown
>> to bounce cache lines between processors and in general be slow.  So that is
>> not desirable.
>>
>> The only known user of running the fuse server in a different pid namespace
>> from the filesystem does not care what the pids are in the fuse messages
>> so removing this code should not matter.
>
> Shouldn't we at least zero out the pid in that case?

This is an explicit case of passing a file descriptor between pid
namespaces.  So I think there are plenty of buyer be ware signs out.
So I don't know if there are any real world advantages of zeroing the
pid.

I can see a case for using the pid namespace of the opener of /dev/fuse
instead of the pid namespace of the mounter of the fuse filesystem.
Although in practice I would be surprised if they were different.

I am very leary about caring during a read operation.  Caring about the
current processes during read/write tends to break caching, is error prone
as the need for this patch demonstrates, and is generally likely to be
slower than not caring.

So yes we can zero the pid.   I don't think it is wise to zero the pid
unless we zero the pid in fuse_req_init_context.

Eric
