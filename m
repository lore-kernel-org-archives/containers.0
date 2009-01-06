From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC][PATCH 0/4] utsns: RPC/NFS bug rework
Date: Mon, 05 Jan 2009 17:13:14 -0800
Message-ID: <20090106011314.534653345__25782.4791050099$1231204824$gmane$org@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

This series replaces the workaround for a bug reported by Cedric Le Goater 
<clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> back in September:

> On a system with nfs mounts, if a task unshares its mount namespace,
> a oops can occur when the system is rebooted if the task is the last
> to unreference the nfs mount. It will try to create a rpc request
> using utsname() which has been invalidated by free_nsproxy().

Cedric worked around this bug by always using the initial uts namespace's
nodename (see commit: 63ffc23d307c9534c732edd87895e37b223004a3).

This is a non-ideal solution because uts namespace nodenames are reported
as the hostname during RPC authentication. Consider a machine configured
to export directories via NFS from a parent container to designated "trusted"
child containers. It would be unable to rely on the hostname during RPC
authentication -- forcing the administration of more advanced authentication
systems than might otherwise be necessary.

The goal of this series is to report a namespace's UTS nodename rather than 
the initial UTS namespace's nodename during RPC-call authentication -- much as
before Cedric's workaround. By changing the way that the nodename is cached and
fetched we can simultaneously avoid the NULL dereference during shutdown and
ensure that amalgamated RPC services (such as statd, lockd, mountd for NFS) see
a consistent nodename.

Cheers,
	-Matt Helsley

-- 
