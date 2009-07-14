From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 1/3] Adds a read-only "procs" file similar to "tasks"
	that shows only unique tgids
Date: Tue, 14 Jul 2009 11:34:30 -0700
Message-ID: <1247596470.13426.16088.camel@nimitz>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 2009-07-10 at 16:01 -0700, Ben Blum wrote:
> +struct cgroup_pidlist {
> +       /* protects the other fields */
> +       struct rw_semaphore mutex;
> +       /* array of xids */
> +       pid_t *list;
> +       /* how many elements the above list has */
> +       int length;
> +       /* how many files are using the current array */
> +       int use_count;
> +};

I think a slightly nicer way of doing this would be to use a structure
like this:

#define NR_PIDS (PAGE_SIZE-sizeof(struct list_head))
struct pid_list {
	struct list_head list;
	pid_t pids[NR_PIDS];
};

That way, you can always kmalloc(sizeof(pid_list)), it fits nicely in
PAGE_SIZE, and you can chain them together.

Or, you could always just use one of the other flexible structures in
the kernel like a radix_tree.

-- Dave
