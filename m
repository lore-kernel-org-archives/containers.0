From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroup: fix reverse unlock sequence in cgroup_get_sb
Date: Tue, 21 Jul 2009 09:03:01 -0700
Message-ID: <6599ad830907210903q7206cac2l83a9139d19c5e1a__36205.6462131024$1248192373$gmane$org@mail.gmail.com>
References: <1248171926-20232-1-git-send-email-dfeng@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1248171926-20232-1-git-send-email-dfeng-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Xiaotian Feng <dfeng-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jul 21, 2009 at 3:25 AM, Xiaotian Feng<dfeng-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> In cgroup_get_sb, the lock sequence is:
> =A0 =A0 =A0 =A0mutex_lock(&inode->i_mutex);
> =A0 =A0 =A0 =A0mutex_lock(&cgroup->mutex);
> so the last unlock sequence should be:

Make this "so for consistency the last ..." ?

Maybe make the patch title "Make unlock sequence in cgroup_get_sb
consistent" so someone looking through the change logs for fixes to
backport doesn't wrongly thing that this fixes any bug"?

> =A0 =A0 =A0 =A0mutex_unlock(&cgroup->mutex);
> =A0 =A0 =A0 =A0mutex_unlock(&inode->i_mutex);
>
> Signed-off-by: Xiaotian Feng <dfeng-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Paul
