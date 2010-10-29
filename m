From: Lin Ming <lin-7mNXGst3two@public.gmane.org>
Subject: Re: [PATCH 0/5][v5][cr] Checkpoint/restart file locks
Date: Fri, 29 Oct 2010 22:31:21 +0800
Message-ID: <AANLkTiktKVuAtjPaHT9d+7ATpKn+jMonFYzeEmd85L3o__42662.5420259826$1288362822$gmane$org@mail.gmail.com>
References: <1288333001-28838-1-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1288333001-28838-1-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Oct 29, 2010 at 2:16 PM, Sukadev Bhattiprolu
<sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> Checkpoint/restart file locks.
>
> Changelog[v5]:
> =A0 =A0 =A0 =A0- This patchset only checkpoints/restores file locks. C/R =
of
> =A0 =A0 =A0 =A0 =A0file-owner and file-leases will be addressed in follow=
n patches.
> =A0 =A0 =A0 =A0 =A0C/R of file-owner information must deal with nested-co=
ntainers
> =A0 =A0 =A0 =A0 =A0and, will need a way to C/R struct pids. C/R of file-l=
eases depends
> =A0 =A0 =A0 =A0 =A0on C/R of file-owner information.
>
>
> Sukadev Bhattiprolu (5):
> =A0Move file_lock macros into linux/fs.h
> =A0Define flock_set()
> =A0Define flock64_set()
> =A0Checkpoint/restore file-locks
> =A0Document design of C/R of file-locks and leases
>
> =A0Documentation/checkpoint/file-locks | =A0 52 ++++++
> =A0fs/checkpoint.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0318 +++++=
++++++++++++++++++++++++++++--
> =A0fs/locks.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 89=
 ++++++----
> =A0include/linux/checkpoint_hdr.h =A0 =A0 =A0| =A0 17 ++
> =A0include/linux/fs.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 10 +
> =A05 files changed, 433 insertions(+), 53 deletions(-)
> =A0create mode 100644 Documentation/checkpoint/file-locks

Hi,

Which tree are these patches against?

I can't apply them neither to Linus tree(18cb657c) nor
vfs-2.6.git/for-linus branch(a4cdbd8b).

Lin Ming
