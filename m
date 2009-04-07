From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v14-rc2][PATCH 06/29] Dump memory address space
Date: Tue, 07 Apr 2009 00:57:44 -0400
Message-ID: <49DADD48.1010100@cs.columbia.edu>
References: <1238477349-11029-1-git-send-email-orenl@cs.columbia.edu>
	<1238477349-11029-7-git-send-email-orenl@cs.columbia.edu>
	<20090407032636.GD12316@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090407032636.GD12316-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org



Sukadev Bhattiprolu wrote:
> One comment below.

Thanks .. (and the other reviews as well - I fixed all of them)

[...]

> | +static char *
> | +cr_fill_fname(struct path *path, struct path *root, char *buf, int *n)
> | +{
> | +	struct path tmp = *root;
> | +	char *fname;
> | +
> | +	BUG_ON(!buf);
> | +	spin_lock(&dcache_lock);
> | +	fname = __d_path(path, &tmp, buf, *n);
> | +	spin_unlock(&dcache_lock);
> | +	if (!IS_ERR(fname))
> | +		*n = (buf + (*n) - fname);
> | +	/*
> | +	 * FIXME: if __d_path() changed these, it must have stepped out of
> | +	 * init's namespace. Since currently we require a unified namespace
> | +	 * within the container: simply fail.
> | +	 */
> | +	if (tmp.mnt != root->mnt || tmp.dentry != root->dentry)
> | +		fname = ERR_PTR(-EBADF);
> | 
> 
> Shouldn't this be under if (!IS_ERR(fname)) ? 'tmp' may be uninitialized
> if __d_path() fails with ENAMETOOLONG. Even otherwise, it may be better
> to report the error from __dpath() first ?
> 

True, fixed.

Oren.
