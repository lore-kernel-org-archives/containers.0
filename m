From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [RFC v10][PATCH 08/13] Dump open file descriptors
Date: Fri, 28 Nov 2008 10:19:19 +0000
Message-ID: <20081128101919.GO28946__6444.89538758552$1227867782$gmane$org@ZenIV.linux.org.uk>
References: <1227747884-14150-1-git-send-email-orenl@cs.columbia.edu>
	<1227747884-14150-9-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1227747884-14150-9-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linus Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Nov 26, 2008 at 08:04:39PM -0500, Oren Laadan wrote:
> +int cr_scan_fds(struct files_struct *files, int **fdtable)
> +{
> +	struct fdtable *fdt;
> +	int *fds;
> +	int i, n = 0;
> +	int tot = CR_DEFAULT_FDTABLE;
> +
> +	fds = kmalloc(tot * sizeof(*fds), GFP_KERNEL);
> +	if (!fds)
> +		return -ENOMEM;
> +
> +	/*
> +	 * We assume that the target task is frozen (or that we checkpoint
> +	 * ourselves), so we can safely proceed after krealloc() from where
> +	 * we left off; in the worst cases restart will fail.
> +	 */

Task may be frozen, but it may share the table with any number of other
tasks...

> +	spin_lock(&files->file_lock);
> +	rcu_read_lock();
> +	fdt = files_fdtable(files);
> +	for (i = 0; i < fdt->max_fds; i++) {
> +		if (!fcheck_files(files, i))
> +			continue;
> +		if (n == tot) {
> +			/*
> +			 * fcheck_files() is safe with drop/re-acquire
> +			 * of the lock, because it tests:  fd < max_fds
> +			 */
> +			spin_unlock(&files->file_lock);
> +			rcu_read_unlock();
> +			tot *= 2;	/* won't overflow: kmalloc will fail */
> +			fds = krealloc(fds, tot * sizeof(*fds), GFP_KERNEL);
> +			if (!fds)
> +				return -ENOMEM;
> +			rcu_read_lock();
> +			spin_lock(&files->file_lock);
> +		}
> +		fds[n++] = i;
> +	}
> +	rcu_read_unlock();
> +	spin_unlock(&files->file_lock);
> +
> +	*fdtable = fds;
> +	return n;
> +}

> +	switch (inode->i_mode & S_IFMT) {
> +	case S_IFREG:
> +		fd_type = CR_FD_FILE;
> +		break;
> +	case S_IFDIR:
> +		fd_type = CR_FD_DIR;
> +		break;
> +	case S_IFLNK:
> +		fd_type = CR_FD_LINK;

Opened symlinks?  May I have whatever you'd been smoking, please?
