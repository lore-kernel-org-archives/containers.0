From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: [GIT PULL] binfmt_misc updates for 4.7+ merge window
Date: Wed, 27 Jul 2016 22:31:46 -0400
Message-ID: <1469673106.3565.9.camel@HansenPartnership.com>
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
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

First off, the intention of this pull is to declare that I'll be the
binfmt_misc maintainer (mainly on the grounds of you touched it last,
it's yours).  There's no MAINTAINERS entry, but get_maintainers.pl will
now finger me.

The update itself is to allow architecture emulation containers to
function such that the emulation binary can be housed outside the
container itself.  The container and fs parts both have acks from
relevant experts.

The change is user visible. To use the new feature you have to add an F
option to your binfmt_misc configuration.  However, the existing tools,
like systemd-binfmt work with this without modification.

It's also all been incubated in linux-next for over a month.

The update is available here:

git://git.kernel.org/pub/scm/linux/kernel/git/jejb/binfmt_misc.git binfmt-for-linus

The short changelog is:

James Bottomley (3):
      binfmt_misc: add F option description to documentation
      binfmt_misc: add persistent opened binary handler for containers
      fs: add filp_clone_open API

And the diffstat:

 Documentation/binfmt_misc.txt |  7 +++++++
 fs/binfmt_misc.c              | 41 +++++++++++++++++++++++++++++++++++++++--
 fs/internal.h                 |  1 +
 fs/open.c                     | 20 ++++++++++++++++++++
 4 files changed, 67 insertions(+), 2 deletions(-)

James
