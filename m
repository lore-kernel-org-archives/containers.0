From: pravin shelar <pshelar-LZ6Gd1LRuIk@public.gmane.org>
Subject: Re: [PATCH v3] openvswitch: allow management from inside user
	namespaces
Date: Thu, 11 Feb 2016 10:10:59 +0100
Message-ID: <CAOrHB_CLkirGUf4r=0pyJppaKgbV7nm8u5guXcM=sdup2YJCnA__32720.0833395638$1455182373$gmane$org@mail.gmail.com>
References: <1454689252-18749-1-git-send-email-tycho.andersen@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1454689252-18749-1-git-send-email-tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Justin Pettit <jpettit-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Feb 5, 2016 at 5:20 PM, Tycho Andersen
<tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
> Operations with the GENL_ADMIN_PERM flag fail permissions checks because
> this flag means we call netlink_capable, which uses the init user ns.
>
> Instead, let's introduce a new flag, GENL_UNS_ADMIN_PERM for operations
> which should be allowed inside a user namespace.
>
> The motivation for this is to be able to run openvswitch in unprivileged
> containers. I've tested this and it seems to work, but I really have no
> idea about the security consequences of this patch, so thoughts would be
> much appreciated.
>
> v2: use the GENL_UNS_ADMIN_PERM flag instead of a check in each function
> v3: use separate ifs for UNS_ADMIN_PERM and ADMIN_PERM, instead of one
>     massive one
>
> Reported-by: James Page <james.page-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Signed-off-by: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> CC: Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> CC: Pravin Shelar <pshelar-LZ6Gd1LRuIk@public.gmane.org>
> CC: Justin Pettit <jpettit-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
> CC: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> ---
>  include/uapi/linux/genetlink.h |  1 +
>  net/netlink/genetlink.c        |  4 ++++
>  net/openvswitch/datapath.c     | 20 ++++++++++----------
>  3 files changed, 15 insertions(+), 10 deletions(-)
>
Looks good.

Acked-by: Pravin B Shelar <pshelar-LZ6Gd1LRuIk@public.gmane.org>
