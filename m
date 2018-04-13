From: Djalal Harouni <tixxdz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] [RFC][WIP] namespace.c: Allow some unprivileged proc
	mounts when not fully visible
Date: Sat, 14 Apr 2018 00:41:31 +0200
Message-ID: <CAEiveUf5LWpvA-QMm3eYr9yFgUjwyQdkk-WVptze9m_EfbGMwg__14234.6354471103$1523659192$gmane$org@mail.gmail.com>
References: <20180404115311.725-1-alban@kinvolk.io>
	<87tvsrjai0.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87tvsrjai0.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Alexey Gladkov <gladkov.alexey-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Iago Lopez Galeiras <iago-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Daniel J Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Akihiro Suda <suda.akihiro-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>, Alban Crequy <alban.crequy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Michael Crosby <crosbymichael-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Stephen J Day <stephen.day-FCduhRhOUaTQT0dZR+AlfA@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jess Frazelle <acidburn-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Apr 4, 2018 at 4:45 PM, Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
[...]
>
> The only option I have seen proposed that might qualify as something
> general purpose and simple is a new filesystem that is just the process
> directories of proc.  As there would in essence be no files that would
> need restrictions it would be safe to allow anyone to mount without
> restriction.
>
Eric, there is a series for this:
https://www.mail-archive.com/linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg1533642.html

patch on top for pids:
https://github.com/legionus/linux/commit/993a2a5b9af95b0ac901ff41d32124b72ed676e3

it was reviewed, and suggestions were integrated from Andy and Al Viro
feedback, thanks. It works on Debian, Ubuntu and others, not on Fedora
due to bug with dracut+systemd.

I do not have time to work on it now, anyone can just pick them.

Thanks!


-- 
tixxdz
