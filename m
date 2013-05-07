From: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
Subject: [Suggestion] kernel/cgroup.c: about kfree after 'get_new_cssid'
Date: Tue, 07 May 2013 18:46:43 +0800
Message-ID: <5188DB93.2080504__16920.2966652394$1367924956$gmane$org@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello Maintainers:

After call get_new_cssid(), I can not find the related free function
(it seems free_css_id() is for that, but not used).

The memory location is:
  get_new_cssid() --> kzalloc() for 'struct css_id'
  get_new_cssid() --> idr_alloc() for 'ss->idr'

One work flow:
  cgroup_load_subsys() --> cgroup_init_idr() --> get_new_cssid()
  when get_new_cssid() fails, it will:
  cgroup_load_subsys() --> cgroup_unload_subsys() --> idr_destroy(),
  and also:
  cgroup_load_subsys() --> cgroup_unload_subsys() --> ss->css_free();
    ('css_free' may 'debug_css_free', or 'freezer_css_free' ...)

It seems the work flow above is not 'kfree' 'struct css_id', is it true?

BTW: I also guess, for cgroup_init_idr() in cgroup_init(), need check
the return value.

Please help check.


Thanks.

--
 Chen Gang

 Asianux Corporation
