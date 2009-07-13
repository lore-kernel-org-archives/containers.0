From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 1/3] Adds a read-only "procs" file similar to "tasks"
	that	shows only unique tgids
Date: Mon, 13 Jul 2009 11:46:10 +0800
Message-ID: <4A5AAE02.7060106__25372.1445020803$1247456894$gmane$org@cn.fujitsu.com>
References: <20090710230043.16778.29656.stgit@hastromil.mtv.corp.google.com>
	<20090710230154.16778.58053.stgit@hastromil.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090710230154.16778.58053.stgit-/yCBOHwbXCxd3OlUiQof+WCaruZE5nAUZeezCHUQhQ4@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Ben Blum wrote:
> Adds a read-only "procs" file similar to "tasks" that shows only unique tgids
> 
> struct cgroup used to have a bunch of fields for keeping track of the pidlist
> for the tasks file. Those are now separated into a new struct cgroup_pidlist,
> of which two are had, one for procs and one for tasks. The way the seq_file
> operations are set up is changed so that just the pidlist struct gets passed
> around as the private data.
> 
> Interface example: suppose a process with tgid 1000 has additional threads
> with ids 1001 and 1002. The tasks file will show ids 1000, 1001, and 1002, and
> the procs file will only show id 1000.
> 

I think a better demonstration is:

  $ cat tasks
  1000
  1001
  1002

  $ cat procs
  1000

> Possible future functionality is making the procs file writable for purposes
> of adding all threads with the same tgid at once.
> 
> Signed-off-by: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 
> ---
> 
>  include/linux/cgroup.h |   22 ++--
>  kernel/cgroup.c        |  282 ++++++++++++++++++++++++++++++------------------
>  2 files changed, 190 insertions(+), 114 deletions(-)
...
> +/* is the size difference enough that we should re-allocate the array? */
> +#define PIDLIST_REALLOC_DIFFERENCE(old,new) ((old) - PAGE_SIZE >= (new))
> +static int pidlist_uniq(pid_t **p, int length)
> +{
> +	int src, dest = 1;
> +	pid_t *list = *p;
> +	pid_t *newlist;
> +
> +	/*
> +	 * we presume the 0th element is unique, so i starts at 1. trivial
> +	 * edge cases first; no work needs to be done for either
> +	 */
> +	if (length == 0 || length == 1)
> +		return length;
> +	/* src and dest walk down the list; dest counts unique elements */
> +	for (src = 1; src < length; src++) {
> +		/* find next unique element */
> +		while (list[src] == list[src-1]) {
> +			src++;
> +			if (src == length)
> +				break;

'goto' is better

> +		}
> +		if (src == length)
> +			break;
> +		/* dest always points to where the next unique element goes */
> +		list[dest] = list[src];
> +		dest++;
> +	}
> +	/*
> +	 * if the length difference is large enough, we want to allocate a
> +	 * smaller buffer to save memory. if this fails due to out of memory,
> +	 * we'll just stay with what we've got.
> +	 */
> +	if (PIDLIST_REALLOC_DIFFERENCE(length, dest)) {
> +		newlist = kmalloc(dest * sizeof(pid_t), GFP_KERNEL);

krealloc()

> +		if (newlist) {
> +			memcpy(newlist, list, dest * sizeof(pid_t));
> +			kfree(list);
> +			*p = newlist;
> +		}
> +	}
> +	return dest;
> +}
