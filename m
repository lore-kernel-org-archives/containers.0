From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 7/7] [RFC] Example multi-bindable subsystem: a per-cgroup
	notes field
Date: Tue, 17 Mar 2009 14:46:51 +0800
Message-ID: <49BF475B.1070300@cn.fujitsu.com>
References: <20090312104507.24154.71691.stgit@menage.corp.google.com>
	<20090312105153.24154.29389.stgit@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090312105153.24154.29389.stgit-B63HFAS8fGlSzHKm+aFRNNkmqwFzkYv6@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> [RFC] Example multi-bindable subsystem: a per-cgroup notes field
> 
> As an example of a multiply-bindable subsystem, this patch introduces
> the "info" subsystem, which provides a single file, "info.notes", in
> which user-space middleware can store an arbitrary (up to one page)
> string representing configuration data about that cgroup. This reduces
> the need to keep additional state outside the cgroup filesystem.
> 
> TODO: a single page is somewhat limiting - the file limit should be
> userspace-configurable, and the system should store large notes in a
> vector of pages (to avoid trying to kmalloc() an excessively large
> chunk of memory. (Or maybe just use vmalloc())
> 

add info.size, and the size will default to PAGESIZE but is changable?

> Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 

> +config CGROUP_INFO
> +	bool "Simple application-specific info cgroup subsystem

"..."

> +	help
> +	  Provides a simple cgroups subsystem with an "info.notes"
> +	  field, which can be used by middleware to store
> +	  application-specific configuration data about a cgroup. Can
> +	  be mounted on multiple hierarchies at once.
> +
