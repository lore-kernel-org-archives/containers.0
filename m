From: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH 0/3] Fix NFSv3 to work with network namespaces.
Date: Thu, 31 Mar 2011 02:46:44 -0500
Message-ID: <4D943164.40800__4076.56256943501$1301557672$gmane$org@parallels.com>
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

This patch series makes NFSv3 work inside an lxc container that uses a
different network namespace than the host.

The series contains three patches.  The first adds network namespace
information to the NFSv3 code under fs/nfs (copying the network context
from the mount process during options parsing, saving it with
appropriate reference counting in the persistent nfs_client struct, and
supplying it to the RPC functions).  The second and third patches add
additional network namespace information to the sunrpc code under
net/sunrpc (which already had partial support for network namespaces).

1) Add network context to struct nfs_client and make NFSv3 use it.
2) Supply network namespace to rpcbind.
3) Compare network namespace in auth_unix cache address checks.

My containers test environment setup is described at:

  http://landley.net/lxc

I exported the NFS share from the "Laptop" layer using knfsd with the
/etc/exports line:

  /home/landley/nfs 192.168.254.2(rw,no_root_squash,insecure)

And the mount command I ran in the container is:

  mount -t nfs -o nfsvers=3 10.0.2.2:/home/landley/nfs nfstest

(You don't need the -o if you haven't compiled NFSv4 support into your
kernel.)

I've tested NFSv2 and NFSv3 with UDP and TCP transports.  This series
does not address using NFSv4, pNFS, or knfsd from container context.
I haven't fixed lockd or kerberos authentication yet.
