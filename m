From: Stefan Berger <"Stefan Bergerstefanb"@linux.vnet.ibm.com>
Subject: [PATCH v2] Enable namespaced file capabilities
Date: Tue, 11 Jul 2017 11:05:10 -0400
Message-ID: <1499785511-17192-1-git-send-email-stefanb@linux.vnet.ibm.com>
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
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: lkp-JC7UmRfGjtg@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

From: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

The primary goal of the following patch is to enable file capabilities
in user namespaces without affecting the file capabilities that are
effective on the host. This is to prevent that any unprivileged user
on the host maps his own uid to root in a private namespace, writes
the xattr, and executes the file with privilege on the host.

We achieve this goal by writing extended attributes with a different
name when a user namespace is used. If for example the root user
in a user namespace writes the security.capability xattr, the name
of the xattr that is actually written is encoded as
security.capability@uid=1000 for root mapped to uid 1000 on the host.
When listing the xattrs on the host, the existing security.capability
as well as the security.capability@uid=1000 will be shown. Inside the
namespace only 'security.capability', with the value of
security.capability@uid=1000, is visible.

To maintain compatibility with existing behavior, the value of
security.capability of the host is shown inside the user namespace
once the security.capability of the user namespace has been removed
(which really removes security.capability@uid=1000). Writing to
an extended attribute inside a user namespace effectively hides the
extended attribute of the host.

The general framework that is established with these patches can
be applied to other extended attributes as well, such as security.ima
or the 'trusted.' prefix.

Regards,
   Stefan & Serge

---
 v1->v2:
  - removed patch 3 related to security.selinux; no other xattr than
    security.capability is touched
  - reordered call to xattr_userns_name() to be before call to
    xattr_resolve_name() since the string passed into the handler must
    contain the full xattr name so that xattr_full_name() still works
    properly since only the xattr's suffix is passed to the handler
    function but xattr_resolve_name() may be called from that handler

Stefan Berger (1):
  xattr: Enable security.capability in user namespaces

 fs/xattr.c               | 509 +++++++++++++++++++++++++++++++++++++++++++++--
 security/commoncap.c     |  36 +++-
 security/selinux/hooks.c |   9 +-
 3 files changed, 523 insertions(+), 31 deletions(-)

-- 
2.7.4
