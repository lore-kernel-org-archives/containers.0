From: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/3] Quick vmalloc vs kmalloc fix to the case where array
	size is too large
Date: Tue, 14 Jul 2009 13:26:30 -0400
Message-ID: <2f86c2480907141026h7ca27a4fq898c3ee248280a75__6565.73924138701$1247592537$gmane$org@mail.gmail.com>
References: <20090710230043.16778.29656.stgit@hastromil.mtv.corp.google.com>
	<20090710230205.16778.11707.stgit@hastromil.mtv.corp.google.com>
	<4A5AA3E7.9070800@cn.fujitsu.com>
	<20090713150303.70ab5176.kamezawa.hiroyu@jp.fujitsu.com>
	<2f86c2480907130827u7d2b062bw26bbb80a8e3de657@mail.gmail.com>
	<20090714084950.2401d9a6.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830907132050n226aecb3ucab6746a4d0e81fa@mail.gmail.com>
	<20090714125334.b476aa78.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830907132104o55d31ccexb15e5aa35c31416e@mail.gmail.com>
	<20090714132538.ac0bc44a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090714132538.ac0bc44a.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jul 14, 2009 at 12:25 AM, KAMEZAWA
Hiroyuki<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> My point is
> =A0- More PIDs, More time necessary to read procs file.
> This patch boost it ;) Seems like "visit this later again" ,or FIXME patc=
h.
>
> Thanks,
> -Kame

Indeed. You'll notice the TODOs in the code here referring to the
discussion of a possible dynamic array system in the previous thread.
This is simply a correctness patch that aims to keep performance as
good as it can for the current approach.

(Kame, forgive the double-post; forgot to reply-all the first time)

- Ben
