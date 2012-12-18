From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [GIT PULL] user namespace and namespace infrastructure changes
	for 3.8
Date: Mon, 17 Dec 2012 23:47:26 -0800
Message-ID: <87d2y7dcoh.fsf@xmission.com>
References: <87wqwggtcu.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87wqwggtcu.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Mon, 17 Dec 2012 15:18:57 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman) writes:

> Linus,
>
> Please pull the for-linus git tree from:
>
>    git://git.kernel.org:/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus
>
>    HEAD: 5155040ed349950e16c093ba8e65ad534994df2a userns: Fix typo in description of the limitation of userns_install
>
>    This tree is against v3.7-rc3
>
> The embarrasing oversights that Andy found have been corrected.

Those bugs, those darn embarrasing bugs just want don't want to get
fixed.

Linus I just updated my mirror of your kernel.org tree and it appears
you successfully pulled everything except the last 4 commits that fix
those embarrasing bugs.

When you get a chance can you please repull my branch (the details
above are still corect.

The pending changes are.

Eric W. Biederman (4):
      Fix cap_capable to only allow owners in the parent user namespace to have caps.
      userns: Require CAP_SYS_ADMIN for most uses of setns.
      userns: Add a more complete capability subset test to commit_creds
      userns: Fix typo in description of the limitation of userns_install

 fs/namespace.c           |    3 ++-
 ipc/namespace.c          |    3 ++-
 kernel/cred.c            |   27 ++++++++++++++++++++++++++-
 kernel/pid_namespace.c   |    3 ++-
 kernel/user_namespace.c  |    2 +-
 kernel/utsname.c         |    3 ++-
 net/core/net_namespace.c |    3 ++-
 security/commoncap.c     |   25 +++++++++++++++++--------
 8 files changed, 54 insertions(+), 15 deletions(-)

Eric
