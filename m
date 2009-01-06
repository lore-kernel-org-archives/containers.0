From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC][PATCH 2/4] sunrpc: Use utsnamespaces
Date: Mon, 05 Jan 2009 17:13:16 -0800
Message-ID: <20090106011314.961946803@us.ibm.com>
References: <20090106011314.534653345@us.ibm.com>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=reenable-uts-ns-for-most-rpc-clients.patch
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

We can often specify the UTS namespace to use when starting an RPC client.
However sometimes no UTS namespace is available (specifically during system
shutdown as the last NFS mount in a container is unmounted) so fall
back to the initial UTS namespace.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>
Cc: Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>

---
 net/sunrpc/clnt.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

Index: linux-2.6.28/net/sunrpc/clnt.c
===================================================================
--- linux-2.6.28.orig/net/sunrpc/clnt.c
+++ linux-2.6.28/net/sunrpc/clnt.c
@@ -128,6 +128,7 @@ static struct rpc_clnt * rpc_new_client(
 	struct rpc_version	*version;
 	struct rpc_clnt		*clnt = NULL;
 	struct rpc_auth		*auth;
+	struct new_utsname	*uts_ns = init_utsname();
 	int err;
 	size_t len;
 
@@ -213,10 +214,12 @@ static struct rpc_clnt * rpc_new_client(
 	}
 
 	/* save the nodename */
-	clnt->cl_nodelen = strlen(init_utsname()->nodename);
+	if (current->nsproxy != NULL)
+		uts_ns = utsname();
+	clnt->cl_nodelen = strlen(uts_ns->nodename);
 	if (clnt->cl_nodelen > UNX_MAXNODENAME)
 		clnt->cl_nodelen = UNX_MAXNODENAME;
-	memcpy(clnt->cl_nodename, init_utsname()->nodename, clnt->cl_nodelen);
+	memcpy(clnt->cl_nodename, uts_ns->nodename, clnt->cl_nodelen);
 	rpc_register_client(clnt);
 	return clnt;
 

-- 
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
