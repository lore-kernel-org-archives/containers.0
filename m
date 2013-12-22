From: Stefan Beller <stefanbeller-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: [PATCH 2/2] binder: implement namepsace support for Android binder
	driver
Date: Sun, 22 Dec 2013 11:38:06 +0100
Message-ID: <52B6C10E.3070002@googlemail.com>
References: <cover.1387706794.git.orenl@cellrox.com>
	<45c5d62a35f19228a681f5be9834741baabfdb0d.1387706794.git.orenl@cellrox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <45c5d62a35f19228a681f5be9834741baabfdb0d.1387706794.git.orenl-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org>, Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, =?ISO-8859-1?Q?Arve_Hj=F8nnev=E5?= =?ISO-8859-1?Q?g?= <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, lxc-devel <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org


>  #include <linux/uaccess.h>
>  #include <linux/vmalloc.h>
>  #include <linux/slab.h>
> +#include <linux/ipc_namespace.h>
>  #include <linux/pid_namespace.h>
>  
>  #include "binder.h"
>  #include "binder_trace.h"
>  
> +/*
> + * Using a private context manager for each binder namespace is sufficient
> + * to isolate between namespaces, because in binder all IPC must be realized
> + * via hanldes obtained from the context manager.

handles

> + *
> + * TODO: currently, most debugfs data is not tracked per binder namespaces.
> + * Except for "procs" which are properly virtualized, everything else is
> + * global, including stats, logs, and dead nodes.
> + */
> +struct binder_namespace {
> +	struct kref kref;
> +
> +	struct binder_node *context_mgr_node;
> +	kuid_t context_mgr_uid;
> +	int last_id;
