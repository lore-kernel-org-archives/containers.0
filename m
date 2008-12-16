From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [RFC v11][PATCH 03/13] General infrastructure for checkpoint
	restart
Date: Tue, 16 Dec 2008 11:28:39 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0812161116380.14014__32105.4437118166$1229455886$gmane$org@localhost.localdomain>
References: <1228498282-11804-1-git-send-email-orenl@cs.columbia.edu>
	<1228498282-11804-4-git-send-email-orenl@cs.columbia.edu>
	<4947FBC8.2000601@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4947FBC8.2000601-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org



On Tue, 16 Dec 2008, Mike Waychison wrote:
> 
> set_fs(fs) here

Btw, this all is an excellent example of why people should try to aim for 
small functions and use lots of them.

It's often _way_ more readable to do

	static inline int __some_fn(...)
	{
		.. do the real work here ..
	}

	int some_fn(...)
	{
		int retval;

		prepare();
		retval = __some_fn(..)
		finish();

		return retval;
	}

where "prepare/finish" can be about locking, or set_fs(), or allocation 
and de-allocation of temporary buffers, or any number of things like that.

With set_fs() in particular, the wrapper function also tends to be the 
perfect place to change a regular (kernel) pointer into a user pointer. 
IOW, it's the place to make sparse happy, where you can do things like

	uptr = (__force void __user *)ptr;

and comment on the fact that the forced user pointer cast is valid only 
because of the set_fs().

Because it looks like the code isn't sparse-clean.

Btw, I also think that code like this is bogus:

	nwrite = file->f_op->write(file, addr, nleft, &file->f_pos);

because you're not supposed to pass in the raw file->f_pos to that 
function. It's fundamentally thread-unsafe. I realize that maybe you don't 
care, but the thing is, you're supposed to do

	loff_t pos = file->pos;
	..
	nwrite = file->f_op->write(file, addr, nleft, &pos);
	..
	file->f_pos = pos;

and in fact preferably use "file_pos_read()" and "file_pos_write()" (but 
we've never exposed them outside of fs/read_write.c, so I guess we should 
do that).

And yes, I realize that some code does take the address of f_pos directly 
(splice, nfsctl, others), and I realize that it works, but it's still bad 
form. Please don't add more of them.

			Linus
