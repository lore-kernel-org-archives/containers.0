From: Tomasz Buchert <tomasz.buchert-MZpvjPyXg2s@public.gmane.org>
Subject: [PATCH 0/3] Two bugfixes for cgroup freezer.
Date: Thu, 12 Aug 2010 11:45:20 +0200
Message-ID: <1281606323-16245-1-git-send-email-tomasz.buchert__49217.1838334345$1281606379$gmane$org@inria.fr>
References: <1281470001-14320-1-git-send-email-tomasz.buchert@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1281470001-14320-1-git-send-email-tomasz.buchert-MZpvjPyXg2s@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Tomasz Buchert <tomasz.buchert-MZpvjPyXg2s@public.gmane.org>
List-Id: containers.vger.kernel.org

These patches fixes two bugs I discovered when working with
the cgroup freezer. These patches fix them (and probably also
some other variations of them) and now the kernel passes
testcases that uncovered the bugs in the first place.

Please review.

Tomasz

Tomasz Buchert (3):
  cgroup_freezer: Unnecessary test in cgroup_freezing_or_frozen
  cgroup_freezer: Fix can_attach to prohibit moving from/to
    freezing/frozen cgroups
  cgroup_freezer: update_freezer_state does incorrect state
    transactions

 kernel/cgroup_freezer.c |   74 +++++++++++++++++++++-------------------------
 1 files changed, 34 insertions(+), 40 deletions(-)
