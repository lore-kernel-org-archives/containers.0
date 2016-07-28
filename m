From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [GIT PULL] binfmt_misc updates for 4.7+ merge window
Date: Wed, 27 Jul 2016 20:21:05 -0700
Message-ID: <1469676065.3998.19.camel__28656.9387805232$1469697554$gmane$org@perches.com>
References: <1469673106.3565.9.camel@HansenPartnership.com>
	<1469674670.3998.18.camel@perches.com>
	<CA+55aFzK_kNZBNU+Eq+VuuGttOTMP3xK1F9Lsxcff-wkzaNkyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CA+55aFzK_kNZBNU+Eq+VuuGttOTMP3xK1F9Lsxcff-wkzaNkyg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 2016-07-27 at 20:12 -0700, Linus Torvalds wrote:
> On Wed, Jul 27, 2016 at 7:57 PM, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> wrote:
> > =

> > =

> > It'll continue to list only Al Viro unless a --git cmdline option
> > is specified and almost no one uses that.
> Did you actually try it.

yes.
$ ./scripts/get_maintainer.pl -f fs/binfmt_misc.c=A0
Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org> (maintainer:FILESYSTEMS (VFS
and infrastructure))
linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:FILESYSTEMS (VFS and
infrastructure))
linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list)
joe@XPS-9350:~/linux/next$ ./scripts/get_maintainer.pl -f
fs/binfmt_misc.c --git
Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org> (maintainer:FILESYSTEMS (VFS
and
infrastructure),commit_signer:2/3=3D67%,authored:2/3=3D67%,added_lines:10/49
=3D20%,removed_lines:14/16=3D88%)
James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
(commit_signer:1/3=3D33%,authored:1/3=3D33%,added_lines:39/49=3D80%,removed=
_li
nes:2/16=3D12%)
Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> (commit_signer:1/3=3D33%)
linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:FILESYSTEMS (VFS and
infrastructure))
linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list)

> The get_maintainer.pl script should use "--git-fallback" by default,
> so in the absence of a an exact match (which it won't have) it _will_
> in fact pick out recent git authorship.
> =

> (Where "recent" means "in the last year" by default).
> =

> I depend that recent authorship matching quite a lot. In fact, I think
> the reason nobody uses "--git" is that the default "--git-fallback" is
> sufficient most of the time.
> =

> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0Linus
