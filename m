From: Bastian Blank <bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org>
Subject: Re: [RFC v5][PATCH 8/8] Dump open file descriptors
Date: Sun, 14 Sep 2008 11:51:06 +0200
Message-ID: <20080914095106.GA6300__4158.41291328451$1221386014$gmane$org@wavehammer.waldi.eu.org>
References: <1221347167-9956-1-git-send-email-orenl@cs.columbia.edu>
	<1221347167-9956-9-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1221347167-9956-9-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat, Sep 13, 2008 at 07:06:06PM -0400, Oren Laadan wrote:
> +int cr_scan_fds(struct files_struct *files, int **fdtable)
> +{
> +	struct fdtable *fdt;
> +	int *fds;
> +	int i, n, tot;
> +
> +	n = 0;
> +	tot = CR_DEFAULT_FDTABLE;

Why not?
| int i;
| int n = 0;
| int tot = CR_DEFAULT_FDTABLE;

IHMO easier readable.

> +	spin_lock(&files->file_lock);
> +	fdt = files_fdtable(files);
> +	for (i = 0; i < fdt->max_fds; i++) {

The process is suspended at this state?

> +		if (n == tot) {
> +			/*
> +			 * fcheck_files() is safe with drop/re-acquire
> +			 * of the lock, because it tests:  fd < max_fds
> +			 */
> +			spin_unlock(&files->file_lock);
> +			tot *= 2;
> +			if (tot < 0) {		/* overflow ? */

_NO_. tot is signed, this does not have documented overflow behaviour.
You need to restrict this to a sane number.

> +				kfree(fds);
> +				return -EMFILE;
> +			}
> +			fds = krealloc(fds, tot * sizeof(*fds), GFP_KERNEL);
> +			if (!fds)

krealloc does not free the memory on error, so this is a leak.

Bastian

-- 
The more complex the mind, the greater the need for the simplicity of play.
		-- Kirk, "Shore Leave", stardate 3025.8
