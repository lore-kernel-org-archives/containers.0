From: Richard Weinberger <richard-S6VGOU4v5edDinCvNWH78Q@public.gmane.org>
Subject: Re: plan9 semantics on Linux - mount namespaces
Date: Wed, 14 Feb 2018 13:53:40 +0100
Message-ID: <2658681.ustYaP9yci__4574.78689863837$1518613048$gmane$org@blindfold>
References: <0f058286-a432-379b-f559-f2fe713807ab@metux.net>
	<CAFLxGvzxLP_UTQbwEY99bQfyftWzZHwaOP+WrzJ8099EKtbVLg@mail.gmail.com>
	<4864d279-9a3f-eaf4-c297-ea34be604e41@metux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4864d279-9a3f-eaf4-c297-ea34be604e41-EcKl7qYKIbxeoWH0uzbU5w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Enrico Weigelt <lkml-EcKl7qYKIbxeoWH0uzbU5w@public.gmane.org>, Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Enrico,

Am Mittwoch, 14. Februar 2018, 13:38:48 CET schrieb Enrico Weigelt:
> On 14.02.2018 12:30, Richard Weinberger wrote:
> > On Wed, Feb 14, 2018 at 12:27 PM, Enrico Weigelt <lkml-EcKl7qYKIbxeoWH0uzbU5w@public.gmane.org> wrote:
> >> On 14.02.2018 11:24, Aleksa Sarai wrote:
> >>> What distribution are you using and which release?
> >> 
> >> On a self-compiled system.
> >> 
> >> Forgot to enable namespaces in the kernel. Now it seems to work
> >> as root, but not as an unprivileged user:
> >> 
> >> 
> >> daemon@alphabox:~ unshare -r -U
> >> unshare: can't open '/proc/self/setgroups': Permission denied
> >> daemon@alphabox:~ unshare -f -r -U
> >> unshare: can't open '/proc/self/setgroups': Permission denied
> > 
> > Please read http://man7.org/linux/man-pages/man7/user_namespaces.7.html
> > setgroups is a corner case and needs special care.
> 
> I'm still confused. Does the unshare program do something wrong here ?

It does what you ask it for.
Also see the --setgroups switch.
AFAICT --setgroups=deny is the new default, then your command line should just 
work. Maybe your unshare tool is too old.

> Anyways, I doubt that user namespaces help solving my problem.
> 
> What I'd like to achieve is that processes can manipulate their private
> namespace at will and mount other filesystems (primarily 9p and fuse).
> 
> For that, I need to get rid of setuid (and per-file caps) for these
> private namespaces.

This is exactly why we have the user namespace.
In the user namespace you can create your own mount namespace and do (almost) 
whatever you want.
Please note that you cannot mount any kind of filesystem.
For FUSE, see https://lwn.net/Articles/684774/

Thanks,
//richard

-- 
sigma star gmbh - Eduard-Bodem-Gasse 6 - 6020 Innsbruck - Austria
ATU66964118 - FN 374287y
