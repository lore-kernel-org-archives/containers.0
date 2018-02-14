From: Richard Weinberger <richard-S6VGOU4v5edDinCvNWH78Q@public.gmane.org>
Subject: Re: plan9 semantics on Linux - mount namespaces
Date: Wed, 14 Feb 2018 15:19:24 +0100
Message-ID: <2050418.Dl5pXkWGsk@blindfold>
References: <0f058286-a432-379b-f559-f2fe713807ab@metux.net>
	<2658681.ustYaP9yci@blindfold>
	<a2a6f189-008e-38f2-afcb-b9393d8d440a@metux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <a2a6f189-008e-38f2-afcb-b9393d8d440a-EcKl7qYKIbxeoWH0uzbU5w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Enrico Weigelt <lkml-EcKl7qYKIbxeoWH0uzbU5w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Am Mittwoch, 14. Februar 2018, 15:03:55 CET schrieb Enrico Weigelt:
> On 14.02.2018 13:53, Richard Weinberger wrote:
> > It does what you ask it for. > Also see the --setgroups switch.> AFAICT
> > --setgroups=deny is the new
> default, then your command line should just> work. Maybe your unshare
> tool is too old.
> Also doesn't help:
> 
> daemon@alphabox:~ unshare -U -r --setgroups=deny
> unshare: can't open '/proc/self/setgroups': Permission denied

Works here(tm).
Can you debug it? Maybe we miss something obvious.
 
> >> What I'd like to achieve is that processes can manipulate their private
> >> >> namespace at will and mount other filesystems (primarily 9p and
> fuse).>>>> For that, I need to get rid of setuid (and per-file caps) for
> these>> private namespaces.>
> 
> > This is exactly why we have the user namespace.
> > In the user namespace you can create your own mount namespace and do
> > (almost) whatever you want.
> 
> What's the exact relation between user and mnt namespace ?
> Why do I need an own user ns for private mnt ns ? (except for the suid
> bit, which I wanna get rid of anyways).

mount related system calls are root-only. Therefore you need the user 
namespace to become a root in your own little world. :)

Thanks,
//richard

-- 
sigma star gmbh - Eduard-Bodem-Gasse 6 - 6020 Innsbruck - Austria
ATU66964118 - FN 374287y
