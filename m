From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v9][PATCH 05/13] Dump memory address space
Date: Mon, 10 Nov 2008 15:34:37 -0500
Message-ID: <49189ADD.7030607__40740.4042584405$1226349550$gmane$org@cs.columbia.edu>
References: <1226335060-7061-1-git-send-email-orenl@cs.columbia.edu>
	<1226335060-7061-6-git-send-email-orenl@cs.columbia.edu>
	<20081110201251.GA7471@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081110201251.GA7471-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linus Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>> +/**
>> + * cr_fill_fname - return pathname of a given file
>> + * @path: path name
>> + * @root: relative root
>> + * @buf: buffer for pathname
>> + * @n: buffer length (in) and pathname length (out)
>> + */
>> +static char *
>> +cr_fill_fname(struct path *path, struct path *root, char *buf, int *n)
>> +{
>> +	struct path tmp = *root;
>> +	char *fname;
>> +
>> +	BUG_ON(!buf);
>> +	fname = __d_path(path, &tmp, buf, *n);
>> +	if (!IS_ERR(fname))
>> +		*n = (buf + (*n) - fname);
>> +	/*
>> +	 * FIXME: if __d_path() changed these, it must have stepped out of
>> +	 * init's namespace. Since currently we require a unified namespace
>> +	 * within the container: simply fail.
>> +	 */
>> +	if (tmp.mnt != root->mnt || tmp.dentry != root->dentry)
>> +		fname = ERR_PTR(-EBADF);
>> +
>> +	return fname;
>> +}
> 
> You still are not taking the dcache_lock around __d_path.
> 

You still are right.

Oren.
